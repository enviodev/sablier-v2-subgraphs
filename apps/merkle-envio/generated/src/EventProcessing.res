let addEventToRawEvents = (
  event: Types.eventLog<'a>,
  ~inMemoryStore: IO.InMemoryStore.t,
  ~chainId,
  ~jsonSerializedParams: Js.Json.t,
  ~eventName: Types.eventName,
) => {
  let {
    blockNumber,
    logIndex,
    transactionIndex,
    transactionHash,
    srcAddress,
    blockHash,
    blockTimestamp,
  } = event

  let eventId = EventUtils.packEventIndex(~logIndex, ~blockNumber)
  let rawEvent: Types.rawEventsEntity = {
    chainId,
    eventId: eventId->Ethers.BigInt.toString,
    blockNumber,
    logIndex,
    transactionIndex,
    transactionHash,
    srcAddress,
    blockHash,
    blockTimestamp,
    eventType: eventName->Types.eventName_encode,
    params: jsonSerializedParams->Js.Json.stringify,
  }

  let eventIdStr = eventId->Ethers.BigInt.toString

  inMemoryStore.rawEvents->IO.InMemoryStore.RawEvents.set(
    ~key={chainId, eventId: eventIdStr},
    ~entity=rawEvent,
    ~dbOp=Set,
  )
}

let updateEventSyncState = (
  event: Types.eventLog<'a>,
  ~chainId,
  ~inMemoryStore: IO.InMemoryStore.t,
) => {
  let {blockNumber, logIndex, transactionIndex, blockTimestamp} = event
  let _ = inMemoryStore.eventSyncState->IO.InMemoryStore.EventSyncState.set(
    ~key=chainId,
    ~entity={
      chainId,
      blockTimestamp,
      blockNumber,
      logIndex,
      transactionIndex,
    },
    ~dbOp=Set,
  )
}

/** Construct an error object for the logger with event prameters*/
let getEventErr = (~msg, ~error, ~event: Types.eventLog<'a>, ~chainId, ~eventName) => {
  let eventInfoObj = {
    "eventName": eventName,
    "txHash": event.transactionHash,
    "blockNumber": event.blockNumber->Belt.Int.toString,
    "logIndex": event.logIndex->Belt.Int.toString,
    "transactionIndex": event.transactionIndex->Belt.Int.toString,
    "networkId": chainId,
  }
  {
    "msg": msg,
    "error": error,
    "event-details": eventInfoObj,
  }
}

/** Constructs an error object with a caught exception related to an event*/
let getEventErrWithExn = exn => {
  let (msg, error) = switch exn {
  | Js.Exn.Error(obj) =>
    switch Js.Exn.message(obj) {
    | Some(errMsg) =>
      Some((
        "Caught a JS exception in your ${eventName}.handler, please fix the error to keep the indexer running smoothly",
        errMsg,
      ))
    | None => None
    }
  | _ => None
  }->Belt.Option.getWithDefault((
    "Unknown error in your ${eventName}.handler, please review your code carefully and use the stack trace to help you find the issue.",
    "Unknown",
  ))

  getEventErr(~msg, ~error)
}

/** Constructs specific sync/async mismatch error */
let getSyncAsyncMismatchErr = (~event) =>
  getEventErr(
    ~error="Mismatched sync/async handler and context",
    ~msg="Unexpected mismatch between sync/async handler and context. Please contact the team.",
    ~event,
  )

/** Function composer for handling an event*/
let handleEvent = (
  ~inMemoryStore,
  ~chainId,
  ~serializer,
  ~context: Context.genericContextCreatorFunctions<'b, 'c, 'd>,
  ~handlerWithContextGetter: Handlers.handlerWithContextGetterSyncAsync<'a, 'b, 'c, 'd>,
  ~event,
  ~eventName,
  ~cb,
) => {
  event->updateEventSyncState(~chainId, ~inMemoryStore)

  let jsonSerializedParams = event.params->serializer

  event->addEventToRawEvents(~inMemoryStore, ~chainId, ~jsonSerializedParams, ~eventName)

  try {
    switch handlerWithContextGetter {
    | Sync({handler, contextGetter}) =>
      //Call the context getter here, ensures no stale values in the context
      //Since loaders and previous handlers have already run
      let context = contextGetter(context)
      handler(~event, ~context)
      cb()->ignore
    | Async({handler, contextGetter}) =>
      //Call the context getter here, ensures no stale values in the context
      //Since loaders and previous handlers have already run
      let context = contextGetter(context)
      handler(~event, ~context)->Promise.thenResolve(cb)->ignore
    }
  } catch {
  // NOTE: we are only catching javascript errors here - please see docs on how to catch rescript errors too: https://rescript-lang.org/docs/manual/latest/exception
  | userCodeException =>
    let errorObj =
      userCodeException->getEventErrWithExn(
        ~event,
        ~chainId,
        ~eventName=eventName->Types.eventName_encode,
      )
    //Logger takes any type just currently bound to string
    let errorMessage = errorObj->Obj.magic

    context.log.errorWithExn(Js.Exn.asJsExn(userCodeException), errorMessage)
    cb()->ignore
  }
}

let eventRouter = (item: Context.eventRouterEventAndContext, ~inMemoryStore, ~cb) => {
  let {event, chainId} = item

  switch event {
  | MerkleLLV21Contract_ClaimWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=MerkleLLV21_Claim,
      ~serializer=Types.MerkleLLV21Contract.ClaimEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.MerkleLLV21Contract.Claim.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )

  | MerkleLLV21Contract_ClawbackWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=MerkleLLV21_Clawback,
      ~serializer=Types.MerkleLLV21Contract.ClawbackEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.MerkleLLV21Contract.Clawback.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )

  | MerkleLLV21Contract_TransferAdminWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=MerkleLLV21_TransferAdmin,
      ~serializer=Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.MerkleLLV21Contract.TransferAdmin.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )

  | MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=MerkleLockupFactoryV21_CreateMerkleStreamerLL,
      ~serializer=Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLL.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )
  }
}

type readEntitiesResult = {
  timestamp: int,
  chainId: int,
  blockNumber: int,
  logIndex: int,
  entityReads: array<Types.entityRead>,
  eventAndContext: Context.eventAndContext,
}

type rec readEntitiesResultPromise = {
  timestamp: int,
  chainId: int,
  blockNumber: int,
  logIndex: int,
  data: (
    array<Types.entityRead>,
    Context.eventAndContext,
    option<array<readEntitiesResultPromise>>,
  ),
}

let asyncGetters: Context.entityGetters = {
  getAction: id => DbFunctions.Action.readEntities(DbFunctions.sql, [id]),
  getActivity: id => DbFunctions.Activity.readEntities(DbFunctions.sql, [id]),
  getAsset: id => DbFunctions.Asset.readEntities(DbFunctions.sql, [id]),
  getCampaign: id => DbFunctions.Campaign.readEntities(DbFunctions.sql, [id]),
  getFactory: id => DbFunctions.Factory.readEntities(DbFunctions.sql, [id]),
  getWatcher: id => DbFunctions.Watcher.readEntities(DbFunctions.sql, [id]),
}

let rec loadReadEntitiesInner = async (
  ~inMemoryStore,
  ~eventBatch: array<Types.eventBatchQueueItem>,
  ~logger,
  ~chainManager: ChainManager.t,
): array<readEntitiesResultPromise> => {
  // Recursively load entities
  let loadNestedReadEntities = async (
    ~logIndex,
    ~dynamicContracts: array<Types.dynamicContractRegistryEntity>,
    ~fromBlock,
    ~currentBatchLastEventIndex: EventUtils.multiChainEventIndex,
    ~chainId: int,
  ): array<readEntitiesResultPromise> => {
    let chainFetcher = chainManager->ChainManager.getChainFetcher(~chainId)
    let eventBatchPromises =
      await chainFetcher->ChainFetcher.addDynamicContractAndFetchMissingEvents(
        ~fromBlock,
        ~dynamicContracts,
        ~fromLogIndex=logIndex + 1,
      )

    let eventsForCurrentBatch = []
    for i in 0 to eventBatchPromises->Belt.Array.length - 1 {
      let item = eventBatchPromises[i]
      let {timestamp, chainId, blockNumber, logIndex} = item

      let eventIndex: EventUtils.multiChainEventIndex = {
        timestamp,
        chainId,
        blockNumber,
        logIndex,
      }

      // If the event is earlier than the last event of the current batch, then add it to the current batch
      if EventUtils.isEarlierEvent(eventIndex, currentBatchLastEventIndex) {
        eventsForCurrentBatch->Js.Array2.push(item)->ignore
      } else {
        // Otherwise, add it to the arbitrary events queue for later batches
        chainManager->ChainManager.addItemToArbitraryEvents(item)
      }
    }

    //Only load inner batch if there are any events for the current batch
    if eventsForCurrentBatch->Belt.Array.length > 0 {
      await loadReadEntitiesInner(
        ~inMemoryStore,
        ~eventBatch=eventsForCurrentBatch,
        ~logger,
        ~chainManager,
      )
    } else {
      //Else return an empty array since nothing will load
      []
    }
  }

  let baseResults: array<readEntitiesResultPromise> = []

  let optLastItemInBatch = eventBatch->Belt.Array.get(eventBatch->Belt.Array.length - 1)

  switch optLastItemInBatch {
  | None => [] //there is no last item because the array is empty and we should return early
  | Some(lastItemInBatch) =>
    let currentBatchLastEventIndex: EventUtils.multiChainEventIndex = {
      timestamp: lastItemInBatch.timestamp,
      chainId: lastItemInBatch.chainId,
      blockNumber: lastItemInBatch.blockNumber,
      logIndex: lastItemInBatch.logIndex,
    }

    for i in 0 to eventBatch->Belt.Array.length - 1 {
      let {timestamp, chainId, blockNumber, logIndex, event} = eventBatch[i]

      baseResults
      ->Js.Array2.push({
        timestamp,
        chainId,
        blockNumber,
        logIndex,
        data: switch event {
        | MerkleLLV21Contract_Claim(event) => {
            let contextHelper = Context.MerkleLLV21Contract.ClaimEvent.contextCreator(
              ~inMemoryStore,
              ~chainId,
              ~event,
              ~logger,
              ~asyncGetters,
            )

            let context = contextHelper.getLoaderContext()

            let loader = Handlers.MerkleLLV21Contract.Claim.getLoader()

            try {
              loader(~event, ~context)
            } catch {
            // NOTE: we are only catching javascript errors here - please see docs on how to catch rescript errors too: https://rescript-lang.org/docs/manual/latest/exception
            | userCodeException =>
              let errorObj =
                userCodeException->getEventErrWithExn(
                  ~event,
                  ~chainId,
                  ~eventName="MerkleLLV21.Claim",
                )
              // NOTE: we could use the user `uerror` function instead rather than using a system error. This is debatable.
              logger->Logging.childErrorWithExn(userCodeException, errorObj)
            }

            let {logIndex, blockNumber} = event

            let dynamicContracts = contextHelper.getAddedDynamicContractRegistrations()

            (
              contextHelper.getEntitiesToLoad(),
              Context.MerkleLLV21Contract_ClaimWithContext(event, contextHelper),
              if Belt.Array.length(dynamicContracts) > 0 {
                Some(
                  await loadNestedReadEntities(
                    ~logIndex,
                    ~dynamicContracts,
                    ~fromBlock=blockNumber,
                    ~chainId,
                    ~currentBatchLastEventIndex,
                  ),
                )
              } else {
                None
              },
            )
          }
        | MerkleLLV21Contract_Clawback(event) => {
            let contextHelper = Context.MerkleLLV21Contract.ClawbackEvent.contextCreator(
              ~inMemoryStore,
              ~chainId,
              ~event,
              ~logger,
              ~asyncGetters,
            )

            let context = contextHelper.getLoaderContext()

            let loader = Handlers.MerkleLLV21Contract.Clawback.getLoader()

            try {
              loader(~event, ~context)
            } catch {
            // NOTE: we are only catching javascript errors here - please see docs on how to catch rescript errors too: https://rescript-lang.org/docs/manual/latest/exception
            | userCodeException =>
              let errorObj =
                userCodeException->getEventErrWithExn(
                  ~event,
                  ~chainId,
                  ~eventName="MerkleLLV21.Clawback",
                )
              // NOTE: we could use the user `uerror` function instead rather than using a system error. This is debatable.
              logger->Logging.childErrorWithExn(userCodeException, errorObj)
            }

            let {logIndex, blockNumber} = event

            let dynamicContracts = contextHelper.getAddedDynamicContractRegistrations()

            (
              contextHelper.getEntitiesToLoad(),
              Context.MerkleLLV21Contract_ClawbackWithContext(event, contextHelper),
              if Belt.Array.length(dynamicContracts) > 0 {
                Some(
                  await loadNestedReadEntities(
                    ~logIndex,
                    ~dynamicContracts,
                    ~fromBlock=blockNumber,
                    ~chainId,
                    ~currentBatchLastEventIndex,
                  ),
                )
              } else {
                None
              },
            )
          }
        | MerkleLLV21Contract_TransferAdmin(event) => {
            let contextHelper = Context.MerkleLLV21Contract.TransferAdminEvent.contextCreator(
              ~inMemoryStore,
              ~chainId,
              ~event,
              ~logger,
              ~asyncGetters,
            )

            let context = contextHelper.getLoaderContext()

            let loader = Handlers.MerkleLLV21Contract.TransferAdmin.getLoader()

            try {
              loader(~event, ~context)
            } catch {
            // NOTE: we are only catching javascript errors here - please see docs on how to catch rescript errors too: https://rescript-lang.org/docs/manual/latest/exception
            | userCodeException =>
              let errorObj =
                userCodeException->getEventErrWithExn(
                  ~event,
                  ~chainId,
                  ~eventName="MerkleLLV21.TransferAdmin",
                )
              // NOTE: we could use the user `uerror` function instead rather than using a system error. This is debatable.
              logger->Logging.childErrorWithExn(userCodeException, errorObj)
            }

            let {logIndex, blockNumber} = event

            let dynamicContracts = contextHelper.getAddedDynamicContractRegistrations()

            (
              contextHelper.getEntitiesToLoad(),
              Context.MerkleLLV21Contract_TransferAdminWithContext(event, contextHelper),
              if Belt.Array.length(dynamicContracts) > 0 {
                Some(
                  await loadNestedReadEntities(
                    ~logIndex,
                    ~dynamicContracts,
                    ~fromBlock=blockNumber,
                    ~chainId,
                    ~currentBatchLastEventIndex,
                  ),
                )
              } else {
                None
              },
            )
          }
        | MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL(event) => {
            let contextHelper = Context.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.contextCreator(
              ~inMemoryStore,
              ~chainId,
              ~event,
              ~logger,
              ~asyncGetters,
            )

            let context = contextHelper.getLoaderContext()

            let loader = Handlers.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLL.getLoader()

            try {
              loader(~event, ~context)
            } catch {
            // NOTE: we are only catching javascript errors here - please see docs on how to catch rescript errors too: https://rescript-lang.org/docs/manual/latest/exception
            | userCodeException =>
              let errorObj =
                userCodeException->getEventErrWithExn(
                  ~event,
                  ~chainId,
                  ~eventName="MerkleLockupFactoryV21.CreateMerkleStreamerLL",
                )
              // NOTE: we could use the user `uerror` function instead rather than using a system error. This is debatable.
              logger->Logging.childErrorWithExn(userCodeException, errorObj)
            }

            let {logIndex, blockNumber} = event

            let dynamicContracts = contextHelper.getAddedDynamicContractRegistrations()

            (
              contextHelper.getEntitiesToLoad(),
              Context.MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLWithContext(
                event,
                contextHelper,
              ),
              if Belt.Array.length(dynamicContracts) > 0 {
                Some(
                  await loadNestedReadEntities(
                    ~logIndex,
                    ~dynamicContracts,
                    ~fromBlock=blockNumber,
                    ~chainId,
                    ~currentBatchLastEventIndex,
                  ),
                )
              } else {
                None
              },
            )
          }
        },
      })
      ->ignore
    }

    baseResults
  }
}

type rec nestedResult = {
  result: readEntitiesResult,
  nested: option<array<nestedResult>>,
}
// Given a read entities promise, unwrap just the top level result
let unwrap = (p: readEntitiesResultPromise): readEntitiesResult => {
  let (er, ec, _) = p.data
  {
    timestamp: p.timestamp,
    chainId: p.chainId,
    blockNumber: p.blockNumber,
    logIndex: p.logIndex,
    entityReads: er,
    eventAndContext: ec,
  }
}

// Recursively await the promises to get their results
let rec recurseEntityPromises = async (p: readEntitiesResultPromise): nestedResult => {
  let (_, _, nested) = p.data

  {
    result: unwrap(p),
    nested: switch nested {
    | None => None
    | Some(xs) => Some(await xs->Belt.Array.map(recurseEntityPromises)->Promise.all)
    },
  }
}

// This function is used to sort results according to their order in the chain
let resultPosition = ({timestamp, chainId, blockNumber, logIndex}: readEntitiesResult) =>
  EventUtils.getEventComparator({
    timestamp,
    chainId,
    blockNumber,
    logIndex,
  })

// Given the recursively awaited results, flatten them down into a single list using chain order
let rec flattenNested = (xs: array<nestedResult>): array<readEntitiesResult> => {
  let baseResults = xs->Belt.Array.map(({result}) => result)
  let nestedNestedResults = xs->Belt.Array.keepMap(({nested}) => nested)
  let nestedResults = nestedNestedResults->Belt.Array.map(flattenNested)
  Belt.Array.reduce(nestedResults, baseResults, (acc, additionalResults) =>
    Utils.mergeSorted(resultPosition, acc, additionalResults)
  )
}

let loadReadEntities = async (
  ~inMemoryStore,
  ~eventBatch: array<Types.eventBatchQueueItem>,
  ~chainManager: ChainManager.t,
  ~logger: Pino.t,
): array<Context.eventRouterEventAndContext> => {
  let batch = await loadReadEntitiesInner(
    ~inMemoryStore,
    ~eventBatch,
    ~logger,
    ~chainManager: ChainManager.t,
  )

  let nestedResults = await batch->Belt.Array.map(recurseEntityPromises)->Promise.all
  let mergedResults = flattenNested(nestedResults)

  // Project the result record into a tuple, so that we can unzip the two payloads.
  let resultToPair = ({entityReads, eventAndContext, chainId}): (
    array<Types.entityRead>,
    Context.eventRouterEventAndContext,
  ) => (entityReads, {chainId, event: eventAndContext})

  let (readEntitiesGrouped, contexts): (
    array<array<Types.entityRead>>,
    array<Context.eventRouterEventAndContext>,
  ) =
    mergedResults->Belt.Array.map(resultToPair)->Belt.Array.unzip

  let readEntities = readEntitiesGrouped->Belt.Array.concatMany

  await IO.loadEntitiesToInMemStore(~inMemoryStore, ~entityBatch=readEntities)

  contexts
}

let registerProcessEventBatchMetrics = (
  ~logger,
  ~batchSize,
  ~loadDuration,
  ~handlerDuration,
  ~dbWriteDuration,
) => {
  logger->Logging.childTrace({
    "message": "Finished processing batch",
    "batch_size": batchSize,
    "loader_time_elapsed": loadDuration,
    "handlers_time_elapsed": handlerDuration,
    "write_time_elapsed": dbWriteDuration,
  })

  Prometheus.incrementLoadEntityDurationCounter(~duration=loadDuration)

  Prometheus.incrementEventRouterDurationCounter(~duration=handlerDuration)

  Prometheus.incrementExecuteBatchDurationCounter(~duration=dbWriteDuration)

  Prometheus.incrementEventsProcessedCounter(~number=batchSize)
}

let processEventBatch = async (
  ~eventBatch: array<Types.eventBatchQueueItem>,
  ~chainManager: ChainManager.t,
  ~inMemoryStore: IO.InMemoryStore.t,
) => {
  let logger = Logging.createChild(
    ~params={
      "context": "batch",
    },
  )

  let timeRef = Hrtime.makeTimer()

  let eventBatchAndContext = await loadReadEntities(
    ~inMemoryStore,
    ~eventBatch,
    ~chainManager,
    ~logger,
  )

  let elapsedAfterLoad = timeRef->Hrtime.timeSince->Hrtime.toMillis->Hrtime.intFromMillis

  await eventBatchAndContext->Belt.Array.reduce(Promise.resolve(), async (
    previousPromise,
    event,
  ) => {
    await previousPromise
    await Promise.make((resolve, _reject) =>
      event->eventRouter(~inMemoryStore, ~cb={() => resolve(. ())})
    )
  })

  let elapsedTimeAfterProcess = timeRef->Hrtime.timeSince->Hrtime.toMillis->Hrtime.intFromMillis
  await DbFunctions.sql->IO.executeBatch(~inMemoryStore)

  let elapsedTimeAfterDbWrite = timeRef->Hrtime.timeSince->Hrtime.toMillis->Hrtime.intFromMillis

  registerProcessEventBatchMetrics(
    ~logger,
    ~batchSize=eventBatch->Array.length,
    ~loadDuration=elapsedAfterLoad,
    ~handlerDuration=elapsedTimeAfterProcess - elapsedAfterLoad,
    ~dbWriteDuration=elapsedTimeAfterDbWrite - elapsedTimeAfterProcess,
  )
}

let startProcessingEventsOnQueue = async (~chainManager: ChainManager.t): unit => {
  while true {
    let nextBatch =
      await chainManager->ChainManager.createBatch(
        ~minBatchSize=1,
        ~maxBatchSize=Env.maxProcessBatchSize,
      )

    let inMemoryStore = IO.InMemoryStore.make()
    await processEventBatch(~eventBatch=nextBatch, ~inMemoryStore, ~chainManager)
  }
}
