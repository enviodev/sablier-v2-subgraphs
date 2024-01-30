module InMemoryStore = {
  let entityCurrentCrud = (currentCrud: option<Types.dbOp>, nextCrud: Types.dbOp): Types.dbOp => {
    switch (currentCrud, nextCrud) {
    | (Some(Set), Read)
    | (_, Set) =>
      Set
    | (Some(Read), Read) => Read
    | (Some(Delete), Read)
    | (_, Delete) =>
      Delete
    | (None, _) => nextCrud
    }
  }

  type stringHasher<'val> = 'val => string
  type storeState<'entity, 'entityKey> = {
    dict: Js.Dict.t<Types.inMemoryStoreRow<'entity>>,
    hasher: stringHasher<'entityKey>,
  }

  module type StoreItem = {
    type t
    type key
    let hasher: stringHasher<key>
  }

  //Binding used for deep cloning stores in tests
  @val external structuredClone: 'a => 'a = "structuredClone"

  module MakeStore = (StoreItem: StoreItem) => {
    @genType
    type value = StoreItem.t
    @genType
    type key = StoreItem.key
    type t = storeState<value, key>

    let make = (): t => {dict: Js.Dict.empty(), hasher: StoreItem.hasher}

    let set = (self: t, ~key: StoreItem.key, ~dbOp, ~entity: StoreItem.t) =>
      self.dict->Js.Dict.set(key->self.hasher, {entity, dbOp})

    let get = (self: t, key: StoreItem.key) =>
      self.dict->Js.Dict.get(key->self.hasher)->Belt.Option.map(row => row.entity)

    let values = (self: t) => self.dict->Js.Dict.values

    let clone = (self: t) => {
      ...self,
      dict: self.dict->structuredClone,
    }
  }

  module EventSyncState = MakeStore({
    type t = DbFunctions.EventSyncState.eventSyncState
    type key = int
    let hasher = Belt.Int.toString
  })

  @genType
  type rawEventsKey = {
    chainId: int,
    eventId: string,
  }

  module RawEvents = MakeStore({
    type t = Types.rawEventsEntity
    type key = rawEventsKey
    let hasher = (key: key) =>
      EventUtils.getEventIdKeyString(~chainId=key.chainId, ~eventId=key.eventId)
  })

  @genType
  type dynamicContractRegistryKey = {
    chainId: int,
    contractAddress: Ethers.ethAddress,
  }

  module DynamicContractRegistry = MakeStore({
    type t = Types.dynamicContractRegistryEntity
    type key = dynamicContractRegistryKey
    let hasher = ({chainId, contractAddress}) =>
      EventUtils.getContractAddressKeyString(~chainId, ~contractAddress)
  })

  module Action = MakeStore({
    type t = Types.actionEntity
    type key = string
    let hasher = Obj.magic
  })

  module Asset = MakeStore({
    type t = Types.assetEntity
    type key = string
    let hasher = Obj.magic
  })

  module Batch = MakeStore({
    type t = Types.batchEntity
    type key = string
    let hasher = Obj.magic
  })

  module Batcher = MakeStore({
    type t = Types.batcherEntity
    type key = string
    let hasher = Obj.magic
  })

  module Contract = MakeStore({
    type t = Types.contractEntity
    type key = string
    let hasher = Obj.magic
  })

  module Segment = MakeStore({
    type t = Types.segmentEntity
    type key = string
    let hasher = Obj.magic
  })

  module Stream = MakeStore({
    type t = Types.streamEntity
    type key = string
    let hasher = Obj.magic
  })

  module Watcher = MakeStore({
    type t = Types.watcherEntity
    type key = string
    let hasher = Obj.magic
  })

  @genType
  type t = {
    eventSyncState: EventSyncState.t,
    rawEvents: RawEvents.t,
    dynamicContractRegistry: DynamicContractRegistry.t,
    action: Action.t,
    asset: Asset.t,
    batch: Batch.t,
    batcher: Batcher.t,
    contract: Contract.t,
    segment: Segment.t,
    stream: Stream.t,
    watcher: Watcher.t,
  }

  let make = (): t => {
    eventSyncState: EventSyncState.make(),
    rawEvents: RawEvents.make(),
    dynamicContractRegistry: DynamicContractRegistry.make(),
    action: Action.make(),
    asset: Asset.make(),
    batch: Batch.make(),
    batcher: Batcher.make(),
    contract: Contract.make(),
    segment: Segment.make(),
    stream: Stream.make(),
    watcher: Watcher.make(),
  }

  let clone = (self: t) => {
    eventSyncState: self.eventSyncState->EventSyncState.clone,
    rawEvents: self.rawEvents->RawEvents.clone,
    dynamicContractRegistry: self.dynamicContractRegistry->DynamicContractRegistry.clone,
    action: self.action->Action.clone,
    asset: self.asset->Asset.clone,
    batch: self.batch->Batch.clone,
    batcher: self.batcher->Batcher.clone,
    contract: self.contract->Contract.clone,
    segment: self.segment->Segment.clone,
    stream: self.stream->Stream.clone,
    watcher: self.watcher->Watcher.clone,
  }
}

module LoadLayer = {
  /**The ids to load for a particular entity*/
  type idsToLoad = Belt.Set.String.t

  /**
  A round of entities to load from the DB. Depending on what entities come back
  and the dataLoaded "actions" that get run after the entities are loaded up. It
  could mean another load layer is created based of values that are returned
  */
  type rec t = {
    //A an array of getters to run after the entities with idsToLoad have been loaded
    dataLoadedActionsGetters: dataLoadedActionsGetters,
    //A unique list of ids that need to be loaded for entity action
    actionIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity asset
    assetIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity batch
    batchIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity batcher
    batcherIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity contract
    contractIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity segment
    segmentIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity stream
    streamIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity watcher
    watcherIdsToLoad: idsToLoad,
  }
  //An action that gets run after the data is loaded in from the db to the in memory store
  //the action will derive values from the loaded data and update the next load layer
  and dataLoadedAction = t => t
  //A getter function that returns an array of actions that need to be run
  //Actions will fetch values from the in memory store and update a load layer
  and dataLoadedActionsGetter = unit => array<dataLoadedAction>
  //An array of getter functions for dataLoadedActions
  and dataLoadedActionsGetters = array<dataLoadedActionsGetter>

  /**Instantiates a load layer*/
  let emptyLoadLayer = () => {
    actionIdsToLoad: Belt.Set.String.empty,
    assetIdsToLoad: Belt.Set.String.empty,
    batchIdsToLoad: Belt.Set.String.empty,
    batcherIdsToLoad: Belt.Set.String.empty,
    contractIdsToLoad: Belt.Set.String.empty,
    segmentIdsToLoad: Belt.Set.String.empty,
    streamIdsToLoad: Belt.Set.String.empty,
    watcherIdsToLoad: Belt.Set.String.empty,
    dataLoadedActionsGetters: [],
  }

  /* Helper to append an ID to load for a given entity to the loadLayer */
  let extendIdsToLoad = (idsToLoad: idsToLoad, entityId: Types.id): idsToLoad =>
    idsToLoad->Belt.Set.String.add(entityId)

  /* Helper to append a getter for DataLoadedActions to load for a given entity to the loadLayer */
  let extendDataLoadedActionsGetters = (
    dataLoadedActionsGetters: dataLoadedActionsGetters,
    newDataLoadedActionsGetters: dataLoadedActionsGetters,
  ): dataLoadedActionsGetters =>
    dataLoadedActionsGetters->Belt.Array.concat(newDataLoadedActionsGetters)
}

//remove warning 39 for unused "rec" flag in case of no other related loaders
/**
Loader functions for each entity. The loader function extends a load layer with the given id and config.
*/
@warning("-39")
let rec actionLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~actionLoaderConfig: Types.actionLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    actionLoaderConfig.loadContract->Belt.Option.map(contractLoaderConfig => {
      () =>
        inMemoryStore.action
        ->InMemoryStore.Action.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            contractLinkedEntityLoader(~contractLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.contract is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.contract->getLoader]
        })
    }),
    actionLoaderConfig.loadStream->Belt.Option.map(streamLoaderConfig => {
      () =>
        inMemoryStore.action
        ->InMemoryStore.Action.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            streamLinkedEntityLoader(~streamLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.stream is an optional single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          entity.stream->Belt.Option.mapWithDefault([], entityId => [entityId->getLoader])
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    actionIdsToLoad: loadLayer.actionIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and assetLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~assetLoaderConfig: Types.assetLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "assetLoaderConfig" type is a boolean.
  if !assetLoaderConfig {
    //If assetLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If assetLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      assetIdsToLoad: loadLayer.assetIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}
@warning("-27")
and batchLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~batchLoaderConfig: Types.batchLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    batchLoaderConfig.loadBatcher->Belt.Option.map(batcherLoaderConfig => {
      () =>
        inMemoryStore.batch
        ->InMemoryStore.Batch.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            batcherLinkedEntityLoader(~batcherLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.batcher is an optional single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          entity.batcher->Belt.Option.mapWithDefault([], entityId => [entityId->getLoader])
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    batchIdsToLoad: loadLayer.batchIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and batcherLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~batcherLoaderConfig: Types.batcherLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "batcherLoaderConfig" type is a boolean.
  if !batcherLoaderConfig {
    //If batcherLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If batcherLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      batcherIdsToLoad: loadLayer.batcherIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}
@warning("-27")
and contractLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~contractLoaderConfig: Types.contractLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "contractLoaderConfig" type is a boolean.
  if !contractLoaderConfig {
    //If contractLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If contractLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      contractIdsToLoad: loadLayer.contractIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}
@warning("-27")
and segmentLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~segmentLoaderConfig: Types.segmentLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    segmentLoaderConfig.loadStream->Belt.Option.map(streamLoaderConfig => {
      () =>
        inMemoryStore.segment
        ->InMemoryStore.Segment.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            streamLinkedEntityLoader(~streamLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.stream is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.stream->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    segmentIdsToLoad: loadLayer.segmentIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and streamLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~streamLoaderConfig: Types.streamLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    streamLoaderConfig.loadAsset->Belt.Option.map(assetLoaderConfig => {
      () =>
        inMemoryStore.stream
        ->InMemoryStore.Stream.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            assetLinkedEntityLoader(~assetLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.asset is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.asset->getLoader]
        })
    }),
    streamLoaderConfig.loadContract->Belt.Option.map(contractLoaderConfig => {
      () =>
        inMemoryStore.stream
        ->InMemoryStore.Stream.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            contractLinkedEntityLoader(~contractLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.contract is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.contract->getLoader]
        })
    }),
    streamLoaderConfig.loadCanceledAction->Belt.Option.map(actionLoaderConfig => {
      () =>
        inMemoryStore.stream
        ->InMemoryStore.Stream.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            actionLinkedEntityLoader(~actionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.canceledAction is an optional single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          entity.canceledAction->Belt.Option.mapWithDefault([], entityId => [entityId->getLoader])
        })
    }),
    streamLoaderConfig.loadRenounceAction->Belt.Option.map(actionLoaderConfig => {
      () =>
        inMemoryStore.stream
        ->InMemoryStore.Stream.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            actionLinkedEntityLoader(~actionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.renounceAction is an optional single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          entity.renounceAction->Belt.Option.mapWithDefault([], entityId => [entityId->getLoader])
        })
    }),
    streamLoaderConfig.loadBatch->Belt.Option.map(batchLoaderConfig => {
      () =>
        inMemoryStore.stream
        ->InMemoryStore.Stream.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            batchLinkedEntityLoader(~batchLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.batch is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.batch->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    streamIdsToLoad: loadLayer.streamIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and watcherLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~watcherLoaderConfig: Types.watcherLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "watcherLoaderConfig" type is a boolean.
  if !watcherLoaderConfig {
    //If watcherLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If watcherLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      watcherIdsToLoad: loadLayer.watcherIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}

/**
Creates and populates a load layer with the current in memory store and an array of entityRead variants
*/
let getLoadLayer = (~entityBatch: array<Types.entityRead>, ~inMemoryStore) => {
  entityBatch->Belt.Array.reduce(LoadLayer.emptyLoadLayer(), (loadLayer, readEntity) => {
    switch readEntity {
    | ActionRead(entityId, actionLoaderConfig) =>
      loadLayer->actionLinkedEntityLoader(~entityId, ~inMemoryStore, ~actionLoaderConfig)
    | AssetRead(entityId) =>
      loadLayer->assetLinkedEntityLoader(~entityId, ~inMemoryStore, ~assetLoaderConfig=true)
    | BatchRead(entityId, batchLoaderConfig) =>
      loadLayer->batchLinkedEntityLoader(~entityId, ~inMemoryStore, ~batchLoaderConfig)
    | BatcherRead(entityId) =>
      loadLayer->batcherLinkedEntityLoader(~entityId, ~inMemoryStore, ~batcherLoaderConfig=true)
    | ContractRead(entityId) =>
      loadLayer->contractLinkedEntityLoader(~entityId, ~inMemoryStore, ~contractLoaderConfig=true)
    | SegmentRead(entityId, segmentLoaderConfig) =>
      loadLayer->segmentLinkedEntityLoader(~entityId, ~inMemoryStore, ~segmentLoaderConfig)
    | StreamRead(entityId, streamLoaderConfig) =>
      loadLayer->streamLinkedEntityLoader(~entityId, ~inMemoryStore, ~streamLoaderConfig)
    | WatcherRead(entityId) =>
      loadLayer->watcherLinkedEntityLoader(~entityId, ~inMemoryStore, ~watcherLoaderConfig=true)
    }
  })
}

/**
Represents whether a deeper layer needs to be executed or whether the last layer
has been executed
*/
type nextLayer = NextLayer(LoadLayer.t) | LastLayer

let getNextLayer = (~loadLayer: LoadLayer.t) =>
  switch loadLayer.dataLoadedActionsGetters {
  | [] => LastLayer
  | dataLoadedActionsGetters =>
    dataLoadedActionsGetters
    ->Belt.Array.reduce(LoadLayer.emptyLoadLayer(), (loadLayer, getLoadedActions) => {
      //call getLoadedActions returns array of of actions to run against the load layer
      getLoadedActions()->Belt.Array.reduce(loadLayer, (loadLayer, action) => {
        action(loadLayer)
      })
    })
    ->NextLayer
  }

/**
Used for composing a loadlayer executor
*/
type entityExecutor<'executorRes> = {
  idsToLoad: LoadLayer.idsToLoad,
  executor: LoadLayer.idsToLoad => 'executorRes,
}

/**
Compose an execute load layer function. Used to compose an executor
for a postgres db or a mock db in the testing framework.
*/
let executeLoadLayerComposer = (
  ~entityExecutors: array<entityExecutor<'exectuorRes>>,
  ~handleResponses: array<'exectuorRes> => 'nextLoadlayer,
) => {
  entityExecutors
  ->Belt.Array.map(({idsToLoad, executor}) => {
    idsToLoad->executor
  })
  ->handleResponses
}

/**Recursively load layers with execute fn composer. Can be used with async or sync functions*/
let rec executeNestedLoadLayersComposer = (
  ~loadLayer,
  ~inMemoryStore,
  //Could be an execution function that is async or sync
  ~executeLoadLayerFn,
  //A call back function, for async or sync
  ~then,
  //Unit value, either wrapped in a promise or not
  ~unit,
) => {
  executeLoadLayerFn(~loadLayer, ~inMemoryStore)->then(res =>
    switch res {
    | LastLayer => unit
    | NextLayer(loadLayer) =>
      executeNestedLoadLayersComposer(~loadLayer, ~inMemoryStore, ~executeLoadLayerFn, ~then, ~unit)
    }
  )
}

/**Load all entities in the entity batch from the db to the inMemoryStore */
let loadEntitiesToInMemStoreComposer = (
  ~entityBatch,
  ~inMemoryStore,
  ~executeLoadLayerFn,
  ~then,
  ~unit,
) => {
  executeNestedLoadLayersComposer(
    ~inMemoryStore,
    ~loadLayer=getLoadLayer(~inMemoryStore, ~entityBatch),
    ~executeLoadLayerFn,
    ~then,
    ~unit,
  )
}

let makeEntityExecuterComposer = (
  ~idsToLoad,
  ~dbReadFn,
  ~inMemStoreSetFn,
  ~store,
  ~getEntiyId,
  ~unit,
  ~then,
) => {
  idsToLoad,
  executor: idsToLoad => {
    switch idsToLoad->Belt.Set.String.toArray {
    | [] => unit //Check if there are values so we don't create an unnecessary empty query
    | idsToLoad =>
      idsToLoad
      ->dbReadFn
      ->then(entities =>
        entities->Belt.Array.forEach(entity => {
          store->inMemStoreSetFn(~key=entity->getEntiyId, ~dbOp=Types.Read, ~entity)
        })
      )
    }
  },
}

/**
Specifically create an sql executor with async functionality
*/
let makeSqlEntityExecuter = (~idsToLoad, ~dbReadFn, ~inMemStoreSetFn, ~store, ~getEntiyId) => {
  makeEntityExecuterComposer(
    ~dbReadFn=DbFunctions.sql->dbReadFn,
    ~idsToLoad,
    ~getEntiyId,
    ~store,
    ~inMemStoreSetFn,
    ~then=Promise.thenResolve,
    ~unit=Promise.resolve(),
  )
}

/**
Executes a single load layer using the async sql functions
*/
let executeSqlLoadLayer = (~loadLayer: LoadLayer.t, ~inMemoryStore: InMemoryStore.t) => {
  let entityExecutors = [
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.actionIdsToLoad,
      ~dbReadFn=DbFunctions.Action.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Action.set,
      ~store=inMemoryStore.action,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.assetIdsToLoad,
      ~dbReadFn=DbFunctions.Asset.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Asset.set,
      ~store=inMemoryStore.asset,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.batchIdsToLoad,
      ~dbReadFn=DbFunctions.Batch.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Batch.set,
      ~store=inMemoryStore.batch,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.batcherIdsToLoad,
      ~dbReadFn=DbFunctions.Batcher.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Batcher.set,
      ~store=inMemoryStore.batcher,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.contractIdsToLoad,
      ~dbReadFn=DbFunctions.Contract.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Contract.set,
      ~store=inMemoryStore.contract,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.segmentIdsToLoad,
      ~dbReadFn=DbFunctions.Segment.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Segment.set,
      ~store=inMemoryStore.segment,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.streamIdsToLoad,
      ~dbReadFn=DbFunctions.Stream.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Stream.set,
      ~store=inMemoryStore.stream,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.watcherIdsToLoad,
      ~dbReadFn=DbFunctions.Watcher.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Watcher.set,
      ~store=inMemoryStore.watcher,
      ~getEntiyId=entity => entity.id,
    ),
  ]
  let handleResponses = responses => {
    responses
    ->Promise.all
    ->Promise.thenResolve(_ => {
      getNextLayer(~loadLayer)
    })
  }

  executeLoadLayerComposer(~entityExecutors, ~handleResponses)
}

/**Execute loading of entities using sql*/
let loadEntitiesToInMemStore = (~entityBatch, ~inMemoryStore) => {
  loadEntitiesToInMemStoreComposer(
    ~inMemoryStore,
    ~entityBatch,
    ~executeLoadLayerFn=executeSqlLoadLayer,
    ~then=Promise.then,
    ~unit=Promise.resolve(),
  )
}

let executeEntityFunction = (
  sql: Postgres.sql,
  ~rows: array<Types.inMemoryStoreRow<'a>>,
  ~dbOp: Types.dbOp,
  ~dbFunction: (Postgres.sql, array<'b>) => promise<unit>,
  ~getInputValFromRow: Types.inMemoryStoreRow<'a> => 'b,
) => {
  let entityIds =
    rows->Belt.Array.keepMap(row => row.dbOp == dbOp ? Some(row->getInputValFromRow) : None)

  if entityIds->Array.length > 0 {
    sql->dbFunction(entityIds)
  } else {
    Promise.resolve()
  }
}

let executeSet = executeEntityFunction(~dbOp=Set)
let executeDelete = executeEntityFunction(~dbOp=Delete)

let executeSetSchemaEntity = (~entityEncoder) =>
  executeSet(~getInputValFromRow=row => {
    row.entity->entityEncoder
  })

let executeBatch = async (sql, ~inMemoryStore: InMemoryStore.t) => {
  let setEventSyncState = executeSet(
    ~dbFunction=DbFunctions.EventSyncState.batchSet,
    ~getInputValFromRow=row => row.entity,
    ~rows=inMemoryStore.eventSyncState->InMemoryStore.EventSyncState.values,
  )

  let setRawEvents = executeSet(
    ~dbFunction=DbFunctions.RawEvents.batchSet,
    ~getInputValFromRow=row => row.entity,
    ~rows=inMemoryStore.rawEvents->InMemoryStore.RawEvents.values,
  )

  let setDynamicContracts = executeSet(
    ~dbFunction=DbFunctions.DynamicContractRegistry.batchSet,
    ~rows=inMemoryStore.dynamicContractRegistry->InMemoryStore.DynamicContractRegistry.values,
    ~getInputValFromRow={row => row.entity},
  )

  let deleteActions = executeDelete(
    ~dbFunction=DbFunctions.Action.batchDelete,
    ~rows=inMemoryStore.action->InMemoryStore.Action.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setActions = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Action.batchSet,
    ~rows=inMemoryStore.action->InMemoryStore.Action.values,
    ~entityEncoder=Types.actionEntity_encode,
  )

  let deleteAssets = executeDelete(
    ~dbFunction=DbFunctions.Asset.batchDelete,
    ~rows=inMemoryStore.asset->InMemoryStore.Asset.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setAssets = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Asset.batchSet,
    ~rows=inMemoryStore.asset->InMemoryStore.Asset.values,
    ~entityEncoder=Types.assetEntity_encode,
  )

  let deleteBatchs = executeDelete(
    ~dbFunction=DbFunctions.Batch.batchDelete,
    ~rows=inMemoryStore.batch->InMemoryStore.Batch.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setBatchs = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Batch.batchSet,
    ~rows=inMemoryStore.batch->InMemoryStore.Batch.values,
    ~entityEncoder=Types.batchEntity_encode,
  )

  let deleteBatchers = executeDelete(
    ~dbFunction=DbFunctions.Batcher.batchDelete,
    ~rows=inMemoryStore.batcher->InMemoryStore.Batcher.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setBatchers = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Batcher.batchSet,
    ~rows=inMemoryStore.batcher->InMemoryStore.Batcher.values,
    ~entityEncoder=Types.batcherEntity_encode,
  )

  let deleteContracts = executeDelete(
    ~dbFunction=DbFunctions.Contract.batchDelete,
    ~rows=inMemoryStore.contract->InMemoryStore.Contract.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setContracts = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Contract.batchSet,
    ~rows=inMemoryStore.contract->InMemoryStore.Contract.values,
    ~entityEncoder=Types.contractEntity_encode,
  )

  let deleteSegments = executeDelete(
    ~dbFunction=DbFunctions.Segment.batchDelete,
    ~rows=inMemoryStore.segment->InMemoryStore.Segment.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setSegments = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Segment.batchSet,
    ~rows=inMemoryStore.segment->InMemoryStore.Segment.values,
    ~entityEncoder=Types.segmentEntity_encode,
  )

  let deleteStreams = executeDelete(
    ~dbFunction=DbFunctions.Stream.batchDelete,
    ~rows=inMemoryStore.stream->InMemoryStore.Stream.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setStreams = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Stream.batchSet,
    ~rows=inMemoryStore.stream->InMemoryStore.Stream.values,
    ~entityEncoder=Types.streamEntity_encode,
  )

  let deleteWatchers = executeDelete(
    ~dbFunction=DbFunctions.Watcher.batchDelete,
    ~rows=inMemoryStore.watcher->InMemoryStore.Watcher.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setWatchers = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Watcher.batchSet,
    ~rows=inMemoryStore.watcher->InMemoryStore.Watcher.values,
    ~entityEncoder=Types.watcherEntity_encode,
  )

  let res = await sql->Postgres.beginSql(sql => {
    [
      setEventSyncState,
      setRawEvents,
      setDynamicContracts,
      deleteActions,
      setActions,
      deleteAssets,
      setAssets,
      deleteBatchs,
      setBatchs,
      deleteBatchers,
      setBatchers,
      deleteContracts,
      setContracts,
      deleteSegments,
      setSegments,
      deleteStreams,
      setStreams,
      deleteWatchers,
      setWatchers,
    ]->Belt.Array.map(dbFunc => sql->dbFunc)
  })

  res
}
