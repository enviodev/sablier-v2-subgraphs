/* TypeScript file generated from Types.res by genType. */
/* eslint-disable import/first */


import type {BigInt_t as Ethers_BigInt_t} from '../src/bindings/Ethers.gen';

import type {Json_t as Js_Json_t} from '../src/Js.shim';

import type {Nullable as $$nullable} from './bindings/OpaqueTypes';

import type {ethAddress as Ethers_ethAddress} from '../src/bindings/Ethers.gen';

import type {userLogger as Logs_userLogger} from './Logs.gen';

// tslint:disable-next-line:interface-over-type-literal
export type id = string;
export type Id = id;

// tslint:disable-next-line:interface-over-type-literal
export type nullable<a> = $$nullable<a>;

// tslint:disable-next-line:interface-over-type-literal
export type actionLoaderConfig = { readonly loadContract?: contractLoaderConfig; readonly loadStream?: streamLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type assetLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type batchLoaderConfig = { readonly loadBatcher?: batcherLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type batcherLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type contractLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type segmentLoaderConfig = { readonly loadStream?: streamLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type streamLoaderConfig = {
  readonly loadAsset?: assetLoaderConfig; 
  readonly loadContract?: contractLoaderConfig; 
  readonly loadCanceledAction?: actionLoaderConfig; 
  readonly loadRenounceAction?: actionLoaderConfig; 
  readonly loadBatch?: batchLoaderConfig
};

// tslint:disable-next-line:interface-over-type-literal
export type entityRead = 
    { tag: "ActionRead"; value: [id, actionLoaderConfig] }
  | { tag: "AssetRead"; value: id }
  | { tag: "BatchRead"; value: [id, batchLoaderConfig] }
  | { tag: "BatcherRead"; value: id }
  | { tag: "ContractRead"; value: id }
  | { tag: "SegmentRead"; value: [id, segmentLoaderConfig] }
  | { tag: "StreamRead"; value: [id, streamLoaderConfig] }
  | { tag: "WatcherRead"; value: id };

// tslint:disable-next-line:interface-over-type-literal
export type rawEventsEntity = {
  readonly chain_id: number; 
  readonly event_id: string; 
  readonly block_number: number; 
  readonly log_index: number; 
  readonly transaction_index: number; 
  readonly transaction_hash: string; 
  readonly src_address: Ethers_ethAddress; 
  readonly block_hash: string; 
  readonly block_timestamp: number; 
  readonly event_type: Js_Json_t; 
  readonly params: string
};

// tslint:disable-next-line:interface-over-type-literal
export type dynamicContractRegistryEntity = {
  readonly chain_id: number; 
  readonly event_id: Ethers_BigInt_t; 
  readonly contract_address: Ethers_ethAddress; 
  readonly contract_type: string
};

// tslint:disable-next-line:interface-over-type-literal
export type actionEntity = {
  readonly id: id; 
  readonly addressA: nullable<string>; 
  readonly addressB: nullable<string>; 
  readonly amountA: nullable<Ethers_BigInt_t>; 
  readonly amountB: nullable<Ethers_BigInt_t>; 
  readonly block: Ethers_BigInt_t; 
  readonly category: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly contract: id; 
  readonly hash: string; 
  readonly from: string; 
  readonly stream: nullable<id>; 
  readonly subgraphId: Ethers_BigInt_t; 
  readonly timestamp: Ethers_BigInt_t
};
export type ActionEntity = actionEntity;

// tslint:disable-next-line:interface-over-type-literal
export type assetEntity = {
  readonly id: id; 
  readonly address: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly decimals: Ethers_BigInt_t; 
  readonly name: string; 
  readonly symbol: string
};
export type AssetEntity = assetEntity;

// tslint:disable-next-line:interface-over-type-literal
export type batchEntity = {
  readonly id: string; 
  readonly size: Ethers_BigInt_t; 
  readonly label: nullable<string>; 
  readonly batcher: nullable<id>; 
  readonly hash: string; 
  readonly timestamp: Ethers_BigInt_t
};
export type BatchEntity = batchEntity;

// tslint:disable-next-line:interface-over-type-literal
export type batcherEntity = {
  readonly id: string; 
  readonly address: string; 
  readonly batchIndex: Ethers_BigInt_t
};
export type BatcherEntity = batcherEntity;

// tslint:disable-next-line:interface-over-type-literal
export type contractEntity = {
  readonly id: id; 
  readonly address: string; 
  readonly admin: nullable<string>; 
  readonly alias: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly category: string; 
  readonly version: string
};
export type ContractEntity = contractEntity;

// tslint:disable-next-line:interface-over-type-literal
export type segmentEntity = {
  readonly id: id; 
  readonly position: Ethers_BigInt_t; 
  readonly stream: id; 
  readonly amount: Ethers_BigInt_t; 
  readonly exponent: Ethers_BigInt_t; 
  readonly milestone: Ethers_BigInt_t; 
  readonly endTime: Ethers_BigInt_t; 
  readonly startTime: Ethers_BigInt_t; 
  readonly startAmount: Ethers_BigInt_t; 
  readonly endAmount: Ethers_BigInt_t
};
export type SegmentEntity = segmentEntity;

// tslint:disable-next-line:interface-over-type-literal
export type streamEntity = {
  readonly id: id; 
  readonly alias: string; 
  readonly subgraphId: Ethers_BigInt_t; 
  readonly tokenId: Ethers_BigInt_t; 
  readonly version: string; 
  readonly asset: id; 
  readonly category: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly contract: id; 
  readonly hash: string; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly funder: string; 
  readonly sender: string; 
  readonly recipient: string; 
  readonly parties: string[]; 
  readonly proxender: nullable<string>; 
  readonly proxied: boolean; 
  readonly cliff: boolean; 
  readonly cancelable: boolean; 
  readonly canceled: boolean; 
  readonly transferable: boolean; 
  readonly canceledAction: nullable<id>; 
  readonly renounceAction: nullable<id>; 
  readonly renounceTime: nullable<Ethers_BigInt_t>; 
  readonly canceledTime: nullable<Ethers_BigInt_t>; 
  readonly cliffTime: nullable<Ethers_BigInt_t>; 
  readonly endTime: Ethers_BigInt_t; 
  readonly startTime: Ethers_BigInt_t; 
  readonly duration: Ethers_BigInt_t; 
  readonly brokerFeeAmount: Ethers_BigInt_t; 
  readonly cliffAmount: nullable<Ethers_BigInt_t>; 
  readonly depositAmount: Ethers_BigInt_t; 
  readonly intactAmount: Ethers_BigInt_t; 
  readonly protocolFeeAmount: Ethers_BigInt_t; 
  readonly withdrawnAmount: Ethers_BigInt_t; 
  readonly batch: id; 
  readonly position: Ethers_BigInt_t
};
export type StreamEntity = streamEntity;

// tslint:disable-next-line:interface-over-type-literal
export type watcherEntity = {
  readonly id: id; 
  readonly chainId: Ethers_BigInt_t; 
  readonly streamIndex: Ethers_BigInt_t; 
  readonly actionIndex: Ethers_BigInt_t; 
  readonly initialized: boolean; 
  readonly logs: string[]
};
export type WatcherEntity = watcherEntity;

// tslint:disable-next-line:interface-over-type-literal
export type dbOp = "Read" | "Set" | "Delete";

// tslint:disable-next-line:interface-over-type-literal
export type inMemoryStoreRow<a> = { readonly dbOp: dbOp; readonly entity: a };

// tslint:disable-next-line:interface-over-type-literal
export type eventLog<a> = {
  readonly params: a; 
  readonly chainId: number; 
  readonly blockNumber: number; 
  readonly blockTimestamp: number; 
  readonly blockHash: string; 
  readonly srcAddress: Ethers_ethAddress; 
  readonly transactionHash: string; 
  readonly transactionIndex: number; 
  readonly logIndex: number
};
export type EventLog<a> = eventLog<a>;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_eventArgs = {
  readonly owner: Ethers_ethAddress; 
  readonly approved: Ethers_ethAddress; 
  readonly tokenId: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_log = eventLog<LockupV20Contract_ApprovalEvent_eventArgs>;
export type LockupV20Contract_Approval_EventLog = LockupV20Contract_ApprovalEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_ApprovalEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_ApprovalEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_ApprovalEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_ApprovalEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_ApprovalEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_ApprovalEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_ApprovalEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_ApprovalEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_ApprovalEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_ApprovalEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_ApprovalEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_ApprovalEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_ApprovalEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_ApprovalEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_ApprovalEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_ApprovalEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_ApprovalEvent_contractRegistrations; 
  readonly Stream: LockupV20Contract_ApprovalEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_ApprovalEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_eventArgs = {
  readonly owner: Ethers_ethAddress; 
  readonly operator: Ethers_ethAddress; 
  readonly approved: boolean
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_log = eventLog<LockupV20Contract_ApprovalForAllEvent_eventArgs>;
export type LockupV20Contract_ApprovalForAll_EventLog = LockupV20Contract_ApprovalForAllEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_ApprovalForAllEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_ApprovalForAllEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_ApprovalForAllEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_ApprovalForAllEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_ApprovalForAllEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_ApprovalForAllEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_ApprovalForAllEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_ApprovalForAllEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_ApprovalForAllEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_ApprovalForAllEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_ApprovalForAllEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_ApprovalForAllEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_ApprovalForAllEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_ApprovalForAllEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_ApprovalForAllEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_ApprovalForAllEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_ApprovalForAllEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_ApprovalForAllEvent_contractRegistrations; 
  readonly Watcher: LockupV20Contract_ApprovalForAllEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly sender: Ethers_ethAddress; 
  readonly recipient: Ethers_ethAddress; 
  readonly senderAmount: Ethers_BigInt_t; 
  readonly recipientAmount: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_log = eventLog<LockupV20Contract_CancelLockupStreamEvent_eventArgs>;
export type LockupV20Contract_CancelLockupStream_EventLog = LockupV20Contract_CancelLockupStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_CancelLockupStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_CancelLockupStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_CancelLockupStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_CancelLockupStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_CancelLockupStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_CancelLockupStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_CancelLockupStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_CancelLockupStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_CancelLockupStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_CancelLockupStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_CancelLockupStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_CancelLockupStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_CancelLockupStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_CancelLockupStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_CancelLockupStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_CancelLockupStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CancelLockupStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_CancelLockupStreamEvent_contractRegistrations; 
  readonly Stream: LockupV20Contract_CancelLockupStreamEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_CancelLockupStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly funder: Ethers_ethAddress; 
  readonly sender: Ethers_ethAddress; 
  readonly recipient: Ethers_ethAddress; 
  readonly amounts: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset: Ethers_ethAddress; 
  readonly cancelable: boolean; 
  readonly range: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker: Ethers_ethAddress
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_log = eventLog<LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs>;
export type LockupV20Contract_CreateLockupLinearStream_EventLog = LockupV20Contract_CreateLockupLinearStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | assetEntity); 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | assetEntity)>; 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batchEntity); 
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batchEntity)>; 
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batcherEntity); 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | contractEntity); 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | contractEntity)>; 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_assetEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_batchEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: batchLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_batcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_contractEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupLinearStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_CreateLockupLinearStreamEvent_contractRegistrations; 
  readonly Asset: LockupV20Contract_CreateLockupLinearStreamEvent_assetEntityLoaderContext; 
  readonly Batch: LockupV20Contract_CreateLockupLinearStreamEvent_batchEntityLoaderContext; 
  readonly Batcher: LockupV20Contract_CreateLockupLinearStreamEvent_batcherEntityLoaderContext; 
  readonly Contract: LockupV20Contract_CreateLockupLinearStreamEvent_contractEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_CreateLockupLinearStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly funder: Ethers_ethAddress; 
  readonly sender: Ethers_ethAddress; 
  readonly recipient: Ethers_ethAddress; 
  readonly amounts: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset: Ethers_ethAddress; 
  readonly cancelable: boolean; 
  readonly segments: Array<[Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]>; 
  readonly range: [Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker: Ethers_ethAddress
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_log = eventLog<LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs>;
export type LockupV20Contract_CreateLockupDynamicStream_EventLog = LockupV20Contract_CreateLockupDynamicStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | assetEntity); 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | assetEntity)>; 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batchEntity); 
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batchEntity)>; 
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batcherEntity); 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | contractEntity); 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | contractEntity)>; 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_assetEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_batchEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: batchLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_batcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_contractEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_CreateLockupDynamicStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_CreateLockupDynamicStreamEvent_contractRegistrations; 
  readonly Asset: LockupV20Contract_CreateLockupDynamicStreamEvent_assetEntityLoaderContext; 
  readonly Batch: LockupV20Contract_CreateLockupDynamicStreamEvent_batchEntityLoaderContext; 
  readonly Batcher: LockupV20Contract_CreateLockupDynamicStreamEvent_batcherEntityLoaderContext; 
  readonly Contract: LockupV20Contract_CreateLockupDynamicStreamEvent_contractEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_CreateLockupDynamicStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_eventArgs = { readonly streamId: Ethers_BigInt_t };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_log = eventLog<LockupV20Contract_RenounceLockupStreamEvent_eventArgs>;
export type LockupV20Contract_RenounceLockupStream_EventLog = LockupV20Contract_RenounceLockupStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_RenounceLockupStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_RenounceLockupStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_RenounceLockupStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_RenounceLockupStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_RenounceLockupStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_RenounceLockupStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_RenounceLockupStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_RenounceLockupStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_RenounceLockupStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_RenounceLockupStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_RenounceLockupStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_RenounceLockupStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_RenounceLockupStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_RenounceLockupStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_RenounceLockupStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_RenounceLockupStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_RenounceLockupStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_RenounceLockupStreamEvent_contractRegistrations; 
  readonly Stream: LockupV20Contract_RenounceLockupStreamEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_RenounceLockupStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_eventArgs = {
  readonly from: Ethers_ethAddress; 
  readonly to: Ethers_ethAddress; 
  readonly tokenId: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_log = eventLog<LockupV20Contract_TransferEvent_eventArgs>;
export type LockupV20Contract_Transfer_EventLog = LockupV20Contract_TransferEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_TransferEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_TransferEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_TransferEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_TransferEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_TransferEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_TransferEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_TransferEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_TransferEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_TransferEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_TransferEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_TransferEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_TransferEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_TransferEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_TransferEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_TransferEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_TransferEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_TransferEvent_contractRegistrations; 
  readonly Stream: LockupV20Contract_TransferEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_TransferEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_eventArgs = { readonly oldAdmin: Ethers_ethAddress; readonly newAdmin: Ethers_ethAddress };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_log = eventLog<LockupV20Contract_TransferAdminEvent_eventArgs>;
export type LockupV20Contract_TransferAdmin_EventLog = LockupV20Contract_TransferAdminEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_contractEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | contractEntity); 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_contractEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | contractEntity)>; 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_TransferAdminEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_TransferAdminEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_TransferAdminEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_TransferAdminEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_TransferAdminEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_TransferAdminEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_TransferAdminEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_TransferAdminEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_TransferAdminEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_TransferAdminEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_TransferAdminEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_TransferAdminEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_TransferAdminEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_TransferAdminEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_TransferAdminEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_TransferAdminEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_contractEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_TransferAdminEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_TransferAdminEvent_contractRegistrations; 
  readonly Contract: LockupV20Contract_TransferAdminEvent_contractEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_TransferAdminEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly to: Ethers_ethAddress; 
  readonly amount: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_log = eventLog<LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs>;
export type LockupV20Contract_WithdrawFromLockupStream_EventLog = LockupV20Contract_WithdrawFromLockupStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV20Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV20Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV20Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV20Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV20Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV20Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV20Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV20Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV20Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV20Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV20Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV20Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV20Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV20Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV20Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20Contract_WithdrawFromLockupStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV20Contract_WithdrawFromLockupStreamEvent_contractRegistrations; 
  readonly Stream: LockupV20Contract_WithdrawFromLockupStreamEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV20Contract_WithdrawFromLockupStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_eventArgs = {
  readonly owner: Ethers_ethAddress; 
  readonly approved: Ethers_ethAddress; 
  readonly tokenId: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_log = eventLog<LockupV21Contract_ApprovalEvent_eventArgs>;
export type LockupV21Contract_Approval_EventLog = LockupV21Contract_ApprovalEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_ApprovalEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_ApprovalEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_ApprovalEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_ApprovalEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_ApprovalEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_ApprovalEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_ApprovalEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_ApprovalEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_ApprovalEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_ApprovalEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_ApprovalEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_ApprovalEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_ApprovalEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_ApprovalEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_ApprovalEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_ApprovalEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_ApprovalEvent_contractRegistrations; 
  readonly Stream: LockupV21Contract_ApprovalEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_ApprovalEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_eventArgs = {
  readonly owner: Ethers_ethAddress; 
  readonly operator: Ethers_ethAddress; 
  readonly approved: boolean
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_log = eventLog<LockupV21Contract_ApprovalForAllEvent_eventArgs>;
export type LockupV21Contract_ApprovalForAll_EventLog = LockupV21Contract_ApprovalForAllEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_ApprovalForAllEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_ApprovalForAllEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_ApprovalForAllEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_ApprovalForAllEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_ApprovalForAllEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_ApprovalForAllEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_ApprovalForAllEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_ApprovalForAllEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_ApprovalForAllEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_ApprovalForAllEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_ApprovalForAllEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_ApprovalForAllEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_ApprovalForAllEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_ApprovalForAllEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_ApprovalForAllEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_ApprovalForAllEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_ApprovalForAllEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_ApprovalForAllEvent_contractRegistrations; 
  readonly Watcher: LockupV21Contract_ApprovalForAllEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly sender: Ethers_ethAddress; 
  readonly recipient: Ethers_ethAddress; 
  readonly asset: Ethers_ethAddress; 
  readonly senderAmount: Ethers_BigInt_t; 
  readonly recipientAmount: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_log = eventLog<LockupV21Contract_CancelLockupStreamEvent_eventArgs>;
export type LockupV21Contract_CancelLockupStream_EventLog = LockupV21Contract_CancelLockupStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_CancelLockupStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_CancelLockupStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_CancelLockupStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_CancelLockupStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_CancelLockupStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_CancelLockupStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_CancelLockupStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_CancelLockupStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_CancelLockupStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_CancelLockupStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_CancelLockupStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_CancelLockupStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_CancelLockupStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_CancelLockupStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_CancelLockupStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_CancelLockupStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CancelLockupStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_CancelLockupStreamEvent_contractRegistrations; 
  readonly Stream: LockupV21Contract_CancelLockupStreamEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_CancelLockupStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly funder: Ethers_ethAddress; 
  readonly sender: Ethers_ethAddress; 
  readonly recipient: Ethers_ethAddress; 
  readonly amounts: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset: Ethers_ethAddress; 
  readonly cancelable: boolean; 
  readonly transferable: boolean; 
  readonly range: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker: Ethers_ethAddress
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_log = eventLog<LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs>;
export type LockupV21Contract_CreateLockupLinearStream_EventLog = LockupV21Contract_CreateLockupLinearStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | assetEntity); 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | assetEntity)>; 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batchEntity); 
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batchEntity)>; 
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batcherEntity); 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | contractEntity); 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | contractEntity)>; 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_CreateLockupLinearStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_CreateLockupLinearStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_CreateLockupLinearStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_CreateLockupLinearStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_CreateLockupLinearStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_CreateLockupLinearStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_CreateLockupLinearStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_CreateLockupLinearStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_assetEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_batchEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: batchLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_batcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_contractEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupLinearStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_CreateLockupLinearStreamEvent_contractRegistrations; 
  readonly Asset: LockupV21Contract_CreateLockupLinearStreamEvent_assetEntityLoaderContext; 
  readonly Batch: LockupV21Contract_CreateLockupLinearStreamEvent_batchEntityLoaderContext; 
  readonly Batcher: LockupV21Contract_CreateLockupLinearStreamEvent_batcherEntityLoaderContext; 
  readonly Contract: LockupV21Contract_CreateLockupLinearStreamEvent_contractEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_CreateLockupLinearStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly funder: Ethers_ethAddress; 
  readonly sender: Ethers_ethAddress; 
  readonly recipient: Ethers_ethAddress; 
  readonly amounts: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset: Ethers_ethAddress; 
  readonly cancelable: boolean; 
  readonly transferable: boolean; 
  readonly segments: Array<[Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]>; 
  readonly range: [Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker: Ethers_ethAddress
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_log = eventLog<LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs>;
export type LockupV21Contract_CreateLockupDynamicStream_EventLog = LockupV21Contract_CreateLockupDynamicStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | assetEntity); 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | assetEntity)>; 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batchEntity); 
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batchEntity)>; 
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | batcherEntity); 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | contractEntity); 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | contractEntity)>; 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_CreateLockupDynamicStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_CreateLockupDynamicStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_CreateLockupDynamicStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_CreateLockupDynamicStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_CreateLockupDynamicStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_CreateLockupDynamicStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_CreateLockupDynamicStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_CreateLockupDynamicStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_assetEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_batchEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: batchLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_batcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_contractEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_CreateLockupDynamicStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_CreateLockupDynamicStreamEvent_contractRegistrations; 
  readonly Asset: LockupV21Contract_CreateLockupDynamicStreamEvent_assetEntityLoaderContext; 
  readonly Batch: LockupV21Contract_CreateLockupDynamicStreamEvent_batchEntityLoaderContext; 
  readonly Batcher: LockupV21Contract_CreateLockupDynamicStreamEvent_batcherEntityLoaderContext; 
  readonly Contract: LockupV21Contract_CreateLockupDynamicStreamEvent_contractEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_CreateLockupDynamicStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_eventArgs = { readonly streamId: Ethers_BigInt_t };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_log = eventLog<LockupV21Contract_RenounceLockupStreamEvent_eventArgs>;
export type LockupV21Contract_RenounceLockupStream_EventLog = LockupV21Contract_RenounceLockupStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_RenounceLockupStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_RenounceLockupStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_RenounceLockupStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_RenounceLockupStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_RenounceLockupStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_RenounceLockupStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_RenounceLockupStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_RenounceLockupStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_RenounceLockupStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_RenounceLockupStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_RenounceLockupStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_RenounceLockupStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_RenounceLockupStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_RenounceLockupStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_RenounceLockupStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_RenounceLockupStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_RenounceLockupStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_RenounceLockupStreamEvent_contractRegistrations; 
  readonly Stream: LockupV21Contract_RenounceLockupStreamEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_RenounceLockupStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_eventArgs = {
  readonly from: Ethers_ethAddress; 
  readonly to: Ethers_ethAddress; 
  readonly tokenId: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_log = eventLog<LockupV21Contract_TransferEvent_eventArgs>;
export type LockupV21Contract_Transfer_EventLog = LockupV21Contract_TransferEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_TransferEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_TransferEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_TransferEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_TransferEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_TransferEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_TransferEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_TransferEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_TransferEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_TransferEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_TransferEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_TransferEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_TransferEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_TransferEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_TransferEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_TransferEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_TransferEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_TransferEvent_contractRegistrations; 
  readonly Stream: LockupV21Contract_TransferEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_TransferEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_eventArgs = { readonly oldAdmin: Ethers_ethAddress; readonly newAdmin: Ethers_ethAddress };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_log = eventLog<LockupV21Contract_TransferAdminEvent_eventArgs>;
export type LockupV21Contract_TransferAdmin_EventLog = LockupV21Contract_TransferAdminEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_contractEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | contractEntity); 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_contractEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | contractEntity)>; 
  readonly set: (_1:contractEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_streamEntityHandlerContext = {
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_streamEntityHandlerContextAsync = {
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_TransferAdminEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_TransferAdminEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_TransferAdminEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_TransferAdminEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_TransferAdminEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_TransferAdminEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_TransferAdminEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_TransferAdminEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_TransferAdminEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_TransferAdminEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_TransferAdminEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_TransferAdminEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_TransferAdminEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_TransferAdminEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_TransferAdminEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_TransferAdminEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_contractEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_TransferAdminEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_TransferAdminEvent_contractRegistrations; 
  readonly Contract: LockupV21Contract_TransferAdminEvent_contractEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_TransferAdminEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs = {
  readonly streamId: Ethers_BigInt_t; 
  readonly to: Ethers_ethAddress; 
  readonly asset: Ethers_ethAddress; 
  readonly amount: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_log = eventLog<LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs>;
export type LockupV21Contract_WithdrawFromLockupStream_EventLog = LockupV21Contract_WithdrawFromLockupStreamEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContext = {
  readonly getContract: (_1:actionEntity) => contractEntity; 
  readonly getStream: (_1:actionEntity) => (undefined | streamEntity); 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContextAsync = {
  readonly getContract: (_1:actionEntity) => Promise<contractEntity>; 
  readonly getStream: (_1:actionEntity) => Promise<(undefined | streamEntity)>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContext = {
  readonly getBatcher: (_1:batchEntity) => (undefined | batcherEntity); 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContextAsync = {
  readonly getBatcher: (_1:batchEntity) => Promise<(undefined | batcherEntity)>; 
  readonly set: (_1:batchEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContext = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContextAsync = { readonly set: (_1:batcherEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContext = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContextAsync = { readonly set: (_1:contractEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContext = {
  readonly getStream: (_1:segmentEntity) => streamEntity; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContextAsync = {
  readonly getStream: (_1:segmentEntity) => Promise<streamEntity>; 
  readonly set: (_1:segmentEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | streamEntity); 
  readonly getAsset: (_1:streamEntity) => assetEntity; 
  readonly getContract: (_1:streamEntity) => contractEntity; 
  readonly getCanceledAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getRenounceAction: (_1:streamEntity) => (undefined | actionEntity); 
  readonly getBatch: (_1:streamEntity) => batchEntity; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | streamEntity)>; 
  readonly getAsset: (_1:streamEntity) => Promise<assetEntity>; 
  readonly getContract: (_1:streamEntity) => Promise<contractEntity>; 
  readonly getCanceledAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getRenounceAction: (_1:streamEntity) => Promise<(undefined | actionEntity)>; 
  readonly getBatch: (_1:streamEntity) => Promise<batchEntity>; 
  readonly set: (_1:streamEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContext; 
  readonly Asset: LockupV21Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContext; 
  readonly Batch: LockupV21Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContext; 
  readonly Batcher: LockupV21Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContext; 
  readonly Contract: LockupV21Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContext; 
  readonly Segment: LockupV21Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContext; 
  readonly Stream: LockupV21Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContext; 
  readonly Watcher: LockupV21Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: LockupV21Contract_WithdrawFromLockupStreamEvent_actionEntityHandlerContextAsync; 
  readonly Asset: LockupV21Contract_WithdrawFromLockupStreamEvent_assetEntityHandlerContextAsync; 
  readonly Batch: LockupV21Contract_WithdrawFromLockupStreamEvent_batchEntityHandlerContextAsync; 
  readonly Batcher: LockupV21Contract_WithdrawFromLockupStreamEvent_batcherEntityHandlerContextAsync; 
  readonly Contract: LockupV21Contract_WithdrawFromLockupStreamEvent_contractEntityHandlerContextAsync; 
  readonly Segment: LockupV21Contract_WithdrawFromLockupStreamEvent_segmentEntityHandlerContextAsync; 
  readonly Stream: LockupV21Contract_WithdrawFromLockupStreamEvent_streamEntityHandlerContextAsync; 
  readonly Watcher: LockupV21Contract_WithdrawFromLockupStreamEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_streamEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: streamLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_contractRegistrations = { readonly addLockupV20: (_1:Ethers_ethAddress) => void; readonly addLockupV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21Contract_WithdrawFromLockupStreamEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: LockupV21Contract_WithdrawFromLockupStreamEvent_contractRegistrations; 
  readonly Stream: LockupV21Contract_WithdrawFromLockupStreamEvent_streamEntityLoaderContext; 
  readonly Watcher: LockupV21Contract_WithdrawFromLockupStreamEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type chainId = number;
