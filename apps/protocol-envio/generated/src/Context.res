type entityGetters = {
  getAction: Types.id => promise<array<Types.actionEntity>>,
  getAsset: Types.id => promise<array<Types.assetEntity>>,
  getBatch: Types.id => promise<array<Types.batchEntity>>,
  getBatcher: Types.id => promise<array<Types.batcherEntity>>,
  getContract: Types.id => promise<array<Types.contractEntity>>,
  getSegment: Types.id => promise<array<Types.segmentEntity>>,
  getStream: Types.id => promise<array<Types.streamEntity>>,
  getWatcher: Types.id => promise<array<Types.watcherEntity>>,
}

@genType
type genericContextCreatorFunctions<'loaderContext, 'handlerContextSync, 'handlerContextAsync> = {
  log: Logs.userLogger,
  getLoaderContext: unit => 'loaderContext,
  getHandlerContextSync: unit => 'handlerContextSync,
  getHandlerContextAsync: unit => 'handlerContextAsync,
  getEntitiesToLoad: unit => array<Types.entityRead>,
  getAddedDynamicContractRegistrations: unit => array<Types.dynamicContractRegistryEntity>,
}

type contextCreator<'eventArgs, 'loaderContext, 'handlerContext, 'handlerContextAsync> = (
  ~inMemoryStore: IO.InMemoryStore.t,
  ~chainId: int,
  ~event: Types.eventLog<'eventArgs>,
  ~logger: Pino.t,
  ~asyncGetters: entityGetters,
) => genericContextCreatorFunctions<'loaderContext, 'handlerContext, 'handlerContextAsync>

exception UnableToLoadNonNullableLinkedEntity(string)
exception LinkedEntityNotAvailableInSyncHandler(string)

module LockupV20Contract = {
  module ApprovalEvent = {
    type loaderContext = Types.LockupV20Contract.ApprovalEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.ApprovalEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.ApprovalEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.ApprovalEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.Approval",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module ApprovalForAllEvent = {
    type loaderContext = Types.LockupV20Contract.ApprovalForAllEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.ApprovalForAllEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.ApprovalForAllEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.ApprovalForAllEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.ApprovalForAll",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module CancelLockupStreamEvent = {
    type loaderContext = Types.LockupV20Contract.CancelLockupStreamEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.CancelLockupStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.CancelLockupStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.CancelLockupStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module CreateLockupLinearStreamEvent = {
    type loaderContext = Types.LockupV20Contract.CreateLockupLinearStreamEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.CreateLockupLinearStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.CreateLockupLinearStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.CreateLockupLinearStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_asset: Set.t<Types.id> = Set.make()
      let optSetOfIds_batch: Set.t<Types.id> = Set.make()
      let optSetOfIds_batcher: Set.t<Types.id> = Set.make()
      let optSetOfIds_contract: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        asset: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_asset->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.AssetRead(id))
          },
        },
        batch: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_batch->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatchRead(id, loaders))
          },
        },
        batcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_batcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatcherRead(id))
          },
        },
        contract: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_contract->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.ContractRead(id))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Asset" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.asset.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batch" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batch.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Contract" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.contract.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.asset->IO.InMemoryStore.Asset.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getAsset(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Asset.set(
                      inMemoryStore.asset,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batch->IO.InMemoryStore.Batch.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatch(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batch.set(
                      inMemoryStore.batch,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.contract->IO.InMemoryStore.Contract.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getContract(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Contract.set(
                      inMemoryStore.contract,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module CreateLockupDynamicStreamEvent = {
    type loaderContext = Types.LockupV20Contract.CreateLockupDynamicStreamEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.CreateLockupDynamicStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.CreateLockupDynamicStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.CreateLockupDynamicStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_asset: Set.t<Types.id> = Set.make()
      let optSetOfIds_batch: Set.t<Types.id> = Set.make()
      let optSetOfIds_batcher: Set.t<Types.id> = Set.make()
      let optSetOfIds_contract: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        asset: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_asset->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.AssetRead(id))
          },
        },
        batch: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_batch->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatchRead(id, loaders))
          },
        },
        batcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_batcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatcherRead(id))
          },
        },
        contract: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_contract->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.ContractRead(id))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Asset" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.asset.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batch" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batch.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Contract" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.contract.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.asset->IO.InMemoryStore.Asset.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getAsset(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Asset.set(
                      inMemoryStore.asset,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batch->IO.InMemoryStore.Batch.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatch(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batch.set(
                      inMemoryStore.batch,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.contract->IO.InMemoryStore.Contract.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getContract(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Contract.set(
                      inMemoryStore.contract,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module RenounceLockupStreamEvent = {
    type loaderContext = Types.LockupV20Contract.RenounceLockupStreamEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.RenounceLockupStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.RenounceLockupStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.RenounceLockupStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module TransferEvent = {
    type loaderContext = Types.LockupV20Contract.TransferEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.TransferEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.TransferEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.TransferEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.Transfer",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module TransferAdminEvent = {
    type loaderContext = Types.LockupV20Contract.TransferAdminEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.TransferAdminEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.TransferAdminEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.TransferAdminEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.TransferAdmin",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_contract: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        contract: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_contract->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.ContractRead(id))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Contract" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.contract.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.contract->IO.InMemoryStore.Contract.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getContract(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Contract.set(
                      inMemoryStore.contract,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module WithdrawFromLockupStreamEvent = {
    type loaderContext = Types.LockupV20Contract.WithdrawFromLockupStreamEvent.loaderContext
    type handlerContext = Types.LockupV20Contract.WithdrawFromLockupStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV20Contract.WithdrawFromLockupStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV20.WithdrawFromLockupStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }
}

module LockupV21Contract = {
  module ApprovalEvent = {
    type loaderContext = Types.LockupV21Contract.ApprovalEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.ApprovalEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.ApprovalEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.ApprovalEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.Approval",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module ApprovalForAllEvent = {
    type loaderContext = Types.LockupV21Contract.ApprovalForAllEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.ApprovalForAllEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.ApprovalForAllEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.ApprovalForAllEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.ApprovalForAll",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module CancelLockupStreamEvent = {
    type loaderContext = Types.LockupV21Contract.CancelLockupStreamEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.CancelLockupStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.CancelLockupStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.CancelLockupStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module CreateLockupLinearStreamEvent = {
    type loaderContext = Types.LockupV21Contract.CreateLockupLinearStreamEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.CreateLockupLinearStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.CreateLockupLinearStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.CreateLockupLinearStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_asset: Set.t<Types.id> = Set.make()
      let optSetOfIds_batch: Set.t<Types.id> = Set.make()
      let optSetOfIds_batcher: Set.t<Types.id> = Set.make()
      let optSetOfIds_contract: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        asset: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_asset->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.AssetRead(id))
          },
        },
        batch: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_batch->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatchRead(id, loaders))
          },
        },
        batcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_batcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatcherRead(id))
          },
        },
        contract: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_contract->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.ContractRead(id))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Asset" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.asset.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batch" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batch.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Contract" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.contract.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.asset->IO.InMemoryStore.Asset.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getAsset(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Asset.set(
                      inMemoryStore.asset,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batch->IO.InMemoryStore.Batch.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatch(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batch.set(
                      inMemoryStore.batch,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.contract->IO.InMemoryStore.Contract.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getContract(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Contract.set(
                      inMemoryStore.contract,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module CreateLockupDynamicStreamEvent = {
    type loaderContext = Types.LockupV21Contract.CreateLockupDynamicStreamEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.CreateLockupDynamicStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.CreateLockupDynamicStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.CreateLockupDynamicStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_asset: Set.t<Types.id> = Set.make()
      let optSetOfIds_batch: Set.t<Types.id> = Set.make()
      let optSetOfIds_batcher: Set.t<Types.id> = Set.make()
      let optSetOfIds_contract: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        asset: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_asset->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.AssetRead(id))
          },
        },
        batch: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_batch->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatchRead(id, loaders))
          },
        },
        batcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_batcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.BatcherRead(id))
          },
        },
        contract: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_contract->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.ContractRead(id))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Asset" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.asset.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batch" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batch.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Batcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.batcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Contract" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.contract.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_asset->Set.has(id) {
                inMemoryStore.asset->IO.InMemoryStore.Asset.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.asset->IO.InMemoryStore.Asset.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getAsset(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Asset.set(
                      inMemoryStore.asset,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batch->Set.has(id) {
                inMemoryStore.batch->IO.InMemoryStore.Batch.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batch->IO.InMemoryStore.Batch.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatch(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batch.set(
                      inMemoryStore.batch,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_batcher->Set.has(id) {
                inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getBatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.contract->IO.InMemoryStore.Contract.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getContract(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Contract.set(
                      inMemoryStore.contract,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module RenounceLockupStreamEvent = {
    type loaderContext = Types.LockupV21Contract.RenounceLockupStreamEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.RenounceLockupStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.RenounceLockupStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.RenounceLockupStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module TransferEvent = {
    type loaderContext = Types.LockupV21Contract.TransferEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.TransferEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.TransferEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.TransferEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.Transfer",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module TransferAdminEvent = {
    type loaderContext = Types.LockupV21Contract.TransferAdminEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.TransferAdminEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.TransferAdminEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.TransferAdminEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.TransferAdmin",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_contract: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        contract: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_contract->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.ContractRead(id))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Contract" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.contract.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_contract->Set.has(id) {
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.contract->IO.InMemoryStore.Contract.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getContract(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Contract.set(
                      inMemoryStore.contract,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module WithdrawFromLockupStreamEvent = {
    type loaderContext = Types.LockupV21Contract.WithdrawFromLockupStreamEvent.loaderContext
    type handlerContext = Types.LockupV21Contract.WithdrawFromLockupStreamEvent.handlerContext
    type handlerContextAsync = Types.LockupV21Contract.WithdrawFromLockupStreamEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "LockupV21.WithdrawFromLockupStream",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_stream: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addLockupV20: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV20",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addLockupV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "LockupV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        stream: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_stream->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.StreamRead(id, loaders))
          },
        },
        watcher: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_watcher->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.WatcherRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: action => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(action.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Action contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
            getStream: action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  Logging.warn(`Action stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Action is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  Logging.warn(`Batch batcher data not found. Loading associated batcher from database.
Please consider loading the batcher in the UpdateBatch entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Batch is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: segment => {
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(segment.stream)
              switch optStream {
              | Some(stream) => stream
              | None =>
                Logging.warn(`Segment stream data not found. Loading associated stream from database.
Please consider loading the stream in the UpdateSegment entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Segment is undefined.",
                  ),
                )
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Stream" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.stream.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: stream => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(stream.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Stream asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getContract: stream => {
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(stream.contract)
              switch optContract {
              | Some(contract) => contract
              | None =>
                Logging.warn(`Stream contract data not found. Loading associated contract from database.
Please consider loading the contract in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
            getCanceledAction: stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  Logging.warn(`Stream canceledAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getRenounceAction: stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  Logging.warn(`Stream renounceAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Stream is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
            getBatch: stream => {
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(stream.batch)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                Logging.warn(`Stream batch data not found. Loading associated batch from database.
Please consider loading the batch in the UpdateStream entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Stream is undefined.",
                  ),
                )
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Watcher" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.watcher.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          action: {
            set: entity => {
              inMemoryStore.action->IO.InMemoryStore.Action.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(action) with ID ${id}.`),
            getContract: async action => {
              let contract_field = action.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Action is undefined.",
                    ),
                  )
                }
              }
            },
            getStream: async action => {
              switch action.stream {
              | Some(stream_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)

                switch optStream {
                | Some(stream) => stream
                | None =>
                  let entities = await asyncGetters.getStream(stream_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Action stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity stream of Action is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          asset: {
            set: entity => {
              inMemoryStore.asset->IO.InMemoryStore.Asset.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(asset) with ID ${id}.`),
          },
          batch: {
            set: entity => {
              inMemoryStore.batch->IO.InMemoryStore.Batch.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batch) with ID ${id}.`),
            getBatcher: async batch => {
              switch batch.batcher {
              | Some(batcher_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optBatcher = inMemoryStore.batcher->IO.InMemoryStore.Batcher.get(batcher_field)

                switch optBatcher {
                | Some(batcher) => batcher
                | None =>
                  let entities = await asyncGetters.getBatcher(batcher_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Batcher.set(
                      inMemoryStore.batcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Batch batcher data not found. Loading associated batcher from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity batcher of Batch is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          batcher: {
            set: entity => {
              inMemoryStore.batcher->IO.InMemoryStore.Batcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(batcher) with ID ${id}.`),
          },
          contract: {
            set: entity => {
              inMemoryStore.contract->IO.InMemoryStore.Contract.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(contract) with ID ${id}.`),
          },
          segment: {
            set: entity => {
              inMemoryStore.segment->IO.InMemoryStore.Segment.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(segment) with ID ${id}.`),
            getStream: async segment => {
              let stream_field = segment.stream
              let optStream = inMemoryStore.stream->IO.InMemoryStore.Stream.get(stream_field)
              switch optStream {
              | Some(stream) => stream
              | None =>
                let entities = await asyncGetters.getStream(stream_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Stream.set(
                    inMemoryStore.stream,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Segment stream data not found. Loading associated stream from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity stream of Segment is undefined.",
                    ),
                  )
                }
              }
            },
          },
          stream: {
            set: entity => {
              inMemoryStore.stream->IO.InMemoryStore.Stream.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(stream) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_stream->Set.has(id) {
                inMemoryStore.stream->IO.InMemoryStore.Stream.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.stream->IO.InMemoryStore.Stream.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getStream(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Stream.set(
                      inMemoryStore.stream,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getAsset: async stream => {
              let asset_field = stream.asset
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(asset_field)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                let entities = await asyncGetters.getAsset(asset_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Asset.set(
                    inMemoryStore.asset,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getContract: async stream => {
              let contract_field = stream.contract
              let optContract =
                inMemoryStore.contract->IO.InMemoryStore.Contract.get(contract_field)
              switch optContract {
              | Some(contract) => contract
              | None =>
                let entities = await asyncGetters.getContract(contract_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Contract.set(
                    inMemoryStore.contract,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream contract data not found. Loading associated contract from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity contract of Stream is undefined.",
                    ),
                  )
                }
              }
            },
            getCanceledAction: async stream => {
              switch stream.canceledAction {
              | Some(canceledAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optCanceledAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(canceledAction_field)

                switch optCanceledAction {
                | Some(canceledAction) => canceledAction
                | None =>
                  let entities = await asyncGetters.getAction(canceledAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream canceledAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity canceledAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getRenounceAction: async stream => {
              switch stream.renounceAction {
              | Some(renounceAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optRenounceAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(renounceAction_field)

                switch optRenounceAction {
                | Some(renounceAction) => renounceAction
                | None =>
                  let entities = await asyncGetters.getAction(renounceAction_field)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Action.set(
                      inMemoryStore.action,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    entity
                  | None =>
                    Logging.error(`Stream renounceAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity renounceAction of Stream is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
            getBatch: async stream => {
              let batch_field = stream.batch
              let optBatch = inMemoryStore.batch->IO.InMemoryStore.Batch.get(batch_field)
              switch optBatch {
              | Some(batch) => batch
              | None =>
                let entities = await asyncGetters.getBatch(batch_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Batch.set(
                    inMemoryStore.batch,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Stream batch data not found. Loading associated batch from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity batch of Stream is undefined.",
                    ),
                  )
                }
              }
            },
          },
          watcher: {
            set: entity => {
              inMemoryStore.watcher->IO.InMemoryStore.Watcher.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(watcher) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_watcher->Set.has(id) {
                inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.watcher->IO.InMemoryStore.Watcher.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getWatcher(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Watcher.set(
                      inMemoryStore.watcher,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
        }
      }

      {
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }
}

@deriving(accessors)
type eventAndContext =
  | LockupV20Contract_ApprovalWithContext(
      Types.eventLog<Types.LockupV20Contract.ApprovalEvent.eventArgs>,
      LockupV20Contract.ApprovalEvent.context,
    )
  | LockupV20Contract_ApprovalForAllWithContext(
      Types.eventLog<Types.LockupV20Contract.ApprovalForAllEvent.eventArgs>,
      LockupV20Contract.ApprovalForAllEvent.context,
    )
  | LockupV20Contract_CancelLockupStreamWithContext(
      Types.eventLog<Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs>,
      LockupV20Contract.CancelLockupStreamEvent.context,
    )
  | LockupV20Contract_CreateLockupLinearStreamWithContext(
      Types.eventLog<Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs>,
      LockupV20Contract.CreateLockupLinearStreamEvent.context,
    )
  | LockupV20Contract_CreateLockupDynamicStreamWithContext(
      Types.eventLog<Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs>,
      LockupV20Contract.CreateLockupDynamicStreamEvent.context,
    )
  | LockupV20Contract_RenounceLockupStreamWithContext(
      Types.eventLog<Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs>,
      LockupV20Contract.RenounceLockupStreamEvent.context,
    )
  | LockupV20Contract_TransferWithContext(
      Types.eventLog<Types.LockupV20Contract.TransferEvent.eventArgs>,
      LockupV20Contract.TransferEvent.context,
    )
  | LockupV20Contract_TransferAdminWithContext(
      Types.eventLog<Types.LockupV20Contract.TransferAdminEvent.eventArgs>,
      LockupV20Contract.TransferAdminEvent.context,
    )
  | LockupV20Contract_WithdrawFromLockupStreamWithContext(
      Types.eventLog<Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs>,
      LockupV20Contract.WithdrawFromLockupStreamEvent.context,
    )
  | LockupV21Contract_ApprovalWithContext(
      Types.eventLog<Types.LockupV21Contract.ApprovalEvent.eventArgs>,
      LockupV21Contract.ApprovalEvent.context,
    )
  | LockupV21Contract_ApprovalForAllWithContext(
      Types.eventLog<Types.LockupV21Contract.ApprovalForAllEvent.eventArgs>,
      LockupV21Contract.ApprovalForAllEvent.context,
    )
  | LockupV21Contract_CancelLockupStreamWithContext(
      Types.eventLog<Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs>,
      LockupV21Contract.CancelLockupStreamEvent.context,
    )
  | LockupV21Contract_CreateLockupLinearStreamWithContext(
      Types.eventLog<Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs>,
      LockupV21Contract.CreateLockupLinearStreamEvent.context,
    )
  | LockupV21Contract_CreateLockupDynamicStreamWithContext(
      Types.eventLog<Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs>,
      LockupV21Contract.CreateLockupDynamicStreamEvent.context,
    )
  | LockupV21Contract_RenounceLockupStreamWithContext(
      Types.eventLog<Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs>,
      LockupV21Contract.RenounceLockupStreamEvent.context,
    )
  | LockupV21Contract_TransferWithContext(
      Types.eventLog<Types.LockupV21Contract.TransferEvent.eventArgs>,
      LockupV21Contract.TransferEvent.context,
    )
  | LockupV21Contract_TransferAdminWithContext(
      Types.eventLog<Types.LockupV21Contract.TransferAdminEvent.eventArgs>,
      LockupV21Contract.TransferAdminEvent.context,
    )
  | LockupV21Contract_WithdrawFromLockupStreamWithContext(
      Types.eventLog<Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs>,
      LockupV21Contract.WithdrawFromLockupStreamEvent.context,
    )

type eventRouterEventAndContext = {
  chainId: int,
  event: eventAndContext,
}
