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
        getAsset: async id =>
          mockDbClone.entities.asset.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getBatch: async id =>
          mockDbClone.entities.batch.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getBatcher: async id =>
          mockDbClone.entities.batcher.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getContract: async id =>
          mockDbClone.entities.contract.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getSegment: async id =>
          mockDbClone.entities.segment.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getStream: async id =>
          mockDbClone.entities.stream.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
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

module LockupV20 = {
  module Approval = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.ApprovalEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.Approval.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_ApprovalWithContext,
      ~eventName=Types.LockupV20_Approval,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.ApprovalEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.Approval.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_ApprovalWithContext,
      ~eventName=Types.LockupV20_Approval,
    )

    @genType
    type createMockArgs = {
      owner?: Ethers.ethAddress,
      approved?: Ethers.ethAddress,
      tokenId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?owner, ?approved, ?tokenId, ?mockEventData} = args

      let params: Types.LockupV20Contract.ApprovalEvent.eventArgs = {
        owner: owner->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        approved: approved->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        tokenId: tokenId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module ApprovalForAll = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.ApprovalForAllEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.ApprovalForAll.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_ApprovalForAllWithContext,
      ~eventName=Types.LockupV20_ApprovalForAll,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.ApprovalForAllEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.ApprovalForAll.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_ApprovalForAllWithContext,
      ~eventName=Types.LockupV20_ApprovalForAll,
    )

    @genType
    type createMockArgs = {
      owner?: Ethers.ethAddress,
      operator?: Ethers.ethAddress,
      approved?: bool,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?owner, ?operator, ?approved, ?mockEventData} = args

      let params: Types.LockupV20Contract.ApprovalForAllEvent.eventArgs = {
        owner: owner->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        operator: operator->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        approved: approved->Belt.Option.getWithDefault(false),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module CancelLockupStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.CancelLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.CancelLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_CancelLockupStreamWithContext,
      ~eventName=Types.LockupV20_CancelLockupStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.CancelLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.CancelLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_CancelLockupStreamWithContext,
      ~eventName=Types.LockupV20_CancelLockupStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      sender?: Ethers.ethAddress,
      recipient?: Ethers.ethAddress,
      senderAmount?: Ethers.BigInt.t,
      recipientAmount?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?streamId, ?sender, ?recipient, ?senderAmount, ?recipientAmount, ?mockEventData} = args

      let params: Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        sender: sender->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        senderAmount: senderAmount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        recipientAmount: recipientAmount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module CreateLockupLinearStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.CreateLockupLinearStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.CreateLockupLinearStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_CreateLockupLinearStreamWithContext,
      ~eventName=Types.LockupV20_CreateLockupLinearStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.CreateLockupLinearStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.CreateLockupLinearStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_CreateLockupLinearStreamWithContext,
      ~eventName=Types.LockupV20_CreateLockupLinearStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      funder?: Ethers.ethAddress,
      sender?: Ethers.ethAddress,
      recipient?: Ethers.ethAddress,
      amounts?: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset?: Ethers.ethAddress,
      cancelable?: bool,
      range?: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      broker?: Ethers.ethAddress,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?streamId,
        ?funder,
        ?sender,
        ?recipient,
        ?amounts,
        ?asset,
        ?cancelable,
        ?range,
        ?broker,
        ?mockEventData,
      } = args

      let params: Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        funder: funder->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        sender: sender->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amounts: amounts->Belt.Option.getWithDefault((
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
        )),
        asset: asset->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        cancelable: cancelable->Belt.Option.getWithDefault(false),
        range: range->Belt.Option.getWithDefault((
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
        )),
        broker: broker->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module CreateLockupDynamicStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.CreateLockupDynamicStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.CreateLockupDynamicStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_CreateLockupDynamicStreamWithContext,
      ~eventName=Types.LockupV20_CreateLockupDynamicStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.CreateLockupDynamicStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.CreateLockupDynamicStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_CreateLockupDynamicStreamWithContext,
      ~eventName=Types.LockupV20_CreateLockupDynamicStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      funder?: Ethers.ethAddress,
      sender?: Ethers.ethAddress,
      recipient?: Ethers.ethAddress,
      amounts?: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset?: Ethers.ethAddress,
      cancelable?: bool,
      segments?: array<(Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t)>,
      range?: (Ethers.BigInt.t, Ethers.BigInt.t),
      broker?: Ethers.ethAddress,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?streamId,
        ?funder,
        ?sender,
        ?recipient,
        ?amounts,
        ?asset,
        ?cancelable,
        ?segments,
        ?range,
        ?broker,
        ?mockEventData,
      } = args

      let params: Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        funder: funder->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        sender: sender->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amounts: amounts->Belt.Option.getWithDefault((
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
        )),
        asset: asset->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        cancelable: cancelable->Belt.Option.getWithDefault(false),
        segments: segments->Belt.Option.getWithDefault([]),
        range: range->Belt.Option.getWithDefault((Ethers.BigInt.zero, Ethers.BigInt.zero)),
        broker: broker->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module RenounceLockupStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.RenounceLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.RenounceLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_RenounceLockupStreamWithContext,
      ~eventName=Types.LockupV20_RenounceLockupStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.RenounceLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.RenounceLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_RenounceLockupStreamWithContext,
      ~eventName=Types.LockupV20_RenounceLockupStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?streamId, ?mockEventData} = args

      let params: Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module Transfer = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.TransferEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.Transfer.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_TransferWithContext,
      ~eventName=Types.LockupV20_Transfer,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.TransferEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.Transfer.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_TransferWithContext,
      ~eventName=Types.LockupV20_Transfer,
    )

    @genType
    type createMockArgs = {
      from?: Ethers.ethAddress,
      to?: Ethers.ethAddress,
      tokenId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?from, ?to, ?tokenId, ?mockEventData} = args

      let params: Types.LockupV20Contract.TransferEvent.eventArgs = {
        from: from->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        to: to->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        tokenId: tokenId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module TransferAdmin = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.TransferAdminEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.TransferAdmin.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_TransferAdminWithContext,
      ~eventName=Types.LockupV20_TransferAdmin,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.TransferAdminEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.TransferAdmin.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_TransferAdminWithContext,
      ~eventName=Types.LockupV20_TransferAdmin,
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

      let params: Types.LockupV20Contract.TransferAdminEvent.eventArgs = {
        oldAdmin: oldAdmin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        newAdmin: newAdmin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module WithdrawFromLockupStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.WithdrawFromLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.WithdrawFromLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_WithdrawFromLockupStreamWithContext,
      ~eventName=Types.LockupV20_WithdrawFromLockupStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV20Contract.WithdrawFromLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV20Contract.WithdrawFromLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV20Contract_WithdrawFromLockupStreamWithContext,
      ~eventName=Types.LockupV20_WithdrawFromLockupStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      to?: Ethers.ethAddress,
      amount?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?streamId, ?to, ?amount, ?mockEventData} = args

      let params: Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        to: to->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amount: amount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }
}

module LockupV21 = {
  module Approval = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.ApprovalEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.Approval.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_ApprovalWithContext,
      ~eventName=Types.LockupV21_Approval,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.ApprovalEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.Approval.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_ApprovalWithContext,
      ~eventName=Types.LockupV21_Approval,
    )

    @genType
    type createMockArgs = {
      owner?: Ethers.ethAddress,
      approved?: Ethers.ethAddress,
      tokenId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?owner, ?approved, ?tokenId, ?mockEventData} = args

      let params: Types.LockupV21Contract.ApprovalEvent.eventArgs = {
        owner: owner->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        approved: approved->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        tokenId: tokenId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module ApprovalForAll = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.ApprovalForAllEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.ApprovalForAll.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_ApprovalForAllWithContext,
      ~eventName=Types.LockupV21_ApprovalForAll,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.ApprovalForAllEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.ApprovalForAll.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_ApprovalForAllWithContext,
      ~eventName=Types.LockupV21_ApprovalForAll,
    )

    @genType
    type createMockArgs = {
      owner?: Ethers.ethAddress,
      operator?: Ethers.ethAddress,
      approved?: bool,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?owner, ?operator, ?approved, ?mockEventData} = args

      let params: Types.LockupV21Contract.ApprovalForAllEvent.eventArgs = {
        owner: owner->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        operator: operator->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        approved: approved->Belt.Option.getWithDefault(false),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module CancelLockupStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.CancelLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.CancelLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_CancelLockupStreamWithContext,
      ~eventName=Types.LockupV21_CancelLockupStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.CancelLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.CancelLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_CancelLockupStreamWithContext,
      ~eventName=Types.LockupV21_CancelLockupStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      sender?: Ethers.ethAddress,
      recipient?: Ethers.ethAddress,
      asset?: Ethers.ethAddress,
      senderAmount?: Ethers.BigInt.t,
      recipientAmount?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?streamId,
        ?sender,
        ?recipient,
        ?asset,
        ?senderAmount,
        ?recipientAmount,
        ?mockEventData,
      } = args

      let params: Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        sender: sender->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        asset: asset->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        senderAmount: senderAmount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        recipientAmount: recipientAmount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module CreateLockupLinearStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.CreateLockupLinearStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.CreateLockupLinearStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_CreateLockupLinearStreamWithContext,
      ~eventName=Types.LockupV21_CreateLockupLinearStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.CreateLockupLinearStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.CreateLockupLinearStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_CreateLockupLinearStreamWithContext,
      ~eventName=Types.LockupV21_CreateLockupLinearStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      funder?: Ethers.ethAddress,
      sender?: Ethers.ethAddress,
      recipient?: Ethers.ethAddress,
      amounts?: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset?: Ethers.ethAddress,
      cancelable?: bool,
      transferable?: bool,
      range?: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      broker?: Ethers.ethAddress,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?streamId,
        ?funder,
        ?sender,
        ?recipient,
        ?amounts,
        ?asset,
        ?cancelable,
        ?transferable,
        ?range,
        ?broker,
        ?mockEventData,
      } = args

      let params: Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        funder: funder->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        sender: sender->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amounts: amounts->Belt.Option.getWithDefault((
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
        )),
        asset: asset->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        cancelable: cancelable->Belt.Option.getWithDefault(false),
        transferable: transferable->Belt.Option.getWithDefault(false),
        range: range->Belt.Option.getWithDefault((
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
        )),
        broker: broker->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module CreateLockupDynamicStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.CreateLockupDynamicStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.CreateLockupDynamicStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_CreateLockupDynamicStreamWithContext,
      ~eventName=Types.LockupV21_CreateLockupDynamicStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.CreateLockupDynamicStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.CreateLockupDynamicStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_CreateLockupDynamicStreamWithContext,
      ~eventName=Types.LockupV21_CreateLockupDynamicStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      funder?: Ethers.ethAddress,
      sender?: Ethers.ethAddress,
      recipient?: Ethers.ethAddress,
      amounts?: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset?: Ethers.ethAddress,
      cancelable?: bool,
      transferable?: bool,
      segments?: array<(Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t)>,
      range?: (Ethers.BigInt.t, Ethers.BigInt.t),
      broker?: Ethers.ethAddress,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?streamId,
        ?funder,
        ?sender,
        ?recipient,
        ?amounts,
        ?asset,
        ?cancelable,
        ?transferable,
        ?segments,
        ?range,
        ?broker,
        ?mockEventData,
      } = args

      let params: Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        funder: funder->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        sender: sender->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amounts: amounts->Belt.Option.getWithDefault((
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
          Ethers.BigInt.zero,
        )),
        asset: asset->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        cancelable: cancelable->Belt.Option.getWithDefault(false),
        transferable: transferable->Belt.Option.getWithDefault(false),
        segments: segments->Belt.Option.getWithDefault([]),
        range: range->Belt.Option.getWithDefault((Ethers.BigInt.zero, Ethers.BigInt.zero)),
        broker: broker->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module RenounceLockupStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.RenounceLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.RenounceLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_RenounceLockupStreamWithContext,
      ~eventName=Types.LockupV21_RenounceLockupStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.RenounceLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.RenounceLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_RenounceLockupStreamWithContext,
      ~eventName=Types.LockupV21_RenounceLockupStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?streamId, ?mockEventData} = args

      let params: Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module Transfer = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.TransferEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.Transfer.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_TransferWithContext,
      ~eventName=Types.LockupV21_Transfer,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.TransferEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.Transfer.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_TransferWithContext,
      ~eventName=Types.LockupV21_Transfer,
    )

    @genType
    type createMockArgs = {
      from?: Ethers.ethAddress,
      to?: Ethers.ethAddress,
      tokenId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?from, ?to, ?tokenId, ?mockEventData} = args

      let params: Types.LockupV21Contract.TransferEvent.eventArgs = {
        from: from->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        to: to->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        tokenId: tokenId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module TransferAdmin = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.TransferAdminEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.TransferAdmin.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_TransferAdminWithContext,
      ~eventName=Types.LockupV21_TransferAdmin,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.TransferAdminEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.TransferAdmin.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_TransferAdminWithContext,
      ~eventName=Types.LockupV21_TransferAdmin,
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

      let params: Types.LockupV21Contract.TransferAdminEvent.eventArgs = {
        oldAdmin: oldAdmin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        newAdmin: newAdmin->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module WithdrawFromLockupStream = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.WithdrawFromLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.WithdrawFromLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_WithdrawFromLockupStreamWithContext,
      ~eventName=Types.LockupV21_WithdrawFromLockupStream,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.LockupV21Contract.WithdrawFromLockupStreamEvent.contextCreator,
      ~getLoader=Handlers.LockupV21Contract.WithdrawFromLockupStream.getLoader,
      ~eventWithContextAccessor=Context.lockupV21Contract_WithdrawFromLockupStreamWithContext,
      ~eventName=Types.LockupV21_WithdrawFromLockupStream,
    )

    @genType
    type createMockArgs = {
      streamId?: Ethers.BigInt.t,
      to?: Ethers.ethAddress,
      asset?: Ethers.ethAddress,
      amount?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?streamId, ?to, ?asset, ?amount, ?mockEventData} = args

      let params: Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs = {
        streamId: streamId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        to: to->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        asset: asset->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amount: amount->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }
}
