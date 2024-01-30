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

  module Activity = MakeStore({
    type t = Types.activityEntity
    type key = string
    let hasher = Obj.magic
  })

  module Asset = MakeStore({
    type t = Types.assetEntity
    type key = string
    let hasher = Obj.magic
  })

  module Campaign = MakeStore({
    type t = Types.campaignEntity
    type key = string
    let hasher = Obj.magic
  })

  module Factory = MakeStore({
    type t = Types.factoryEntity
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
    activity: Activity.t,
    asset: Asset.t,
    campaign: Campaign.t,
    factory: Factory.t,
    watcher: Watcher.t,
  }

  let make = (): t => {
    eventSyncState: EventSyncState.make(),
    rawEvents: RawEvents.make(),
    dynamicContractRegistry: DynamicContractRegistry.make(),
    action: Action.make(),
    activity: Activity.make(),
    asset: Asset.make(),
    campaign: Campaign.make(),
    factory: Factory.make(),
    watcher: Watcher.make(),
  }

  let clone = (self: t) => {
    eventSyncState: self.eventSyncState->EventSyncState.clone,
    rawEvents: self.rawEvents->RawEvents.clone,
    dynamicContractRegistry: self.dynamicContractRegistry->DynamicContractRegistry.clone,
    action: self.action->Action.clone,
    activity: self.activity->Activity.clone,
    asset: self.asset->Asset.clone,
    campaign: self.campaign->Campaign.clone,
    factory: self.factory->Factory.clone,
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
    //A unique list of ids that need to be loaded for entity activity
    activityIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity asset
    assetIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity campaign
    campaignIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity factory
    factoryIdsToLoad: idsToLoad,
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
    activityIdsToLoad: Belt.Set.String.empty,
    assetIdsToLoad: Belt.Set.String.empty,
    campaignIdsToLoad: Belt.Set.String.empty,
    factoryIdsToLoad: Belt.Set.String.empty,
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
    actionLoaderConfig.loadCampaign->Belt.Option.map(campaignLoaderConfig => {
      () =>
        inMemoryStore.action
        ->InMemoryStore.Action.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            campaignLinkedEntityLoader(~campaignLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.campaign is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.campaign->getLoader]
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
and activityLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~activityLoaderConfig: Types.activityLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    activityLoaderConfig.loadCampaign->Belt.Option.map(campaignLoaderConfig => {
      () =>
        inMemoryStore.activity
        ->InMemoryStore.Activity.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            campaignLinkedEntityLoader(~campaignLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.campaign is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.campaign->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    activityIdsToLoad: loadLayer.activityIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
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
and campaignLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~campaignLoaderConfig: Types.campaignLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    campaignLoaderConfig.loadAsset->Belt.Option.map(assetLoaderConfig => {
      () =>
        inMemoryStore.campaign
        ->InMemoryStore.Campaign.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            assetLinkedEntityLoader(~assetLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.asset is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.asset->getLoader]
        })
    }),
    campaignLoaderConfig.loadFactory->Belt.Option.map(factoryLoaderConfig => {
      () =>
        inMemoryStore.campaign
        ->InMemoryStore.Campaign.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            factoryLinkedEntityLoader(~factoryLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.factory is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.factory->getLoader]
        })
    }),
    campaignLoaderConfig.loadClawbackAction->Belt.Option.map(actionLoaderConfig => {
      () =>
        inMemoryStore.campaign
        ->InMemoryStore.Campaign.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            actionLinkedEntityLoader(~actionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.clawbackAction is an optional single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          entity.clawbackAction->Belt.Option.mapWithDefault([], entityId => [entityId->getLoader])
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    campaignIdsToLoad: loadLayer.campaignIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and factoryLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~factoryLoaderConfig: Types.factoryLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "factoryLoaderConfig" type is a boolean.
  if !factoryLoaderConfig {
    //If factoryLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If factoryLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      factoryIdsToLoad: loadLayer.factoryIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
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
    | ActivityRead(entityId, activityLoaderConfig) =>
      loadLayer->activityLinkedEntityLoader(~entityId, ~inMemoryStore, ~activityLoaderConfig)
    | AssetRead(entityId) =>
      loadLayer->assetLinkedEntityLoader(~entityId, ~inMemoryStore, ~assetLoaderConfig=true)
    | CampaignRead(entityId, campaignLoaderConfig) =>
      loadLayer->campaignLinkedEntityLoader(~entityId, ~inMemoryStore, ~campaignLoaderConfig)
    | FactoryRead(entityId) =>
      loadLayer->factoryLinkedEntityLoader(~entityId, ~inMemoryStore, ~factoryLoaderConfig=true)
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
      ~idsToLoad=loadLayer.activityIdsToLoad,
      ~dbReadFn=DbFunctions.Activity.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Activity.set,
      ~store=inMemoryStore.activity,
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
      ~idsToLoad=loadLayer.campaignIdsToLoad,
      ~dbReadFn=DbFunctions.Campaign.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Campaign.set,
      ~store=inMemoryStore.campaign,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.factoryIdsToLoad,
      ~dbReadFn=DbFunctions.Factory.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Factory.set,
      ~store=inMemoryStore.factory,
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

  let deleteActivitys = executeDelete(
    ~dbFunction=DbFunctions.Activity.batchDelete,
    ~rows=inMemoryStore.activity->InMemoryStore.Activity.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setActivitys = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Activity.batchSet,
    ~rows=inMemoryStore.activity->InMemoryStore.Activity.values,
    ~entityEncoder=Types.activityEntity_encode,
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

  let deleteCampaigns = executeDelete(
    ~dbFunction=DbFunctions.Campaign.batchDelete,
    ~rows=inMemoryStore.campaign->InMemoryStore.Campaign.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setCampaigns = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Campaign.batchSet,
    ~rows=inMemoryStore.campaign->InMemoryStore.Campaign.values,
    ~entityEncoder=Types.campaignEntity_encode,
  )

  let deleteFactorys = executeDelete(
    ~dbFunction=DbFunctions.Factory.batchDelete,
    ~rows=inMemoryStore.factory->InMemoryStore.Factory.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setFactorys = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Factory.batchSet,
    ~rows=inMemoryStore.factory->InMemoryStore.Factory.values,
    ~entityEncoder=Types.factoryEntity_encode,
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
      deleteActivitys,
      setActivitys,
      deleteAssets,
      setAssets,
      deleteCampaigns,
      setCampaigns,
      deleteFactorys,
      setFactorys,
      deleteWatchers,
      setWatchers,
    ]->Belt.Array.map(dbFunc => sql->dbFunc)
  })

  res
}
