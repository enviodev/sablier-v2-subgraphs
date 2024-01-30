open Belt
RegisterHandlers.registerAllHandlers()

/***** TAKE NOTE ******
This is a hack to get genType to work!

In order for genType to produce recursive types, it needs to be at the 
root module of a file. If it's defined in a nested module it does not 
work. So all the MockDb types and internal functions are defined in TestHelpers_MockDb
and only public functions are recreated and exported from this module.

the following module:
```rescript
module MyModule = {
  @genType
  type rec a = {fieldB: b}
  @genType and b = {fieldA: a}
}
```

produces the following in ts:
```ts
// tslint:disable-next-line:interface-over-type-literal
export type MyModule_a = { readonly fieldB: b };

// tslint:disable-next-line:interface-over-type-literal
export type MyModule_b = { readonly fieldA: MyModule_a };
```

fieldB references type b which doesn't exist because it's defined
as MyModule_b
*/

module MockDb = {
  @genType
  let createMockDb = TestHelpers_MockDb.createMockDb
}

module EventFunctions = {
  //Note these are made into a record to make operate in the same way
  //for Res, JS and TS.

  /**
  The arguements that get passed to a "processEvent" helper function
  */
  @genType
  type eventProcessorArgs<'eventArgs> = {
    event: Types.eventLog<'eventArgs>,
    mockDb: TestHelpers_MockDb.t,
    chainId?: int,
  }

  /**
  The default chain ID to use (ethereum mainnet) if a user does not specify int the 
  eventProcessor helper
  */
  let \"DEFAULT_CHAIN_ID" = 1

  /**
  A function composer to help create individual processEvent functions
  */
  let makeEventProcessor = (
    ~contextCreator: Context.contextCreator<
      'eventArgs,
      'loaderContext,
      'handlerContextSync,
      'handlerContextAsync,
    >,
    ~getLoader,
    ~eventWithContextAccessor: (
      Types.eventLog<'eventArgs>,
      Context.genericContextCreatorFunctions<
        'loaderContext,
        'handlerContextSync,
        'handlerContextAsync,
      >,
    ) => Context.eventAndContext,
    ~eventName: Types.eventName,
    ~cb: TestHelpers_MockDb.t => unit,
  ) => {
    ({event, mockDb, ?chainId}) => {
      //The user can specify a chainId of an event or leave it off
      //and it will default to "DEFAULT_CHAIN_ID"
      let chainId = chainId->Option.getWithDefault(\"DEFAULT_CHAIN_ID")

      //Create an individual logging context for traceability
      let logger = Logging.createChild(
        ~params={
          "Context": `Test Processor for ${eventName
            ->Types.eventName_encode
            ->Js.Json.stringify} Event`,
          "Chain ID": chainId,
          "event": event,
        },
      )

      //Deep copy the data in mockDb, mutate the clone and return the clone
      //So no side effects occur here and state can be compared between process
      //steps
      let mockDbClone = mockDb->TestHelpers_MockDb.cloneMockDb

      let asyncGetters: Context.entityGetters = {
        getAction: async id =>
          mockDbClone.entities.action.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getActivity: async id =>
          mockDbClone.entities.activity.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getAsset: async id =>
          mockDbClone.entities.asset.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getCampaign: async id =>
          mockDbClone.entities.campaign.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getFactory: async id =>
          mockDbClone.entities.factory.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getWatcher: async id =>
          mockDbClone.entities.watcher.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
      }

      //Construct a new instance of an in memory store to run for the given event
      let inMemoryStore = IO.InMemoryStore.make()

      //Construct a context with the inMemory store for the given event to run
      //loaders and handlers
      let context = contextCreator(~event, ~inMemoryStore, ~chainId, ~logger, ~asyncGetters)

      let loaderContext = context.getLoaderContext()

      let loader = getLoader()

      //Run the loader, to get all the read values/contract registrations
      //into the context
      loader(~event, ~context=loaderContext)

      //Get all the entities are requested to be loaded from the mockDB
      let entityBatch = context.getEntitiesToLoad()

      //Load requested entities from the cloned mockDb into the inMemoryStore
      mockDbClone->TestHelpers_MockDb.loadEntitiesToInMemStore(~entityBatch, ~inMemoryStore)

      //Run the event and handler context through the eventRouter
      //With inMemoryStore
      let eventAndContext: Context.eventRouterEventAndContext = {
        chainId,
        event: eventWithContextAccessor(event, context),
      }

      eventAndContext->EventProcessing.eventRouter(~inMemoryStore, ~cb=() => {
        //Now that the processing is finished. Simulate writing a batch
        //(Although in this case a batch of 1 event only) to the cloned mockDb
        mockDbClone->TestHelpers_MockDb.writeFromMemoryStore(~inMemoryStore)

        //Return the cloned mock db
        cb(mockDbClone)
      })
    }
  }

  /**Creates a mock event processor, wrapping the callback in a Promise for async use*/
  let makeAsyncEventProcessor = (
    ~contextCreator,
    ~getLoader,
    ~eventWithContextAccessor,
    ~eventName,
    eventProcessorArgs,
  ) => {
    Promise.make((res, _rej) => {
      makeEventProcessor(
        ~contextCreator,
        ~getLoader,
        ~eventWithContextAccessor,
        ~eventName,
        ~cb=mockDb => res(. mockDb),
        eventProcessorArgs,
      )
    })
  }

  /**
  Creates a mock event processor, exposing the return of the callback in the return,
  raises an exception if the handler is async
  */
  let makeSyncEventProcessor = (
    ~contextCreator,
    ~getLoader,
    ~eventWithContextAccessor,
    ~eventName,
    eventProcessorArgs,
  ) => {
    //Dangerously set to None, nextMockDb will be set in the callback
    let nextMockDb = ref(None)
    makeEventProcessor(
      ~contextCreator,
      ~getLoader,
      ~eventWithContextAccessor,
      ~eventName,
      ~cb=mockDb => nextMockDb := Some(mockDb),
      eventProcessorArgs,
    )

    //The callback is called synchronously so nextMockDb should be set.
    //In the case it's not set it would mean that the user is using an async handler
    //in which case we want to error and alert the user.
    switch nextMockDb.contents {
    | Some(mockDb) => mockDb
    | None =>
      Js.Exn.raiseError(
        "processEvent failed because handler is not synchronous, please use processEventAsync instead",
      )
    }
  }

  /**
  Optional params for all additional data related to an eventLog
  */
  @genType
  type mockEventData = {
    blockNumber?: int,
    blockTimestamp?: int,
    blockHash?: string,
    chainId?: int,
    srcAddress?: Ethers.ethAddress,
    transactionHash?: string,
    transactionIndex?: int,
    logIndex?: int,
  }

  /**
  Applies optional paramters with defaults for all common eventLog field
  */
  let makeEventMocker = (
    ~params: 'eventParams,
    ~mockEventData: option<mockEventData>,
  ): Types.eventLog<'eventParams> => {
    let {
      ?blockNumber,
      ?blockTimestamp,
      ?blockHash,
      ?srcAddress,
      ?chainId,
      ?transactionHash,
      ?transactionIndex,
      ?logIndex,
    } =
      mockEventData->Belt.Option.getWithDefault({})

    {
      params,
      chainId: chainId->Belt.Option.getWithDefault(1),
      blockNumber: blockNumber->Belt.Option.getWithDefault(0),
      blockTimestamp: blockTimestamp->Belt.Option.getWithDefault(0),
      blockHash: blockHash->Belt.Option.getWithDefault(Ethers.Constants.zeroHash),
      srcAddress: srcAddress->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      transactionHash: transactionHash->Belt.Option.getWithDefault(Ethers.Constants.zeroHash),
      transactionIndex: transactionIndex->Belt.Option.getWithDefault(0),
      logIndex: logIndex->Belt.Option.getWithDefault(0),
    }
  }
}

module MerkleLLV21 = {
  module Claim = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.MerkleLLV21Contract.ClaimEvent.contextCreator,
      ~getLoader=Handlers.MerkleLLV21Contract.Claim.getLoader,
      ~eventWithContextAccessor=Context.merkleLLV21Contract_ClaimWithContext,
      ~eventName=Types.MerkleLLV21_Claim,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.MerkleLLV21Contract.ClaimEvent.contextCreator,
      ~getLoader=Handlers.MerkleLLV21Contract.Claim.getLoader,
      ~eventWithContextAccessor=Context.merkleLLV21Contract_ClaimWithContext,
      ~eventName=Types.MerkleLLV21_Claim,
    )

    @genType
    type createMockArgs = {
      index?: Ethers.BigInt.t,
      recipient?: Ethers.ethAddress,
      amount?: Ethers.BigInt.t,
      streamId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?index, ?recipient, ?amount, ?streamId, ?mockEventData} = args

      let params: Types.MerkleLLV21Contract.ClaimEvent.eventArgs = {
        index: index->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amount: amount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module Clawback = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.MerkleLLV21Contract.ClawbackEvent.contextCreator,
      ~getLoader=Handlers.MerkleLLV21Contract.Clawback.getLoader,
      ~eventWithContextAccessor=Context.merkleLLV21Contract_ClawbackWithContext,
      ~eventName=Types.MerkleLLV21_Clawback,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.MerkleLLV21Contract.ClawbackEvent.contextCreator,
      ~getLoader=Handlers.MerkleLLV21Contract.Clawback.getLoader,
      ~eventWithContextAccessor=Context.merkleLLV21Contract_ClawbackWithContext,
      ~eventName=Types.MerkleLLV21_Clawback,
    )

    @genType
    type createMockArgs = {
      admin?: Ethers.ethAddress,
      to?: Ethers.ethAddress,
      amount?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?admin, ?to, ?amount, ?mockEventData} = args

      let params: Types.MerkleLLV21Contract.ClawbackEvent.eventArgs = {
        admin: admin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        to: to->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amount: amount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module TransferAdmin = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.MerkleLLV21Contract.TransferAdminEvent.contextCreator,
      ~getLoader=Handlers.MerkleLLV21Contract.TransferAdmin.getLoader,
      ~eventWithContextAccessor=Context.merkleLLV21Contract_TransferAdminWithContext,
      ~eventName=Types.MerkleLLV21_TransferAdmin,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.MerkleLLV21Contract.TransferAdminEvent.contextCreator,
      ~getLoader=Handlers.MerkleLLV21Contract.TransferAdmin.getLoader,
      ~eventWithContextAccessor=Context.merkleLLV21Contract_TransferAdminWithContext,
      ~eventName=Types.MerkleLLV21_TransferAdmin,
    )

    @genType
    type createMockArgs = {
      oldAdmin?: Ethers.ethAddress,
      newAdmin?: Ethers.ethAddress,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?oldAdmin, ?newAdmin, ?mockEventData} = args

      let params: Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs = {
        oldAdmin: oldAdmin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        newAdmin: newAdmin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }
}

module MerkleLockupFactoryV21 = {
  module CreateMerkleStreamerLL = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.contextCreator,
      ~getLoader=Handlers.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLL.getLoader,
      ~eventWithContextAccessor=Context.merkleLockupFactoryV21Contract_CreateMerkleStreamerLLWithContext,
      ~eventName=Types.MerkleLockupFactoryV21_CreateMerkleStreamerLL,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.contextCreator,
      ~getLoader=Handlers.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLL.getLoader,
      ~eventWithContextAccessor=Context.merkleLockupFactoryV21Contract_CreateMerkleStreamerLLWithContext,
      ~eventName=Types.MerkleLockupFactoryV21_CreateMerkleStreamerLL,
    )

    @genType
    type createMockArgs = {
      merkleStreamer?: Ethers.ethAddress,
      admin?: Ethers.ethAddress,
      lockupLinear?: Ethers.ethAddress,
      asset?: Ethers.ethAddress,
      merkleRoot?: string,
      expiration?: Ethers.BigInt.t,
      streamDurations?: (Ethers.BigInt.t, Ethers.BigInt.t),
      cancelable?: bool,
      transferable?: bool,
      ipfsCID?: string,
      aggregateAmount?: Ethers.BigInt.t,
      recipientsCount?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?merkleStreamer,
        ?admin,
        ?lockupLinear,
        ?asset,
        ?merkleRoot,
        ?expiration,
        ?streamDurations,
        ?cancelable,
        ?transferable,
        ?ipfsCID,
        ?aggregateAmount,
        ?recipientsCount,
        ?mockEventData,
      } = args

      let params: Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs = {
        merkleStreamer: merkleStreamer->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        admin: admin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        lockupLinear: lockupLinear->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        asset: asset->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        merkleRoot: merkleRoot->Belt.Option.getWithDefault("foo"),
        expiration: expiration->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        streamDurations: streamDurations->Belt.Option.getWithDefault((
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
        )),
        cancelable: cancelable->Belt.Option.getWithDefault(false),
        transferable: transferable->Belt.Option.getWithDefault(false),
        ipfsCID: ipfsCID->Belt.Option.getWithDefault("foo"),
        aggregateAmount: aggregateAmount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        recipientsCount: recipientsCount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }
}
