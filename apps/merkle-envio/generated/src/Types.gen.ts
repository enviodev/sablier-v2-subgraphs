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
export type actionLoaderConfig = { readonly loadCampaign?: campaignLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type activityLoaderConfig = { readonly loadCampaign?: campaignLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type assetLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type campaignLoaderConfig = {
  readonly loadAsset?: assetLoaderConfig; 
  readonly loadFactory?: factoryLoaderConfig; 
  readonly loadClawbackAction?: actionLoaderConfig
};

// tslint:disable-next-line:interface-over-type-literal
export type factoryLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type entityRead = 
    { tag: "ActionRead"; value: [id, actionLoaderConfig] }
  | { tag: "ActivityRead"; value: [id, activityLoaderConfig] }
  | { tag: "AssetRead"; value: id }
  | { tag: "CampaignRead"; value: [id, campaignLoaderConfig] }
  | { tag: "FactoryRead"; value: id }
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
  readonly id: string; 
  readonly block: Ethers_BigInt_t; 
  readonly category: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly campaign: id; 
  readonly hash: string; 
  readonly from: string; 
  readonly subgraphId: Ethers_BigInt_t; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly claimStreamId: nullable<string>; 
  readonly claimTokenId: nullable<Ethers_BigInt_t>; 
  readonly claimAmount: nullable<Ethers_BigInt_t>; 
  readonly claimIndex: nullable<Ethers_BigInt_t>; 
  readonly claimRecipient: nullable<string>; 
  readonly clawbackAmount: nullable<Ethers_BigInt_t>; 
  readonly clawbackFrom: nullable<string>; 
  readonly clawbackTo: nullable<string>
};
export type ActionEntity = actionEntity;

// tslint:disable-next-line:interface-over-type-literal
export type activityEntity = {
  readonly id: string; 
  readonly campaign: id; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly day: Ethers_BigInt_t; 
  readonly amount: Ethers_BigInt_t; 
  readonly claims: Ethers_BigInt_t
};
export type ActivityEntity = activityEntity;

// tslint:disable-next-line:interface-over-type-literal
export type assetEntity = {
  readonly id: string; 
  readonly address: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly decimals: Ethers_BigInt_t; 
  readonly name: string; 
  readonly symbol: string
};
export type AssetEntity = assetEntity;

// tslint:disable-next-line:interface-over-type-literal
export type campaignEntity = {
  readonly id: string; 
  readonly subgraphId: Ethers_BigInt_t; 
  readonly address: string; 
  readonly asset: id; 
  readonly factory: id; 
  readonly chainId: Ethers_BigInt_t; 
  readonly hash: string; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly category: string; 
  readonly admin: string; 
  readonly lockup: string; 
  readonly root: string; 
  readonly expires: boolean; 
  readonly expiration: nullable<Ethers_BigInt_t>; 
  readonly ipfsCID: string; 
  readonly aggregateAmount: Ethers_BigInt_t; 
  readonly totalRecipients: Ethers_BigInt_t; 
  readonly clawbackAction: nullable<id>; 
  readonly clawbackTime: nullable<Ethers_BigInt_t>; 
  readonly streamCliff: boolean; 
  readonly streamCliffDuration: nullable<Ethers_BigInt_t>; 
  readonly streamTotalDuration: Ethers_BigInt_t; 
  readonly streamCancelable: boolean; 
  readonly streamTransferable: boolean; 
  readonly claimedAmount: Ethers_BigInt_t; 
  readonly claimedCount: Ethers_BigInt_t; 
  readonly version: string
};
export type CampaignEntity = campaignEntity;

// tslint:disable-next-line:interface-over-type-literal
export type factoryEntity = {
  readonly id: string; 
  readonly alias: string; 
  readonly address: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly version: string
};
export type FactoryEntity = factoryEntity;

// tslint:disable-next-line:interface-over-type-literal
export type watcherEntity = {
  readonly id: string; 
  readonly chainId: Ethers_BigInt_t; 
  readonly actionIndex: Ethers_BigInt_t; 
  readonly campaignIndex: Ethers_BigInt_t; 
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
export type MerkleLLV21Contract_ClaimEvent_eventArgs = {
  readonly index: Ethers_BigInt_t; 
  readonly recipient: Ethers_ethAddress; 
  readonly amount: Ethers_BigInt_t; 
  readonly streamId: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_log = eventLog<MerkleLLV21Contract_ClaimEvent_eventArgs>;
export type MerkleLLV21Contract_Claim_EventLog = MerkleLLV21Contract_ClaimEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_actionEntityHandlerContext = {
  readonly getCampaign: (_1:actionEntity) => campaignEntity; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_actionEntityHandlerContextAsync = {
  readonly getCampaign: (_1:actionEntity) => Promise<campaignEntity>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_activityEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | activityEntity); 
  readonly getCampaign: (_1:activityEntity) => campaignEntity; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_activityEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | activityEntity)>; 
  readonly getCampaign: (_1:activityEntity) => Promise<campaignEntity>; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_campaignEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | campaignEntity); 
  readonly getAsset: (_1:campaignEntity) => assetEntity; 
  readonly getFactory: (_1:campaignEntity) => factoryEntity; 
  readonly getClawbackAction: (_1:campaignEntity) => (undefined | actionEntity); 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_campaignEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | campaignEntity)>; 
  readonly getAsset: (_1:campaignEntity) => Promise<assetEntity>; 
  readonly getFactory: (_1:campaignEntity) => Promise<factoryEntity>; 
  readonly getClawbackAction: (_1:campaignEntity) => Promise<(undefined | actionEntity)>; 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_factoryEntityHandlerContext = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_factoryEntityHandlerContextAsync = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLLV21Contract_ClaimEvent_actionEntityHandlerContext; 
  readonly Activity: MerkleLLV21Contract_ClaimEvent_activityEntityHandlerContext; 
  readonly Asset: MerkleLLV21Contract_ClaimEvent_assetEntityHandlerContext; 
  readonly Campaign: MerkleLLV21Contract_ClaimEvent_campaignEntityHandlerContext; 
  readonly Factory: MerkleLLV21Contract_ClaimEvent_factoryEntityHandlerContext; 
  readonly Watcher: MerkleLLV21Contract_ClaimEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLLV21Contract_ClaimEvent_actionEntityHandlerContextAsync; 
  readonly Activity: MerkleLLV21Contract_ClaimEvent_activityEntityHandlerContextAsync; 
  readonly Asset: MerkleLLV21Contract_ClaimEvent_assetEntityHandlerContextAsync; 
  readonly Campaign: MerkleLLV21Contract_ClaimEvent_campaignEntityHandlerContextAsync; 
  readonly Factory: MerkleLLV21Contract_ClaimEvent_factoryEntityHandlerContextAsync; 
  readonly Watcher: MerkleLLV21Contract_ClaimEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_activityEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: activityLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_campaignEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: campaignLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_contractRegistrations = { readonly addMerkleLLV21: (_1:Ethers_ethAddress) => void; readonly addMerkleLockupFactoryV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClaimEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: MerkleLLV21Contract_ClaimEvent_contractRegistrations; 
  readonly Activity: MerkleLLV21Contract_ClaimEvent_activityEntityLoaderContext; 
  readonly Campaign: MerkleLLV21Contract_ClaimEvent_campaignEntityLoaderContext; 
  readonly Watcher: MerkleLLV21Contract_ClaimEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_eventArgs = {
  readonly admin: Ethers_ethAddress; 
  readonly to: Ethers_ethAddress; 
  readonly amount: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_log = eventLog<MerkleLLV21Contract_ClawbackEvent_eventArgs>;
export type MerkleLLV21Contract_Clawback_EventLog = MerkleLLV21Contract_ClawbackEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_actionEntityHandlerContext = {
  readonly getCampaign: (_1:actionEntity) => campaignEntity; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_actionEntityHandlerContextAsync = {
  readonly getCampaign: (_1:actionEntity) => Promise<campaignEntity>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_activityEntityHandlerContext = {
  readonly getCampaign: (_1:activityEntity) => campaignEntity; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_activityEntityHandlerContextAsync = {
  readonly getCampaign: (_1:activityEntity) => Promise<campaignEntity>; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_campaignEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | campaignEntity); 
  readonly getAsset: (_1:campaignEntity) => assetEntity; 
  readonly getFactory: (_1:campaignEntity) => factoryEntity; 
  readonly getClawbackAction: (_1:campaignEntity) => (undefined | actionEntity); 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_campaignEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | campaignEntity)>; 
  readonly getAsset: (_1:campaignEntity) => Promise<assetEntity>; 
  readonly getFactory: (_1:campaignEntity) => Promise<factoryEntity>; 
  readonly getClawbackAction: (_1:campaignEntity) => Promise<(undefined | actionEntity)>; 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_factoryEntityHandlerContext = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_factoryEntityHandlerContextAsync = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLLV21Contract_ClawbackEvent_actionEntityHandlerContext; 
  readonly Activity: MerkleLLV21Contract_ClawbackEvent_activityEntityHandlerContext; 
  readonly Asset: MerkleLLV21Contract_ClawbackEvent_assetEntityHandlerContext; 
  readonly Campaign: MerkleLLV21Contract_ClawbackEvent_campaignEntityHandlerContext; 
  readonly Factory: MerkleLLV21Contract_ClawbackEvent_factoryEntityHandlerContext; 
  readonly Watcher: MerkleLLV21Contract_ClawbackEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLLV21Contract_ClawbackEvent_actionEntityHandlerContextAsync; 
  readonly Activity: MerkleLLV21Contract_ClawbackEvent_activityEntityHandlerContextAsync; 
  readonly Asset: MerkleLLV21Contract_ClawbackEvent_assetEntityHandlerContextAsync; 
  readonly Campaign: MerkleLLV21Contract_ClawbackEvent_campaignEntityHandlerContextAsync; 
  readonly Factory: MerkleLLV21Contract_ClawbackEvent_factoryEntityHandlerContextAsync; 
  readonly Watcher: MerkleLLV21Contract_ClawbackEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_campaignEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: campaignLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_contractRegistrations = { readonly addMerkleLLV21: (_1:Ethers_ethAddress) => void; readonly addMerkleLockupFactoryV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_ClawbackEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: MerkleLLV21Contract_ClawbackEvent_contractRegistrations; 
  readonly Campaign: MerkleLLV21Contract_ClawbackEvent_campaignEntityLoaderContext; 
  readonly Watcher: MerkleLLV21Contract_ClawbackEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_eventArgs = { readonly oldAdmin: Ethers_ethAddress; readonly newAdmin: Ethers_ethAddress };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_log = eventLog<MerkleLLV21Contract_TransferAdminEvent_eventArgs>;
export type MerkleLLV21Contract_TransferAdmin_EventLog = MerkleLLV21Contract_TransferAdminEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_actionEntityHandlerContext = {
  readonly getCampaign: (_1:actionEntity) => campaignEntity; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_actionEntityHandlerContextAsync = {
  readonly getCampaign: (_1:actionEntity) => Promise<campaignEntity>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_activityEntityHandlerContext = {
  readonly getCampaign: (_1:activityEntity) => campaignEntity; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_activityEntityHandlerContextAsync = {
  readonly getCampaign: (_1:activityEntity) => Promise<campaignEntity>; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_assetEntityHandlerContext = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_assetEntityHandlerContextAsync = { readonly set: (_1:assetEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_campaignEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | campaignEntity); 
  readonly getAsset: (_1:campaignEntity) => assetEntity; 
  readonly getFactory: (_1:campaignEntity) => factoryEntity; 
  readonly getClawbackAction: (_1:campaignEntity) => (undefined | actionEntity); 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_campaignEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | campaignEntity)>; 
  readonly getAsset: (_1:campaignEntity) => Promise<assetEntity>; 
  readonly getFactory: (_1:campaignEntity) => Promise<factoryEntity>; 
  readonly getClawbackAction: (_1:campaignEntity) => Promise<(undefined | actionEntity)>; 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_factoryEntityHandlerContext = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_factoryEntityHandlerContextAsync = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLLV21Contract_TransferAdminEvent_actionEntityHandlerContext; 
  readonly Activity: MerkleLLV21Contract_TransferAdminEvent_activityEntityHandlerContext; 
  readonly Asset: MerkleLLV21Contract_TransferAdminEvent_assetEntityHandlerContext; 
  readonly Campaign: MerkleLLV21Contract_TransferAdminEvent_campaignEntityHandlerContext; 
  readonly Factory: MerkleLLV21Contract_TransferAdminEvent_factoryEntityHandlerContext; 
  readonly Watcher: MerkleLLV21Contract_TransferAdminEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLLV21Contract_TransferAdminEvent_actionEntityHandlerContextAsync; 
  readonly Activity: MerkleLLV21Contract_TransferAdminEvent_activityEntityHandlerContextAsync; 
  readonly Asset: MerkleLLV21Contract_TransferAdminEvent_assetEntityHandlerContextAsync; 
  readonly Campaign: MerkleLLV21Contract_TransferAdminEvent_campaignEntityHandlerContextAsync; 
  readonly Factory: MerkleLLV21Contract_TransferAdminEvent_factoryEntityHandlerContextAsync; 
  readonly Watcher: MerkleLLV21Contract_TransferAdminEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_campaignEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: campaignLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_contractRegistrations = { readonly addMerkleLLV21: (_1:Ethers_ethAddress) => void; readonly addMerkleLockupFactoryV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21Contract_TransferAdminEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: MerkleLLV21Contract_TransferAdminEvent_contractRegistrations; 
  readonly Campaign: MerkleLLV21Contract_TransferAdminEvent_campaignEntityLoaderContext; 
  readonly Watcher: MerkleLLV21Contract_TransferAdminEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs = {
  readonly merkleStreamer: Ethers_ethAddress; 
  readonly admin: Ethers_ethAddress; 
  readonly lockupLinear: Ethers_ethAddress; 
  readonly asset: Ethers_ethAddress; 
  readonly merkleRoot: string; 
  readonly expiration: Ethers_BigInt_t; 
  readonly streamDurations: [Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly cancelable: boolean; 
  readonly transferable: boolean; 
  readonly ipfsCID: string; 
  readonly aggregateAmount: Ethers_BigInt_t; 
  readonly recipientsCount: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_log = eventLog<MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs>;
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL_EventLog = MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_actionEntityHandlerContext = {
  readonly getCampaign: (_1:actionEntity) => campaignEntity; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_actionEntityHandlerContextAsync = {
  readonly getCampaign: (_1:actionEntity) => Promise<campaignEntity>; 
  readonly set: (_1:actionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_activityEntityHandlerContext = {
  readonly getCampaign: (_1:activityEntity) => campaignEntity; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_activityEntityHandlerContextAsync = {
  readonly getCampaign: (_1:activityEntity) => Promise<campaignEntity>; 
  readonly set: (_1:activityEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_assetEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | assetEntity); 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_assetEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | assetEntity)>; 
  readonly set: (_1:assetEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_campaignEntityHandlerContext = {
  readonly getAsset: (_1:campaignEntity) => assetEntity; 
  readonly getFactory: (_1:campaignEntity) => factoryEntity; 
  readonly getClawbackAction: (_1:campaignEntity) => (undefined | actionEntity); 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_campaignEntityHandlerContextAsync = {
  readonly getAsset: (_1:campaignEntity) => Promise<assetEntity>; 
  readonly getFactory: (_1:campaignEntity) => Promise<factoryEntity>; 
  readonly getClawbackAction: (_1:campaignEntity) => Promise<(undefined | actionEntity)>; 
  readonly set: (_1:campaignEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_factoryEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | factoryEntity); 
  readonly set: (_1:factoryEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_factoryEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | factoryEntity)>; 
  readonly set: (_1:factoryEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_watcherEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | watcherEntity); 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_watcherEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | watcherEntity)>; 
  readonly set: (_1:watcherEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_actionEntityHandlerContext; 
  readonly Activity: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_activityEntityHandlerContext; 
  readonly Asset: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_assetEntityHandlerContext; 
  readonly Campaign: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_campaignEntityHandlerContext; 
  readonly Factory: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_factoryEntityHandlerContext; 
  readonly Watcher: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_watcherEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Action: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_actionEntityHandlerContextAsync; 
  readonly Activity: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_activityEntityHandlerContextAsync; 
  readonly Asset: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_assetEntityHandlerContextAsync; 
  readonly Campaign: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_campaignEntityHandlerContextAsync; 
  readonly Factory: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_factoryEntityHandlerContextAsync; 
  readonly Watcher: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_watcherEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_assetEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_factoryEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_watcherEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_contractRegistrations = { readonly addMerkleLLV21: (_1:Ethers_ethAddress) => void; readonly addMerkleLockupFactoryV21: (_1:Ethers_ethAddress) => void };

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_contractRegistrations; 
  readonly Asset: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_assetEntityLoaderContext; 
  readonly Factory: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_factoryEntityLoaderContext; 
  readonly Watcher: MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_watcherEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type chainId = number;
