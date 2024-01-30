//*************
//***ENTITIES**
//*************

@spice @genType.as("Id")
type id = string

@genType.import(("./bindings/OpaqueTypes", "Nullable"))
type nullable<'a> = option<'a>

let nullable_encode = (encoder: Spice.encoder<'a>, n: nullable<'a>): Js.Json.t =>
  switch n {
  | None => Js.Json.null
  | Some(v) => v->encoder
  }

let nullable_decode = Spice.optionFromJson

@@warning("-30")
@genType
type rec actionLoaderConfig = {loadCampaign?: campaignLoaderConfig}
and activityLoaderConfig = {loadCampaign?: campaignLoaderConfig}
and assetLoaderConfig = bool
and campaignLoaderConfig = {
  loadAsset?: assetLoaderConfig,
  loadFactory?: factoryLoaderConfig,
  loadClawbackAction?: actionLoaderConfig,
}
and factoryLoaderConfig = bool
and watcherLoaderConfig = bool

@@warning("+30")
@genType
type entityRead =
  | ActionRead(id, actionLoaderConfig)
  | ActivityRead(id, activityLoaderConfig)
  | AssetRead(id)
  | CampaignRead(id, campaignLoaderConfig)
  | FactoryRead(id)
  | WatcherRead(id)

@genType
type rawEventsEntity = {
  @as("chain_id") chainId: int,
  @as("event_id") eventId: string,
  @as("block_number") blockNumber: int,
  @as("log_index") logIndex: int,
  @as("transaction_index") transactionIndex: int,
  @as("transaction_hash") transactionHash: string,
  @as("src_address") srcAddress: Ethers.ethAddress,
  @as("block_hash") blockHash: string,
  @as("block_timestamp") blockTimestamp: int,
  @as("event_type") eventType: Js.Json.t,
  params: string,
}

@genType
type dynamicContractRegistryEntity = {
  @as("chain_id") chainId: int,
  @as("event_id") eventId: Ethers.BigInt.t,
  @as("contract_address") contractAddress: Ethers.ethAddress,
  @as("contract_type") contractType: string,
}

@spice @genType.as("ActionEntity")
type actionEntity = {
  id: string,
  block: Ethers.BigInt.t,
  category: string,
  chainId: Ethers.BigInt.t,
  campaign: id,
  hash: string,
  from: string,
  subgraphId: Ethers.BigInt.t,
  timestamp: Ethers.BigInt.t,
  claimStreamId: nullable<string>,
  claimTokenId: nullable<Ethers.BigInt.t>,
  claimAmount: nullable<Ethers.BigInt.t>,
  claimIndex: nullable<Ethers.BigInt.t>,
  claimRecipient: nullable<string>,
  clawbackAmount: nullable<Ethers.BigInt.t>,
  clawbackFrom: nullable<string>,
  clawbackTo: nullable<string>,
}

@spice @genType.as("ActivityEntity")
type activityEntity = {
  id: string,
  campaign: id,
  timestamp: Ethers.BigInt.t,
  day: Ethers.BigInt.t,
  amount: Ethers.BigInt.t,
  claims: Ethers.BigInt.t,
}

@spice @genType.as("AssetEntity")
type assetEntity = {
  id: string,
  address: string,
  chainId: Ethers.BigInt.t,
  decimals: Ethers.BigInt.t,
  name: string,
  symbol: string,
}

@spice @genType.as("CampaignEntity")
type campaignEntity = {
  id: string,
  subgraphId: Ethers.BigInt.t,
  address: string,
  asset: id,
  factory: id,
  chainId: Ethers.BigInt.t,
  hash: string,
  timestamp: Ethers.BigInt.t,
  category: string,
  admin: string,
  lockup: string,
  root: string,
  expires: bool,
  expiration: nullable<Ethers.BigInt.t>,
  ipfsCID: string,
  aggregateAmount: Ethers.BigInt.t,
  totalRecipients: Ethers.BigInt.t,
  clawbackAction: nullable<id>,
  clawbackTime: nullable<Ethers.BigInt.t>,
  streamCliff: bool,
  streamCliffDuration: nullable<Ethers.BigInt.t>,
  streamTotalDuration: Ethers.BigInt.t,
  streamCancelable: bool,
  streamTransferable: bool,
  claimedAmount: Ethers.BigInt.t,
  claimedCount: Ethers.BigInt.t,
  version: string,
}

@spice @genType.as("FactoryEntity")
type factoryEntity = {
  id: string,
  alias: string,
  address: string,
  chainId: Ethers.BigInt.t,
  version: string,
}

@spice @genType.as("WatcherEntity")
type watcherEntity = {
  id: string,
  chainId: Ethers.BigInt.t,
  actionIndex: Ethers.BigInt.t,
  campaignIndex: Ethers.BigInt.t,
  initialized: bool,
  logs: array<string>,
}

type entity =
  | ActionEntity(actionEntity)
  | ActivityEntity(activityEntity)
  | AssetEntity(assetEntity)
  | CampaignEntity(campaignEntity)
  | FactoryEntity(factoryEntity)
  | WatcherEntity(watcherEntity)

type dbOp = Read | Set | Delete

@genType
type inMemoryStoreRow<'a> = {
  dbOp: dbOp,
  entity: 'a,
}

//*************
//**CONTRACTS**
//*************

@genType.as("EventLog")
type eventLog<'a> = {
  params: 'a,
  chainId: int,
  blockNumber: int,
  blockTimestamp: int,
  blockHash: string,
  srcAddress: Ethers.ethAddress,
  transactionHash: string,
  transactionIndex: int,
  logIndex: int,
}

module MerkleLLV21Contract = {
  module ClaimEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") index: Ethers.BigInt.t,
      @as("1") recipient: Ethers.ethAddress,
      @as("2") amount: Ethers.BigInt.t,
      @as("3") streamId: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      index: Ethers.BigInt.t,
      recipient: Ethers.ethAddress,
      amount: Ethers.BigInt.t,
      streamId: Ethers.BigInt.t,
    }

    @genType.as("MerkleLLV21Contract_Claim_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getCampaign: actionEntity => campaignEntity,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getCampaign: actionEntity => promise<campaignEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    // Entity: Activity
    type activityEntityHandlerContext = {
      get: id => option<activityEntity>,
      getCampaign: activityEntity => campaignEntity,
      set: activityEntity => unit,
      delete: id => unit,
    }

    type activityEntityHandlerContextAsync = {
      get: id => promise<option<activityEntity>>,
      getCampaign: activityEntity => promise<campaignEntity>,
      set: activityEntity => unit,
      delete: id => unit,
    }

    // Entity: Asset
    type assetEntityHandlerContext = {
      set: assetEntity => unit,
      delete: id => unit,
    }

    type assetEntityHandlerContextAsync = {
      set: assetEntity => unit,
      delete: id => unit,
    }

    // Entity: Campaign
    type campaignEntityHandlerContext = {
      get: id => option<campaignEntity>,
      getAsset: campaignEntity => assetEntity,
      getFactory: campaignEntity => factoryEntity,
      getClawbackAction: campaignEntity => option<actionEntity>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    type campaignEntityHandlerContextAsync = {
      get: id => promise<option<campaignEntity>>,
      getAsset: campaignEntity => promise<assetEntity>,
      getFactory: campaignEntity => promise<factoryEntity>,
      getClawbackAction: campaignEntity => promise<option<actionEntity>>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Watcher
    type watcherEntityHandlerContext = {
      get: id => option<watcherEntity>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    type watcherEntityHandlerContextAsync = {
      get: id => promise<option<watcherEntity>>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContext,
      @as("Activity") activity: activityEntityHandlerContext,
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Campaign") campaign: campaignEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Activity") activity: activityEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Campaign") campaign: campaignEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type activityEntityLoaderContext = {load: (id, ~loaders: activityLoaderConfig=?) => unit}
    @genType
    type campaignEntityLoaderContext = {load: (id, ~loaders: campaignLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addMerkleLLV21: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addMerkleLockupFactoryV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Activity") activity: activityEntityLoaderContext,
      @as("Campaign") campaign: campaignEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module ClawbackEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") admin: Ethers.ethAddress,
      @as("1") to: Ethers.ethAddress,
      @as("2") amount: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      admin: Ethers.ethAddress,
      to: Ethers.ethAddress,
      amount: Ethers.BigInt.t,
    }

    @genType.as("MerkleLLV21Contract_Clawback_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getCampaign: actionEntity => campaignEntity,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getCampaign: actionEntity => promise<campaignEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    // Entity: Activity
    type activityEntityHandlerContext = {
      getCampaign: activityEntity => campaignEntity,
      set: activityEntity => unit,
      delete: id => unit,
    }

    type activityEntityHandlerContextAsync = {
      getCampaign: activityEntity => promise<campaignEntity>,
      set: activityEntity => unit,
      delete: id => unit,
    }

    // Entity: Asset
    type assetEntityHandlerContext = {
      set: assetEntity => unit,
      delete: id => unit,
    }

    type assetEntityHandlerContextAsync = {
      set: assetEntity => unit,
      delete: id => unit,
    }

    // Entity: Campaign
    type campaignEntityHandlerContext = {
      get: id => option<campaignEntity>,
      getAsset: campaignEntity => assetEntity,
      getFactory: campaignEntity => factoryEntity,
      getClawbackAction: campaignEntity => option<actionEntity>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    type campaignEntityHandlerContextAsync = {
      get: id => promise<option<campaignEntity>>,
      getAsset: campaignEntity => promise<assetEntity>,
      getFactory: campaignEntity => promise<factoryEntity>,
      getClawbackAction: campaignEntity => promise<option<actionEntity>>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Watcher
    type watcherEntityHandlerContext = {
      get: id => option<watcherEntity>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    type watcherEntityHandlerContextAsync = {
      get: id => promise<option<watcherEntity>>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContext,
      @as("Activity") activity: activityEntityHandlerContext,
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Campaign") campaign: campaignEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Activity") activity: activityEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Campaign") campaign: campaignEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type campaignEntityLoaderContext = {load: (id, ~loaders: campaignLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addMerkleLLV21: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addMerkleLockupFactoryV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Campaign") campaign: campaignEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module TransferAdminEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") oldAdmin: Ethers.ethAddress,
      @as("1") newAdmin: Ethers.ethAddress,
    }

    @spice @genType
    type eventArgs = {
      oldAdmin: Ethers.ethAddress,
      newAdmin: Ethers.ethAddress,
    }

    @genType.as("MerkleLLV21Contract_TransferAdmin_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getCampaign: actionEntity => campaignEntity,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getCampaign: actionEntity => promise<campaignEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    // Entity: Activity
    type activityEntityHandlerContext = {
      getCampaign: activityEntity => campaignEntity,
      set: activityEntity => unit,
      delete: id => unit,
    }

    type activityEntityHandlerContextAsync = {
      getCampaign: activityEntity => promise<campaignEntity>,
      set: activityEntity => unit,
      delete: id => unit,
    }

    // Entity: Asset
    type assetEntityHandlerContext = {
      set: assetEntity => unit,
      delete: id => unit,
    }

    type assetEntityHandlerContextAsync = {
      set: assetEntity => unit,
      delete: id => unit,
    }

    // Entity: Campaign
    type campaignEntityHandlerContext = {
      get: id => option<campaignEntity>,
      getAsset: campaignEntity => assetEntity,
      getFactory: campaignEntity => factoryEntity,
      getClawbackAction: campaignEntity => option<actionEntity>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    type campaignEntityHandlerContextAsync = {
      get: id => promise<option<campaignEntity>>,
      getAsset: campaignEntity => promise<assetEntity>,
      getFactory: campaignEntity => promise<factoryEntity>,
      getClawbackAction: campaignEntity => promise<option<actionEntity>>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Watcher
    type watcherEntityHandlerContext = {
      get: id => option<watcherEntity>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    type watcherEntityHandlerContextAsync = {
      get: id => promise<option<watcherEntity>>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContext,
      @as("Activity") activity: activityEntityHandlerContext,
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Campaign") campaign: campaignEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Activity") activity: activityEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Campaign") campaign: campaignEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type campaignEntityLoaderContext = {load: (id, ~loaders: campaignLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addMerkleLLV21: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addMerkleLockupFactoryV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Campaign") campaign: campaignEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
}
module MerkleLockupFactoryV21Contract = {
  module CreateMerkleStreamerLLEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") merkleStreamer: Ethers.ethAddress,
      @as("1") admin: Ethers.ethAddress,
      @as("2") lockupLinear: Ethers.ethAddress,
      @as("3") asset: Ethers.ethAddress,
      @as("4") merkleRoot: string,
      @as("5") expiration: Ethers.BigInt.t,
      @as("6") streamDurations: (Ethers.BigInt.t, Ethers.BigInt.t),
      @as("7") cancelable: bool,
      @as("8") transferable: bool,
      @as("9") ipfsCID: string,
      @as("10") aggregateAmount: Ethers.BigInt.t,
      @as("11") recipientsCount: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      merkleStreamer: Ethers.ethAddress,
      admin: Ethers.ethAddress,
      lockupLinear: Ethers.ethAddress,
      asset: Ethers.ethAddress,
      merkleRoot: string,
      expiration: Ethers.BigInt.t,
      streamDurations: (Ethers.BigInt.t, Ethers.BigInt.t),
      cancelable: bool,
      transferable: bool,
      ipfsCID: string,
      aggregateAmount: Ethers.BigInt.t,
      recipientsCount: Ethers.BigInt.t,
    }

    @genType.as("MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getCampaign: actionEntity => campaignEntity,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getCampaign: actionEntity => promise<campaignEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    // Entity: Activity
    type activityEntityHandlerContext = {
      getCampaign: activityEntity => campaignEntity,
      set: activityEntity => unit,
      delete: id => unit,
    }

    type activityEntityHandlerContextAsync = {
      getCampaign: activityEntity => promise<campaignEntity>,
      set: activityEntity => unit,
      delete: id => unit,
    }

    // Entity: Asset
    type assetEntityHandlerContext = {
      get: id => option<assetEntity>,
      set: assetEntity => unit,
      delete: id => unit,
    }

    type assetEntityHandlerContextAsync = {
      get: id => promise<option<assetEntity>>,
      set: assetEntity => unit,
      delete: id => unit,
    }

    // Entity: Campaign
    type campaignEntityHandlerContext = {
      getAsset: campaignEntity => assetEntity,
      getFactory: campaignEntity => factoryEntity,
      getClawbackAction: campaignEntity => option<actionEntity>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    type campaignEntityHandlerContextAsync = {
      getAsset: campaignEntity => promise<assetEntity>,
      getFactory: campaignEntity => promise<factoryEntity>,
      getClawbackAction: campaignEntity => promise<option<actionEntity>>,
      set: campaignEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      get: id => option<factoryEntity>,
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      get: id => promise<option<factoryEntity>>,
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Watcher
    type watcherEntityHandlerContext = {
      get: id => option<watcherEntity>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    type watcherEntityHandlerContextAsync = {
      get: id => promise<option<watcherEntity>>,
      set: watcherEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContext,
      @as("Activity") activity: activityEntityHandlerContext,
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Campaign") campaign: campaignEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Activity") activity: activityEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Campaign") campaign: campaignEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type assetEntityLoaderContext = {load: id => unit}
    @genType
    type factoryEntityLoaderContext = {load: id => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addMerkleLLV21: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addMerkleLockupFactoryV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Asset") asset: assetEntityLoaderContext,
      @as("Factory") factory: factoryEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
}

@deriving(accessors)
type event =
  | MerkleLLV21Contract_Claim(eventLog<MerkleLLV21Contract.ClaimEvent.eventArgs>)
  | MerkleLLV21Contract_Clawback(eventLog<MerkleLLV21Contract.ClawbackEvent.eventArgs>)
  | MerkleLLV21Contract_TransferAdmin(eventLog<MerkleLLV21Contract.TransferAdminEvent.eventArgs>)
  | MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL(
      eventLog<MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs>,
    )

@spice
type eventName =
  | @spice.as("MerkleLLV21_Claim") MerkleLLV21_Claim
  | @spice.as("MerkleLLV21_Clawback") MerkleLLV21_Clawback
  | @spice.as("MerkleLLV21_TransferAdmin") MerkleLLV21_TransferAdmin
  | @spice.as("MerkleLockupFactoryV21_CreateMerkleStreamerLL")
  MerkleLockupFactoryV21_CreateMerkleStreamerLL

let eventNameToString = (eventName: eventName) =>
  switch eventName {
  | MerkleLLV21_Claim => "Claim"
  | MerkleLLV21_Clawback => "Clawback"
  | MerkleLLV21_TransferAdmin => "TransferAdmin"
  | MerkleLockupFactoryV21_CreateMerkleStreamerLL => "CreateMerkleStreamerLL"
  }

@genType
type chainId = int

type eventBatchQueueItem = {
  timestamp: int,
  chainId: int,
  blockNumber: int,
  logIndex: int,
  event: event,
}
