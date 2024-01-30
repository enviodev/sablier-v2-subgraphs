type entityGetters = {
  getAction: Types.id => promise<array<Types.actionEntity>>,
  getActivity: Types.id => promise<array<Types.activityEntity>>,
  getAsset: Types.id => promise<array<Types.assetEntity>>,
  getCampaign: Types.id => promise<array<Types.campaignEntity>>,
  getFactory: Types.id => promise<array<Types.factoryEntity>>,
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

module MerkleLLV21Contract = {
  module ClaimEvent = {
    type loaderContext = Types.MerkleLLV21Contract.ClaimEvent.loaderContext
    type handlerContext = Types.MerkleLLV21Contract.ClaimEvent.handlerContext
    type handlerContextAsync = Types.MerkleLLV21Contract.ClaimEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.MerkleLLV21Contract.ClaimEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "MerkleLLV21.Claim",
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

      let optSetOfIds_activity: Set.t<Types.id> = Set.make()
      let optSetOfIds_campaign: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addMerkleLLV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLLV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addMerkleLockupFactoryV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLockupFactoryV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        activity: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_activity->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.ActivityRead(id, loaders))
          },
        },
        campaign: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_campaign->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.CampaignRead(id, loaders))
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
            getCampaign: action => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(action.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Action campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_activity->Set.has(id) {
                inMemoryStore.activity->IO.InMemoryStore.Activity.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Activity" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.activity.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.activity->IO.InMemoryStore.Activity.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getCampaign: activity => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(activity.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Activity campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateActivity entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Activity is undefined.",
                  ),
                )
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_campaign->Set.has(id) {
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Campaign" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.campaign.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: campaign => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(campaign.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Campaign asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getFactory: campaign => {
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(campaign.factory)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                Logging.warn(`Campaign factory data not found. Loading associated factory from database.
Please consider loading the factory in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getClawbackAction: campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  Logging.warn(`Campaign clawbackAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Campaign is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
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
            getCampaign: async action => {
              let campaign_field = action.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Action is undefined.",
                    ),
                  )
                }
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_activity->Set.has(id) {
                inMemoryStore.activity->IO.InMemoryStore.Activity.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.activity->IO.InMemoryStore.Activity.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getActivity(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Activity.set(
                      inMemoryStore.activity,
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
            getCampaign: async activity => {
              let campaign_field = activity.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Activity campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Activity is undefined.",
                    ),
                  )
                }
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_campaign->Set.has(id) {
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getCampaign(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Campaign.set(
                      inMemoryStore.campaign,
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
            getAsset: async campaign => {
              let asset_field = campaign.asset
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
                  Logging.error(`Campaign asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getFactory: async campaign => {
              let factory_field = campaign.factory
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(factory_field)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                let entities = await asyncGetters.getFactory(factory_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Factory.set(
                    inMemoryStore.factory,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Campaign factory data not found. Loading associated factory from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity factory of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getClawbackAction: async campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  let entities = await asyncGetters.getAction(clawbackAction_field)

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
                    Logging.error(`Campaign clawbackAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity clawbackAction of Campaign is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
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

  module ClawbackEvent = {
    type loaderContext = Types.MerkleLLV21Contract.ClawbackEvent.loaderContext
    type handlerContext = Types.MerkleLLV21Contract.ClawbackEvent.handlerContext
    type handlerContextAsync = Types.MerkleLLV21Contract.ClawbackEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.MerkleLLV21Contract.ClawbackEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "MerkleLLV21.Clawback",
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

      let optSetOfIds_campaign: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addMerkleLLV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLLV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addMerkleLockupFactoryV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLockupFactoryV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        campaign: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_campaign->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.CampaignRead(id, loaders))
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
            getCampaign: action => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(action.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Action campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            getCampaign: activity => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(activity.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Activity campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateActivity entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Activity is undefined.",
                  ),
                )
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_campaign->Set.has(id) {
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Campaign" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.campaign.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: campaign => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(campaign.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Campaign asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getFactory: campaign => {
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(campaign.factory)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                Logging.warn(`Campaign factory data not found. Loading associated factory from database.
Please consider loading the factory in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getClawbackAction: campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  Logging.warn(`Campaign clawbackAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Campaign is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
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
            getCampaign: async action => {
              let campaign_field = action.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Action is undefined.",
                    ),
                  )
                }
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            getCampaign: async activity => {
              let campaign_field = activity.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Activity campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Activity is undefined.",
                    ),
                  )
                }
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_campaign->Set.has(id) {
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getCampaign(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Campaign.set(
                      inMemoryStore.campaign,
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
            getAsset: async campaign => {
              let asset_field = campaign.asset
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
                  Logging.error(`Campaign asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getFactory: async campaign => {
              let factory_field = campaign.factory
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(factory_field)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                let entities = await asyncGetters.getFactory(factory_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Factory.set(
                    inMemoryStore.factory,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Campaign factory data not found. Loading associated factory from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity factory of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getClawbackAction: async campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  let entities = await asyncGetters.getAction(clawbackAction_field)

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
                    Logging.error(`Campaign clawbackAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity clawbackAction of Campaign is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
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
    type loaderContext = Types.MerkleLLV21Contract.TransferAdminEvent.loaderContext
    type handlerContext = Types.MerkleLLV21Contract.TransferAdminEvent.handlerContext
    type handlerContextAsync = Types.MerkleLLV21Contract.TransferAdminEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "MerkleLLV21.TransferAdmin",
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

      let optSetOfIds_campaign: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addMerkleLLV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLLV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addMerkleLockupFactoryV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLockupFactoryV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        campaign: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_campaign->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.CampaignRead(id, loaders))
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
            getCampaign: action => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(action.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Action campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            getCampaign: activity => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(activity.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Activity campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateActivity entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Activity is undefined.",
                  ),
                )
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_campaign->Set.has(id) {
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Campaign" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.campaign.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getAsset: campaign => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(campaign.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Campaign asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getFactory: campaign => {
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(campaign.factory)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                Logging.warn(`Campaign factory data not found. Loading associated factory from database.
Please consider loading the factory in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getClawbackAction: campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  Logging.warn(`Campaign clawbackAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Campaign is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
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
            getCampaign: async action => {
              let campaign_field = action.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Action is undefined.",
                    ),
                  )
                }
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            getCampaign: async activity => {
              let campaign_field = activity.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Activity campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Activity is undefined.",
                    ),
                  )
                }
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_campaign->Set.has(id) {
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getCampaign(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Campaign.set(
                      inMemoryStore.campaign,
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
            getAsset: async campaign => {
              let asset_field = campaign.asset
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
                  Logging.error(`Campaign asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getFactory: async campaign => {
              let factory_field = campaign.factory
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(factory_field)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                let entities = await asyncGetters.getFactory(factory_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Factory.set(
                    inMemoryStore.factory,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Campaign factory data not found. Loading associated factory from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity factory of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getClawbackAction: async campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  let entities = await asyncGetters.getAction(clawbackAction_field)

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
                    Logging.error(`Campaign clawbackAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity clawbackAction of Campaign is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
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

module MerkleLockupFactoryV21Contract = {
  module CreateMerkleStreamerLLEvent = {
    type loaderContext = Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.loaderContext
    type handlerContext = Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.handlerContext
    type handlerContextAsync = Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "MerkleLockupFactoryV21.CreateMerkleStreamerLL",
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
      let optSetOfIds_factory: Set.t<Types.id> = Set.make()
      let optSetOfIds_watcher: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addMerkleLLV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLLV21",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addMerkleLockupFactoryV21: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "MerkleLockupFactoryV21",
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
        factory: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_factory->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.FactoryRead(id))
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
            getCampaign: action => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(action.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Action campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateAction entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Action is undefined.",
                  ),
                )
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            getCampaign: activity => {
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(activity.campaign)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                Logging.warn(`Activity campaign data not found. Loading associated campaign from database.
Please consider loading the campaign in the UpdateActivity entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Activity is undefined.",
                  ),
                )
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            getAsset: campaign => {
              let optAsset = inMemoryStore.asset->IO.InMemoryStore.Asset.get(campaign.asset)
              switch optAsset {
              | Some(asset) => asset
              | None =>
                Logging.warn(`Campaign asset data not found. Loading associated asset from database.
Please consider loading the asset in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getFactory: campaign => {
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(campaign.factory)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                Logging.warn(`Campaign factory data not found. Loading associated factory from database.
Please consider loading the factory in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Campaign is undefined.",
                  ),
                )
              }
            },
            getClawbackAction: campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  Logging.warn(`Campaign clawbackAction data not found. Loading associated action from database.
Please consider loading the action in the UpdateCampaign entity loader to greatly improve sync speed of your application.
`)

                  raise(
                    LinkedEntityNotAvailableInSyncHandler(
                      "The required linked entity of Campaign is undefined.",
                    ),
                  )
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_factory->Set.has(id) {
                inMemoryStore.factory->IO.InMemoryStore.Factory.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Factory" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.factory.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.factory->IO.InMemoryStore.Factory.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
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
            getCampaign: async action => {
              let campaign_field = action.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Action campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Action is undefined.",
                    ),
                  )
                }
              }
            },
          },
          activity: {
            set: entity => {
              inMemoryStore.activity->IO.InMemoryStore.Activity.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(activity) with ID ${id}.`),
            getCampaign: async activity => {
              let campaign_field = activity.campaign
              let optCampaign =
                inMemoryStore.campaign->IO.InMemoryStore.Campaign.get(campaign_field)
              switch optCampaign {
              | Some(campaign) => campaign
              | None =>
                let entities = await asyncGetters.getCampaign(campaign_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Campaign.set(
                    inMemoryStore.campaign,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Activity campaign data not found. Loading associated campaign from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity campaign of Activity is undefined.",
                    ),
                  )
                }
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
          campaign: {
            set: entity => {
              inMemoryStore.campaign->IO.InMemoryStore.Campaign.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(campaign) with ID ${id}.`),
            getAsset: async campaign => {
              let asset_field = campaign.asset
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
                  Logging.error(`Campaign asset data not found. Loading associated asset from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity asset of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getFactory: async campaign => {
              let factory_field = campaign.factory
              let optFactory = inMemoryStore.factory->IO.InMemoryStore.Factory.get(factory_field)
              switch optFactory {
              | Some(factory) => factory
              | None =>
                let entities = await asyncGetters.getFactory(factory_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Factory.set(
                    inMemoryStore.factory,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Campaign factory data not found. Loading associated factory from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity factory of Campaign is undefined.",
                    ),
                  )
                }
              }
            },
            getClawbackAction: async campaign => {
              switch campaign.clawbackAction {
              | Some(clawbackAction_field) =>
                // TODO: we aren't handling the case where the code is an optional array. Maybe we should enforce that at the compile step, and force users to use an empty array instead.
                let optClawbackAction =
                  inMemoryStore.action->IO.InMemoryStore.Action.get(clawbackAction_field)

                switch optClawbackAction {
                | Some(clawbackAction) => clawbackAction
                | None =>
                  let entities = await asyncGetters.getAction(clawbackAction_field)

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
                    Logging.error(`Campaign clawbackAction data not found. Loading associated action from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                    raise(
                      UnableToLoadNonNullableLinkedEntity(
                        "The required linked entity clawbackAction of Campaign is undefined.",
                      ),
                    )
                  }
                }->Some
              | None => None
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_factory->Set.has(id) {
                inMemoryStore.factory->IO.InMemoryStore.Factory.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.factory->IO.InMemoryStore.Factory.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getFactory(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Factory.set(
                      inMemoryStore.factory,
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
  | MerkleLLV21Contract_ClaimWithContext(
      Types.eventLog<Types.MerkleLLV21Contract.ClaimEvent.eventArgs>,
      MerkleLLV21Contract.ClaimEvent.context,
    )
  | MerkleLLV21Contract_ClawbackWithContext(
      Types.eventLog<Types.MerkleLLV21Contract.ClawbackEvent.eventArgs>,
      MerkleLLV21Contract.ClawbackEvent.context,
    )
  | MerkleLLV21Contract_TransferAdminWithContext(
      Types.eventLog<Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs>,
      MerkleLLV21Contract.TransferAdminEvent.context,
    )
  | MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLWithContext(
      Types.eventLog<Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs>,
      MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.context,
    )

type eventRouterEventAndContext = {
  chainId: int,
  event: eventAndContext,
}
