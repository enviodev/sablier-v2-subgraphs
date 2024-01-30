open ChainWorkerTypes
type rec t = {
  mutable currentBlockInterval: int,
  mutable currentlyFetchingToBlock: int,
  mutable latestFetchedBlockTimestamp: int,
  mutable shouldContinueFetching: bool,
  mutable isFetching: bool,
  mutable hasStoppedFetchingCallBack: unit => unit,
  newRangeQueriedCallBacks: SDSL.Queue.t<unit => unit>,
  contractAddressMapping: ContractAddressingMap.mapping,
  blockLoader: LazyLoader.asyncMap<Ethers.JsonRpcProvider.block>,
  chainConfig: Config.chainConfig,
  rpcConfig: Config.rpcConfig,
  caughtUpToHeadHook: t => promise<unit>,
}

let stopFetchingEvents = (self: t) => {
  //set the shouldContinueFetching to false
  self.shouldContinueFetching = false

  //set a resolve callback for when it's actually stopped
  if !self.isFetching {
    Promise.resolve()
  } else {
    Promise.make((resolve, _reject) => {
      self.hasStoppedFetchingCallBack = () => resolve(. ())
    })
  }
}

let make = (
  ~caughtUpToHeadHook=?,
  ~contractAddressMapping=?,
  chainConfig: Config.chainConfig,
): t => {
  let caughtUpToHeadHook = switch caughtUpToHeadHook {
  | None => (_self: t) => Promise.resolve()
  | Some(hook) => hook
  }

  let logger = Logging.createChild(
    ~params={
      "chainId": chainConfig.chainId,
      "workerType": "rpc",
      "loggerFor": "Used only in logging regestration of static contract addresses",
    },
  )

  let contractAddressMapping = switch contractAddressMapping {
  | None =>
    let m = ContractAddressingMap.make()
    //Add all contracts and addresses from config
    //Dynamic contracts are checked in DB on start
    m->ContractAddressingMap.registerStaticAddresses(~chainConfig, ~logger)
    m
  | Some(m) => m
  }

  let rpcConfig = switch chainConfig.syncSource {
  | Rpc(rpcConfig) => rpcConfig
  | syncSource =>
    let exn = IncorrectSyncSource(syncSource)
    logger->Logging.childErrorWithExn(
      exn,
      {
        "msg": "Parsed sync source to an rpc worker",
        "syncSource": syncSource,
      },
    )
    exn->raise
  }

  let blockLoader = LazyLoader.make(
    ~loaderFn=blockNumber =>
      EventFetching.getUnwrappedBlockWithBackoff(
        ~provider=rpcConfig.provider,
        ~backoffMsOnFailure=1000,
        ~blockNumber,
      ),
    ~metadata={
      asyncTaskName: "blockLoader: fetching block timestamp - `getBlock` rpc call",
      caller: "RPC ChainWorker",
      suggestedFix: "This likely means the RPC url you are using is not respending correctly. Please try another RPC endipoint.",
    },
    (),
  )

  {
    currentlyFetchingToBlock: 0,
    currentBlockInterval: rpcConfig.syncConfig.initialBlockInterval,
    latestFetchedBlockTimestamp: 0,
    shouldContinueFetching: true,
    isFetching: false,
    hasStoppedFetchingCallBack: () => (),
    newRangeQueriedCallBacks: SDSL.Queue.make(),
    contractAddressMapping,
    blockLoader,
    chainConfig,
    rpcConfig,
    caughtUpToHeadHook,
  }
}

let startWorker = async (
  self: t,
  ~startBlock: int,
  ~logger: Pino.t,
  ~fetchedEventQueue: ChainEventQueue.t,
) => {
  let {rpcConfig, chainConfig, contractAddressMapping, blockLoader} = self
  self.shouldContinueFetching = true
  self.isFetching = true

  let sc = rpcConfig.syncConfig
  let provider = rpcConfig.provider

  let fromBlockRef = ref(startBlock)

  let getCurrentBlockFromRPC = () =>
    provider
    ->Ethers.JsonRpcProvider.getBlockNumber
    ->Promise.catch(_err => {
      logger->Logging.childWarn("Error getting current block number")
      0->Promise.resolve
    })
  let currentBlock: ref<int> = ref(await getCurrentBlockFromRPC())

  DbFunctions.ChainMetadata.setChainMetadataRow(
    ~chainId=chainConfig.chainId,
    ~startBlock,
    ~blockHeight=currentBlock.contents,
  )->ignore

  let isNewBlocksToFetch = () => fromBlockRef.contents <= currentBlock.contents

  let rec checkShouldContinue = async (): bool => {
    //If there are no new blocks to fetch, poll the provider for
    //a new block until it arrives
    if !isNewBlocksToFetch() {
      self.caughtUpToHeadHook(self)->ignore

      let newBlock = await provider->EventUtils.waitForNextBlock
      currentBlock := newBlock

      let _ = await checkShouldContinue()
    }

    true
  }

  while (await checkShouldContinue()) && self.shouldContinueFetching {
    let blockInterval = self.currentBlockInterval
    let targetBlock = Pervasives.min(
      currentBlock.contents,
      fromBlockRef.contents + blockInterval - 1,
    )

    self.currentlyFetchingToBlock = targetBlock

    let toBlockTimestampPromise =
      blockLoader
      ->LazyLoader.get(self.currentlyFetchingToBlock)
      ->Promise.thenResolve(block => block.timestamp)

    //Needs to be run on every loop in case of new registrations
    let contractInterfaceManager = ContractInterfaceManager.make(
      ~contractAddressMapping,
      ~chainConfig,
    )

    let {
      eventBatchPromises,
      finalExecutedBlockInterval,
    } = await EventFetching.getContractEventsOnFilters(
      ~contractInterfaceManager,
      ~fromBlock=fromBlockRef.contents,
      ~toBlock=targetBlock,
      ~initialBlockInterval=blockInterval,
      ~minFromBlockLogIndex=0,
      ~rpcConfig,
      ~chainId=chainConfig.chainId,
      ~blockLoader,
      ~logger,
      (),
    )

    for i in 0 to eventBatchPromises->Belt.Array.length - 1 {
      let {timestampPromise, chainId, blockNumber, logIndex, eventPromise} = eventBatchPromises[i]

      let queueItem: Types.eventBatchQueueItem = {
        timestamp: await timestampPromise,
        chainId,
        blockNumber,
        logIndex,
        event: await eventPromise,
      }

      await fetchedEventQueue->ChainEventQueue.awaitQueueSpaceAndPushItem(queueItem)

      //Loop through any callbacks on the queue waiting for confirmation of a new
      //range queried and run callbacks needs to happen after each item is added
      //else this we could be blocked from adding items to the queue and from popping
      //items off without running callbacks
      self.newRangeQueriedCallBacks->SDSL.Queue.popForEach(callback => callback())
    }

    fromBlockRef := targetBlock + 1

    // Increase batch size going forward, but do not increase past a configured maximum
    // See: https://en.wikipedia.org/wiki/Additive_increase/multiplicative_decrease
    self.currentBlockInterval = Pervasives.min(
      finalExecutedBlockInterval + sc.accelerationAdditive,
      sc.intervalCeiling,
    )

    //Set the latest fetched blocktimestamp in state
    self.latestFetchedBlockTimestamp = await toBlockTimestampPromise

    //Loop through any callbacks on the queue waiting for confirmation of a new
    //range queried and run callbacks. Even if no events we now have a new latest
    //timestamp
    self.newRangeQueriedCallBacks->SDSL.Queue.popForEach(callback => callback())

    // Only fetch the current block if it could affect the length of our next batch
    let nextIntervalEnd = fromBlockRef.contents + self.currentBlockInterval - 1
    if currentBlock.contents <= nextIntervalEnd {
      logger->Logging.childInfo(
        `We will finish processing known blocks in the next block. Checking for a newer block than ${currentBlock.contents->Belt.Int.toString}`,
      )
      currentBlock := (await getCurrentBlockFromRPC())
      DbFunctions.ChainMetadata.setChainMetadataRow(
        ~chainId=chainConfig.chainId,
        ~startBlock,
        ~blockHeight=currentBlock.contents,
      )->ignore

      logger->Logging.childInfo(
        `getCurrentBlockFromRPC() => ${currentBlock.contents->Belt.Int.toString}`,
      )
    }
  }
}

//Public methods
let startFetchingEvents = async (
  self: t,
  ~logger: Pino.t,
  ~fetchedEventQueue: ChainEventQueue.t,
) => {
  let {chainConfig, contractAddressMapping} = self

  let latestProcessedBlock = await DbFunctions.EventSyncState.getLatestProcessedBlockNumber(
    ~chainId=chainConfig.chainId,
  )

  let startBlock =
    latestProcessedBlock->Belt.Option.mapWithDefault(chainConfig.startBlock, latestProcessedBlock =>
      latestProcessedBlock + 1
    )

  logger->Logging.childTrace({
    "msg": "Starting fetching events for chain.",
    "startBlock": startBlock,
    "latestProcessedBlock": latestProcessedBlock,
  })

  //Add all dynamic contracts from DB
  let dynamicContracts =
    await DbFunctions.sql->DbFunctions.DynamicContractRegistry.readDynamicContractsOnChainIdAtOrBeforeBlock(
      ~chainId=chainConfig.chainId,
      ~startBlock,
    )

  dynamicContracts->Belt.Array.forEach(({contractType, contractAddress}) =>
    contractAddressMapping->ContractAddressingMap.addAddress(
      ~name=contractType,
      ~address=contractAddress,
    )
  )

  await self->startWorker(~startBlock, ~logger, ~fetchedEventQueue)

  self.hasStoppedFetchingCallBack()
}

let fetchArbitraryEvents = async (
  self: t,
  ~dynamicContracts: array<Types.dynamicContractRegistryEntity>,
  ~fromBlock,
  ~fromLogIndex,
  ~toBlock,
  ~logger,
) => {
  let {chainConfig, rpcConfig, currentBlockInterval, blockLoader} = self

  let contractInterfaceManager =
    dynamicContracts
    ->Belt.Array.map(({contractAddress, contractType, chainId}) => {
      let chainConfig = switch Config.config->Js.Dict.get(chainId->Belt.Int.toString) {
      | None =>
        let exn = UndefinedChainConfig(chainId)
        logger->Logging.childErrorWithExn(exn, "Could not find chain config for given ChainId")
        exn->raise
      | Some(c) => c
      }

      let singleContractInterfaceManager = ContractInterfaceManager.makeFromSingleContract(
        ~contractAddress,
        ~contractName=contractType,
        ~chainConfig,
      )

      singleContractInterfaceManager
    })
    ->ContractInterfaceManager.combineInterfaceManagers

  let {eventBatchPromises} = await EventFetching.getContractEventsOnFilters(
    ~contractInterfaceManager,
    ~fromBlock,
    ~toBlock, //Fetch up till the block that the worker has not included this address
    ~initialBlockInterval=currentBlockInterval,
    ~minFromBlockLogIndex=fromLogIndex,
    ~rpcConfig,
    ~chainId=chainConfig.chainId,
    ~blockLoader,
    ~logger,
    (),
  )
  await eventBatchPromises
  ->Belt.Array.map(async ({
    timestampPromise,
    chainId,
    blockNumber,
    logIndex,
    eventPromise,
  }): Types.eventBatchQueueItem => {
    timestamp: await timestampPromise,
    chainId,
    blockNumber,
    logIndex,
    event: await eventPromise,
  })
  ->Promise.all
}

let getContractAddressMapping = (self: t) => self.contractAddressMapping

let addDynamicContractAndFetchMissingEvents = async (
  self: t,
  ~dynamicContracts: array<Types.dynamicContractRegistryEntity>,
  ~fromBlock,
  ~fromLogIndex,
  ~logger,
): array<Types.eventBatchQueueItem> => {
  let {contractAddressMapping, currentlyFetchingToBlock} = self

  let unaddedDynamicContracts = dynamicContracts->Belt.Array.keep(({
    contractAddress,
    contractType,
  }) => {
    contractAddressMapping->ContractAddressingMap.addAddressIfNotExists(
      ~address=contractAddress,
      ~name=contractType,
    )
  })

  await self->fetchArbitraryEvents(
    ~dynamicContracts=unaddedDynamicContracts,
    ~toBlock=currentlyFetchingToBlock,
    ~fromLogIndex,
    ~fromBlock,
    ~logger,
  )
}

let addNewRangeQueriedCallback = (self: t): promise<unit> => {
  self.newRangeQueriedCallBacks->ChainEventQueue.insertCallbackAwaitPromise
}

let getLatestFetchedBlockTimestamp = (self: t): int => self.latestFetchedBlockTimestamp
