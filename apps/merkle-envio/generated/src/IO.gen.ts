/* TypeScript file generated from IO.res by genType. */
/* eslint-disable import/first */


import type {EventSyncState_eventSyncState as DbFunctions_EventSyncState_eventSyncState} from './DbFunctions.gen';

import type {actionEntity as Types_actionEntity} from './Types.gen';

import type {activityEntity as Types_activityEntity} from './Types.gen';

import type {assetEntity as Types_assetEntity} from './Types.gen';

import type {campaignEntity as Types_campaignEntity} from './Types.gen';

import type {dynamicContractRegistryEntity as Types_dynamicContractRegistryEntity} from './Types.gen';

import type {ethAddress as Ethers_ethAddress} from '../src/bindings/Ethers.gen';

import type {factoryEntity as Types_factoryEntity} from './Types.gen';

import type {inMemoryStoreRow as Types_inMemoryStoreRow} from './Types.gen';

import type {rawEventsEntity as Types_rawEventsEntity} from './Types.gen';

import type {watcherEntity as Types_watcherEntity} from './Types.gen';

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_stringHasher<val> = (_1:val) => string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_storeState<entity,entityKey> = { readonly dict: {[id: string]: Types_inMemoryStoreRow<entity>}; readonly hasher: InMemoryStore_stringHasher<entityKey> };

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_EventSyncState_value = DbFunctions_EventSyncState_eventSyncState;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_EventSyncState_key = number;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_EventSyncState_t = InMemoryStore_storeState<InMemoryStore_EventSyncState_value,InMemoryStore_EventSyncState_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_rawEventsKey = { readonly chainId: number; readonly eventId: string };

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_RawEvents_value = Types_rawEventsEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_RawEvents_key = InMemoryStore_rawEventsKey;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_RawEvents_t = InMemoryStore_storeState<InMemoryStore_RawEvents_value,InMemoryStore_RawEvents_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_dynamicContractRegistryKey = { readonly chainId: number; readonly contractAddress: Ethers_ethAddress };

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_DynamicContractRegistry_value = Types_dynamicContractRegistryEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_DynamicContractRegistry_key = InMemoryStore_dynamicContractRegistryKey;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_DynamicContractRegistry_t = InMemoryStore_storeState<InMemoryStore_DynamicContractRegistry_value,InMemoryStore_DynamicContractRegistry_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Action_value = Types_actionEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Action_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Action_t = InMemoryStore_storeState<InMemoryStore_Action_value,InMemoryStore_Action_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Activity_value = Types_activityEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Activity_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Activity_t = InMemoryStore_storeState<InMemoryStore_Activity_value,InMemoryStore_Activity_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Asset_value = Types_assetEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Asset_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Asset_t = InMemoryStore_storeState<InMemoryStore_Asset_value,InMemoryStore_Asset_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Campaign_value = Types_campaignEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Campaign_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Campaign_t = InMemoryStore_storeState<InMemoryStore_Campaign_value,InMemoryStore_Campaign_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Factory_value = Types_factoryEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Factory_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Factory_t = InMemoryStore_storeState<InMemoryStore_Factory_value,InMemoryStore_Factory_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Watcher_value = Types_watcherEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Watcher_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Watcher_t = InMemoryStore_storeState<InMemoryStore_Watcher_value,InMemoryStore_Watcher_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_t = {
  readonly eventSyncState: InMemoryStore_EventSyncState_t; 
  readonly rawEvents: InMemoryStore_RawEvents_t; 
  readonly dynamicContractRegistry: InMemoryStore_DynamicContractRegistry_t; 
  readonly action: InMemoryStore_Action_t; 
  readonly activity: InMemoryStore_Activity_t; 
  readonly asset: InMemoryStore_Asset_t; 
  readonly campaign: InMemoryStore_Campaign_t; 
  readonly factory: InMemoryStore_Factory_t; 
  readonly watcher: InMemoryStore_Watcher_t
};
