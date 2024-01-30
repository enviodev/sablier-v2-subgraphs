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
type rec actionLoaderConfig = {loadContract?: contractLoaderConfig, loadStream?: streamLoaderConfig}
and assetLoaderConfig = bool
and batchLoaderConfig = {loadBatcher?: batcherLoaderConfig}
and batcherLoaderConfig = bool
and contractLoaderConfig = bool
and segmentLoaderConfig = {loadStream?: streamLoaderConfig}
and streamLoaderConfig = {
  loadAsset?: assetLoaderConfig,
  loadContract?: contractLoaderConfig,
  loadCanceledAction?: actionLoaderConfig,
  loadRenounceAction?: actionLoaderConfig,
  loadBatch?: batchLoaderConfig,
}
and watcherLoaderConfig = bool

@@warning("+30")
@genType
type entityRead =
  | ActionRead(id, actionLoaderConfig)
  | AssetRead(id)
  | BatchRead(id, batchLoaderConfig)
  | BatcherRead(id)
  | ContractRead(id)
  | SegmentRead(id, segmentLoaderConfig)
  | StreamRead(id, streamLoaderConfig)
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
  id: id,
  addressA: nullable<string>,
  addressB: nullable<string>,
  amountA: nullable<Ethers.BigInt.t>,
  amountB: nullable<Ethers.BigInt.t>,
  block: Ethers.BigInt.t,
  category: string,
  chainId: Ethers.BigInt.t,
  contract: id,
  hash: string,
  from: string,
  stream: nullable<id>,
  subgraphId: Ethers.BigInt.t,
  timestamp: Ethers.BigInt.t,
}

@spice @genType.as("AssetEntity")
type assetEntity = {
  id: id,
  address: string,
  chainId: Ethers.BigInt.t,
  decimals: Ethers.BigInt.t,
  name: string,
  symbol: string,
}

@spice @genType.as("BatchEntity")
type batchEntity = {
  id: string,
  size: Ethers.BigInt.t,
  label: nullable<string>,
  batcher: nullable<id>,
  hash: string,
  timestamp: Ethers.BigInt.t,
}

@spice @genType.as("BatcherEntity")
type batcherEntity = {
  id: string,
  address: string,
  batchIndex: Ethers.BigInt.t,
}

@spice @genType.as("ContractEntity")
type contractEntity = {
  id: id,
  address: string,
  admin: nullable<string>,
  alias: string,
  chainId: Ethers.BigInt.t,
  category: string,
  version: string,
}

@spice @genType.as("SegmentEntity")
type segmentEntity = {
  id: id,
  position: Ethers.BigInt.t,
  stream: id,
  amount: Ethers.BigInt.t,
  exponent: Ethers.BigInt.t,
  milestone: Ethers.BigInt.t,
  endTime: Ethers.BigInt.t,
  startTime: Ethers.BigInt.t,
  startAmount: Ethers.BigInt.t,
  endAmount: Ethers.BigInt.t,
}

@spice @genType.as("StreamEntity")
type streamEntity = {
  id: id,
  alias: string,
  subgraphId: Ethers.BigInt.t,
  tokenId: Ethers.BigInt.t,
  version: string,
  asset: id,
  category: string,
  chainId: Ethers.BigInt.t,
  contract: id,
  hash: string,
  timestamp: Ethers.BigInt.t,
  funder: string,
  sender: string,
  recipient: string,
  parties: array<string>,
  proxender: nullable<string>,
  proxied: bool,
  cliff: bool,
  cancelable: bool,
  canceled: bool,
  transferable: bool,
  canceledAction: nullable<id>,
  renounceAction: nullable<id>,
  renounceTime: nullable<Ethers.BigInt.t>,
  canceledTime: nullable<Ethers.BigInt.t>,
  cliffTime: nullable<Ethers.BigInt.t>,
  endTime: Ethers.BigInt.t,
  startTime: Ethers.BigInt.t,
  duration: Ethers.BigInt.t,
  brokerFeeAmount: Ethers.BigInt.t,
  cliffAmount: nullable<Ethers.BigInt.t>,
  depositAmount: Ethers.BigInt.t,
  intactAmount: Ethers.BigInt.t,
  protocolFeeAmount: Ethers.BigInt.t,
  withdrawnAmount: Ethers.BigInt.t,
  batch: id,
  position: Ethers.BigInt.t,
}

@spice @genType.as("WatcherEntity")
type watcherEntity = {
  id: id,
  chainId: Ethers.BigInt.t,
  streamIndex: Ethers.BigInt.t,
  actionIndex: Ethers.BigInt.t,
  initialized: bool,
  logs: array<string>,
}

type entity =
  | ActionEntity(actionEntity)
  | AssetEntity(assetEntity)
  | BatchEntity(batchEntity)
  | BatcherEntity(batcherEntity)
  | ContractEntity(contractEntity)
  | SegmentEntity(segmentEntity)
  | StreamEntity(streamEntity)
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

module LockupV20Contract = {
  module ApprovalEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") owner: Ethers.ethAddress,
      @as("1") approved: Ethers.ethAddress,
      @as("2") tokenId: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      owner: Ethers.ethAddress,
      approved: Ethers.ethAddress,
      tokenId: Ethers.BigInt.t,
    }

    @genType.as("LockupV20Contract_Approval_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module ApprovalForAllEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") owner: Ethers.ethAddress,
      @as("1") operator: Ethers.ethAddress,
      @as("2") approved: bool,
    }

    @spice @genType
    type eventArgs = {
      owner: Ethers.ethAddress,
      operator: Ethers.ethAddress,
      approved: bool,
    }

    @genType.as("LockupV20Contract_ApprovalForAll_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module CancelLockupStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") sender: Ethers.ethAddress,
      @as("2") recipient: Ethers.ethAddress,
      @as("3") senderAmount: Ethers.BigInt.t,
      @as("4") recipientAmount: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      sender: Ethers.ethAddress,
      recipient: Ethers.ethAddress,
      senderAmount: Ethers.BigInt.t,
      recipientAmount: Ethers.BigInt.t,
    }

    @genType.as("LockupV20Contract_CancelLockupStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module CreateLockupLinearStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") funder: Ethers.ethAddress,
      @as("2") sender: Ethers.ethAddress,
      @as("3") recipient: Ethers.ethAddress,
      @as("4") amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      @as("5") asset: Ethers.ethAddress,
      @as("6") cancelable: bool,
      @as("7") range: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      @as("8") broker: Ethers.ethAddress,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      funder: Ethers.ethAddress,
      sender: Ethers.ethAddress,
      recipient: Ethers.ethAddress,
      amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset: Ethers.ethAddress,
      cancelable: bool,
      range: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      broker: Ethers.ethAddress,
    }

    @genType.as("LockupV20Contract_CreateLockupLinearStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      get: id => option<batchEntity>,
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      get: id => promise<option<batchEntity>>,
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      get: id => option<batcherEntity>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      get: id => promise<option<batcherEntity>>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      get: id => option<contractEntity>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      get: id => promise<option<contractEntity>>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type assetEntityLoaderContext = {load: id => unit}
    @genType
    type batchEntityLoaderContext = {load: (id, ~loaders: batchLoaderConfig=?) => unit}
    @genType
    type batcherEntityLoaderContext = {load: id => unit}
    @genType
    type contractEntityLoaderContext = {load: id => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Asset") asset: assetEntityLoaderContext,
      @as("Batch") batch: batchEntityLoaderContext,
      @as("Batcher") batcher: batcherEntityLoaderContext,
      @as("Contract") contract: contractEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module CreateLockupDynamicStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") funder: Ethers.ethAddress,
      @as("2") sender: Ethers.ethAddress,
      @as("3") recipient: Ethers.ethAddress,
      @as("4") amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      @as("5") asset: Ethers.ethAddress,
      @as("6") cancelable: bool,
      @as("7") segments: array<(Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t)>,
      @as("8") range: (Ethers.BigInt.t, Ethers.BigInt.t),
      @as("9") broker: Ethers.ethAddress,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      funder: Ethers.ethAddress,
      sender: Ethers.ethAddress,
      recipient: Ethers.ethAddress,
      amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset: Ethers.ethAddress,
      cancelable: bool,
      segments: array<(Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t)>,
      range: (Ethers.BigInt.t, Ethers.BigInt.t),
      broker: Ethers.ethAddress,
    }

    @genType.as("LockupV20Contract_CreateLockupDynamicStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      get: id => option<batchEntity>,
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      get: id => promise<option<batchEntity>>,
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      get: id => option<batcherEntity>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      get: id => promise<option<batcherEntity>>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      get: id => option<contractEntity>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      get: id => promise<option<contractEntity>>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type assetEntityLoaderContext = {load: id => unit}
    @genType
    type batchEntityLoaderContext = {load: (id, ~loaders: batchLoaderConfig=?) => unit}
    @genType
    type batcherEntityLoaderContext = {load: id => unit}
    @genType
    type contractEntityLoaderContext = {load: id => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Asset") asset: assetEntityLoaderContext,
      @as("Batch") batch: batchEntityLoaderContext,
      @as("Batcher") batcher: batcherEntityLoaderContext,
      @as("Contract") contract: contractEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module RenounceLockupStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {@as("0") streamId: Ethers.BigInt.t}

    @spice @genType
    type eventArgs = {streamId: Ethers.BigInt.t}

    @genType.as("LockupV20Contract_RenounceLockupStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module TransferEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") from: Ethers.ethAddress,
      @as("1") to: Ethers.ethAddress,
      @as("2") tokenId: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      from: Ethers.ethAddress,
      to: Ethers.ethAddress,
      tokenId: Ethers.BigInt.t,
    }

    @genType.as("LockupV20Contract_Transfer_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
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

    @genType.as("LockupV20Contract_TransferAdmin_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      get: id => option<contractEntity>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      get: id => promise<option<contractEntity>>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type contractEntityLoaderContext = {load: id => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Contract") contract: contractEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module WithdrawFromLockupStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") to: Ethers.ethAddress,
      @as("2") amount: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      to: Ethers.ethAddress,
      amount: Ethers.BigInt.t,
    }

    @genType.as("LockupV20Contract_WithdrawFromLockupStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
}
module LockupV21Contract = {
  module ApprovalEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") owner: Ethers.ethAddress,
      @as("1") approved: Ethers.ethAddress,
      @as("2") tokenId: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      owner: Ethers.ethAddress,
      approved: Ethers.ethAddress,
      tokenId: Ethers.BigInt.t,
    }

    @genType.as("LockupV21Contract_Approval_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module ApprovalForAllEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") owner: Ethers.ethAddress,
      @as("1") operator: Ethers.ethAddress,
      @as("2") approved: bool,
    }

    @spice @genType
    type eventArgs = {
      owner: Ethers.ethAddress,
      operator: Ethers.ethAddress,
      approved: bool,
    }

    @genType.as("LockupV21Contract_ApprovalForAll_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module CancelLockupStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") sender: Ethers.ethAddress,
      @as("2") recipient: Ethers.ethAddress,
      @as("3") asset: Ethers.ethAddress,
      @as("4") senderAmount: Ethers.BigInt.t,
      @as("5") recipientAmount: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      sender: Ethers.ethAddress,
      recipient: Ethers.ethAddress,
      asset: Ethers.ethAddress,
      senderAmount: Ethers.BigInt.t,
      recipientAmount: Ethers.BigInt.t,
    }

    @genType.as("LockupV21Contract_CancelLockupStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module CreateLockupLinearStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") funder: Ethers.ethAddress,
      @as("2") sender: Ethers.ethAddress,
      @as("3") recipient: Ethers.ethAddress,
      @as("4") amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      @as("5") asset: Ethers.ethAddress,
      @as("6") cancelable: bool,
      @as("7") transferable: bool,
      @as("8") range: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      @as("9") broker: Ethers.ethAddress,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      funder: Ethers.ethAddress,
      sender: Ethers.ethAddress,
      recipient: Ethers.ethAddress,
      amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset: Ethers.ethAddress,
      cancelable: bool,
      transferable: bool,
      range: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      broker: Ethers.ethAddress,
    }

    @genType.as("LockupV21Contract_CreateLockupLinearStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      get: id => option<batchEntity>,
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      get: id => promise<option<batchEntity>>,
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      get: id => option<batcherEntity>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      get: id => promise<option<batcherEntity>>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      get: id => option<contractEntity>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      get: id => promise<option<contractEntity>>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type assetEntityLoaderContext = {load: id => unit}
    @genType
    type batchEntityLoaderContext = {load: (id, ~loaders: batchLoaderConfig=?) => unit}
    @genType
    type batcherEntityLoaderContext = {load: id => unit}
    @genType
    type contractEntityLoaderContext = {load: id => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Asset") asset: assetEntityLoaderContext,
      @as("Batch") batch: batchEntityLoaderContext,
      @as("Batcher") batcher: batcherEntityLoaderContext,
      @as("Contract") contract: contractEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module CreateLockupDynamicStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") funder: Ethers.ethAddress,
      @as("2") sender: Ethers.ethAddress,
      @as("3") recipient: Ethers.ethAddress,
      @as("4") amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      @as("5") asset: Ethers.ethAddress,
      @as("6") cancelable: bool,
      @as("7") transferable: bool,
      @as("8") segments: array<(Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t)>,
      @as("9") range: (Ethers.BigInt.t, Ethers.BigInt.t),
      @as("10") broker: Ethers.ethAddress,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      funder: Ethers.ethAddress,
      sender: Ethers.ethAddress,
      recipient: Ethers.ethAddress,
      amounts: (Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t),
      asset: Ethers.ethAddress,
      cancelable: bool,
      transferable: bool,
      segments: array<(Ethers.BigInt.t, Ethers.BigInt.t, Ethers.BigInt.t)>,
      range: (Ethers.BigInt.t, Ethers.BigInt.t),
      broker: Ethers.ethAddress,
    }

    @genType.as("LockupV21Contract_CreateLockupDynamicStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      get: id => option<batchEntity>,
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      get: id => promise<option<batchEntity>>,
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      get: id => option<batcherEntity>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      get: id => promise<option<batcherEntity>>,
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      get: id => option<contractEntity>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      get: id => promise<option<contractEntity>>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type assetEntityLoaderContext = {load: id => unit}
    @genType
    type batchEntityLoaderContext = {load: (id, ~loaders: batchLoaderConfig=?) => unit}
    @genType
    type batcherEntityLoaderContext = {load: id => unit}
    @genType
    type contractEntityLoaderContext = {load: id => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Asset") asset: assetEntityLoaderContext,
      @as("Batch") batch: batchEntityLoaderContext,
      @as("Batcher") batcher: batcherEntityLoaderContext,
      @as("Contract") contract: contractEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module RenounceLockupStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {@as("0") streamId: Ethers.BigInt.t}

    @spice @genType
    type eventArgs = {streamId: Ethers.BigInt.t}

    @genType.as("LockupV21Contract_RenounceLockupStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module TransferEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") from: Ethers.ethAddress,
      @as("1") to: Ethers.ethAddress,
      @as("2") tokenId: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      from: Ethers.ethAddress,
      to: Ethers.ethAddress,
      tokenId: Ethers.BigInt.t,
    }

    @genType.as("LockupV21Contract_Transfer_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
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

    @genType.as("LockupV21Contract_TransferAdmin_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      get: id => option<contractEntity>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      get: id => promise<option<contractEntity>>,
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type contractEntityLoaderContext = {load: id => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Contract") contract: contractEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
  module WithdrawFromLockupStreamEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") streamId: Ethers.BigInt.t,
      @as("1") to: Ethers.ethAddress,
      @as("2") asset: Ethers.ethAddress,
      @as("3") amount: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      streamId: Ethers.BigInt.t,
      to: Ethers.ethAddress,
      asset: Ethers.ethAddress,
      amount: Ethers.BigInt.t,
    }

    @genType.as("LockupV21Contract_WithdrawFromLockupStream_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Action
    type actionEntityHandlerContext = {
      getContract: actionEntity => contractEntity,
      getStream: actionEntity => option<streamEntity>,
      set: actionEntity => unit,
      delete: id => unit,
    }

    type actionEntityHandlerContextAsync = {
      getContract: actionEntity => promise<contractEntity>,
      getStream: actionEntity => promise<option<streamEntity>>,
      set: actionEntity => unit,
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

    // Entity: Batch
    type batchEntityHandlerContext = {
      getBatcher: batchEntity => option<batcherEntity>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    type batchEntityHandlerContextAsync = {
      getBatcher: batchEntity => promise<option<batcherEntity>>,
      set: batchEntity => unit,
      delete: id => unit,
    }

    // Entity: Batcher
    type batcherEntityHandlerContext = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    type batcherEntityHandlerContextAsync = {
      set: batcherEntity => unit,
      delete: id => unit,
    }

    // Entity: Contract
    type contractEntityHandlerContext = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    type contractEntityHandlerContextAsync = {
      set: contractEntity => unit,
      delete: id => unit,
    }

    // Entity: Segment
    type segmentEntityHandlerContext = {
      getStream: segmentEntity => streamEntity,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    type segmentEntityHandlerContextAsync = {
      getStream: segmentEntity => promise<streamEntity>,
      set: segmentEntity => unit,
      delete: id => unit,
    }

    // Entity: Stream
    type streamEntityHandlerContext = {
      get: id => option<streamEntity>,
      getAsset: streamEntity => assetEntity,
      getContract: streamEntity => contractEntity,
      getCanceledAction: streamEntity => option<actionEntity>,
      getRenounceAction: streamEntity => option<actionEntity>,
      getBatch: streamEntity => batchEntity,
      set: streamEntity => unit,
      delete: id => unit,
    }

    type streamEntityHandlerContextAsync = {
      get: id => promise<option<streamEntity>>,
      getAsset: streamEntity => promise<assetEntity>,
      getContract: streamEntity => promise<contractEntity>,
      getCanceledAction: streamEntity => promise<option<actionEntity>>,
      getRenounceAction: streamEntity => promise<option<actionEntity>>,
      getBatch: streamEntity => promise<batchEntity>,
      set: streamEntity => unit,
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
      @as("Asset") asset: assetEntityHandlerContext,
      @as("Batch") batch: batchEntityHandlerContext,
      @as("Batcher") batcher: batcherEntityHandlerContext,
      @as("Contract") contract: contractEntityHandlerContext,
      @as("Segment") segment: segmentEntityHandlerContext,
      @as("Stream") stream: streamEntityHandlerContext,
      @as("Watcher") watcher: watcherEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Action") action: actionEntityHandlerContextAsync,
      @as("Asset") asset: assetEntityHandlerContextAsync,
      @as("Batch") batch: batchEntityHandlerContextAsync,
      @as("Batcher") batcher: batcherEntityHandlerContextAsync,
      @as("Contract") contract: contractEntityHandlerContextAsync,
      @as("Segment") segment: segmentEntityHandlerContextAsync,
      @as("Stream") stream: streamEntityHandlerContextAsync,
      @as("Watcher") watcher: watcherEntityHandlerContextAsync,
    }

    @genType
    type streamEntityLoaderContext = {load: (id, ~loaders: streamLoaderConfig=?) => unit}
    @genType
    type watcherEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addLockupV20: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addLockupV21: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Stream") stream: streamEntityLoaderContext,
      @as("Watcher") watcher: watcherEntityLoaderContext,
    }
  }
}

@deriving(accessors)
type event =
  | LockupV20Contract_Approval(eventLog<LockupV20Contract.ApprovalEvent.eventArgs>)
  | LockupV20Contract_ApprovalForAll(eventLog<LockupV20Contract.ApprovalForAllEvent.eventArgs>)
  | LockupV20Contract_CancelLockupStream(
      eventLog<LockupV20Contract.CancelLockupStreamEvent.eventArgs>,
    )
  | LockupV20Contract_CreateLockupLinearStream(
      eventLog<LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs>,
    )
  | LockupV20Contract_CreateLockupDynamicStream(
      eventLog<LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs>,
    )
  | LockupV20Contract_RenounceLockupStream(
      eventLog<LockupV20Contract.RenounceLockupStreamEvent.eventArgs>,
    )
  | LockupV20Contract_Transfer(eventLog<LockupV20Contract.TransferEvent.eventArgs>)
  | LockupV20Contract_TransferAdmin(eventLog<LockupV20Contract.TransferAdminEvent.eventArgs>)
  | LockupV20Contract_WithdrawFromLockupStream(
      eventLog<LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs>,
    )
  | LockupV21Contract_Approval(eventLog<LockupV21Contract.ApprovalEvent.eventArgs>)
  | LockupV21Contract_ApprovalForAll(eventLog<LockupV21Contract.ApprovalForAllEvent.eventArgs>)
  | LockupV21Contract_CancelLockupStream(
      eventLog<LockupV21Contract.CancelLockupStreamEvent.eventArgs>,
    )
  | LockupV21Contract_CreateLockupLinearStream(
      eventLog<LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs>,
    )
  | LockupV21Contract_CreateLockupDynamicStream(
      eventLog<LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs>,
    )
  | LockupV21Contract_RenounceLockupStream(
      eventLog<LockupV21Contract.RenounceLockupStreamEvent.eventArgs>,
    )
  | LockupV21Contract_Transfer(eventLog<LockupV21Contract.TransferEvent.eventArgs>)
  | LockupV21Contract_TransferAdmin(eventLog<LockupV21Contract.TransferAdminEvent.eventArgs>)
  | LockupV21Contract_WithdrawFromLockupStream(
      eventLog<LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs>,
    )

@spice
type eventName =
  | @spice.as("LockupV20_Approval") LockupV20_Approval
  | @spice.as("LockupV20_ApprovalForAll") LockupV20_ApprovalForAll
  | @spice.as("LockupV20_CancelLockupStream") LockupV20_CancelLockupStream
  | @spice.as("LockupV20_CreateLockupLinearStream") LockupV20_CreateLockupLinearStream
  | @spice.as("LockupV20_CreateLockupDynamicStream") LockupV20_CreateLockupDynamicStream
  | @spice.as("LockupV20_RenounceLockupStream") LockupV20_RenounceLockupStream
  | @spice.as("LockupV20_Transfer") LockupV20_Transfer
  | @spice.as("LockupV20_TransferAdmin") LockupV20_TransferAdmin
  | @spice.as("LockupV20_WithdrawFromLockupStream") LockupV20_WithdrawFromLockupStream
  | @spice.as("LockupV21_Approval") LockupV21_Approval
  | @spice.as("LockupV21_ApprovalForAll") LockupV21_ApprovalForAll
  | @spice.as("LockupV21_CancelLockupStream") LockupV21_CancelLockupStream
  | @spice.as("LockupV21_CreateLockupLinearStream") LockupV21_CreateLockupLinearStream
  | @spice.as("LockupV21_CreateLockupDynamicStream") LockupV21_CreateLockupDynamicStream
  | @spice.as("LockupV21_RenounceLockupStream") LockupV21_RenounceLockupStream
  | @spice.as("LockupV21_Transfer") LockupV21_Transfer
  | @spice.as("LockupV21_TransferAdmin") LockupV21_TransferAdmin
  | @spice.as("LockupV21_WithdrawFromLockupStream") LockupV21_WithdrawFromLockupStream

let eventNameToString = (eventName: eventName) =>
  switch eventName {
  | LockupV20_Approval => "Approval"
  | LockupV20_ApprovalForAll => "ApprovalForAll"
  | LockupV20_CancelLockupStream => "CancelLockupStream"
  | LockupV20_CreateLockupLinearStream => "CreateLockupLinearStream"
  | LockupV20_CreateLockupDynamicStream => "CreateLockupDynamicStream"
  | LockupV20_RenounceLockupStream => "RenounceLockupStream"
  | LockupV20_Transfer => "Transfer"
  | LockupV20_TransferAdmin => "TransferAdmin"
  | LockupV20_WithdrawFromLockupStream => "WithdrawFromLockupStream"
  | LockupV21_Approval => "Approval"
  | LockupV21_ApprovalForAll => "ApprovalForAll"
  | LockupV21_CancelLockupStream => "CancelLockupStream"
  | LockupV21_CreateLockupLinearStream => "CreateLockupLinearStream"
  | LockupV21_CreateLockupDynamicStream => "CreateLockupDynamicStream"
  | LockupV21_RenounceLockupStream => "RenounceLockupStream"
  | LockupV21_Transfer => "Transfer"
  | LockupV21_TransferAdmin => "TransferAdmin"
  | LockupV21_WithdrawFromLockupStream => "WithdrawFromLockupStream"
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
