/* TypeScript file generated from IO.res by genType. */
/* eslint-disable import/first */


import type {EventSyncState_eventSyncState as DbFunctions_EventSyncState_eventSyncState} from './DbFunctions.gen';

import type {actionEntity as Types_actionEntity} from './Types.gen';

import type {assetEntity as Types_assetEntity} from './Types.gen';

import type {batchEntity as Types_batchEntity} from './Types.gen';

import type {batcherEntity as Types_batcherEntity} from './Types.gen';

import type {contractEntity as Types_contractEntity} from './Types.gen';

import type {dynamicContractRegistryEntity as Types_dynamicContractRegistryEntity} from './Types.gen';

import type {ethAddress as Ethers_ethAddress} from '../src/bindings/Ethers.gen';

import type {inMemoryStoreRow as Types_inMemoryStoreRow} from './Types.gen';

import type {rawEventsEntity as Types_rawEventsEntity} from './Types.gen';

import type {segmentEntity as Types_segmentEntity} from './Types.gen';

import type {streamEntity as Types_streamEntity} from './Types.gen';

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
export type InMemoryStore_Asset_value = Types_assetEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Asset_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Asset_t = InMemoryStore_storeState<InMemoryStore_Asset_value,InMemoryStore_Asset_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Batch_value = Types_batchEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Batch_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Batch_t = InMemoryStore_storeState<InMemoryStore_Batch_value,InMemoryStore_Batch_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Batcher_value = Types_batcherEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Batcher_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Batcher_t = InMemoryStore_storeState<InMemoryStore_Batcher_value,InMemoryStore_Batcher_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Contract_value = Types_contractEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Contract_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Contract_t = InMemoryStore_storeState<InMemoryStore_Contract_value,InMemoryStore_Contract_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Segment_value = Types_segmentEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Segment_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Segment_t = InMemoryStore_storeState<InMemoryStore_Segment_value,InMemoryStore_Segment_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Stream_value = Types_streamEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Stream_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Stream_t = InMemoryStore_storeState<InMemoryStore_Stream_value,InMemoryStore_Stream_key>;

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
  readonly asset: InMemoryStore_Asset_t; 
  readonly batch: InMemoryStore_Batch_t; 
  readonly batcher: InMemoryStore_Batcher_t; 
  readonly contract: InMemoryStore_Contract_t; 
  readonly segment: InMemoryStore_Segment_t; 
  readonly stream: InMemoryStore_Stream_t; 
  readonly watcher: InMemoryStore_Watcher_t
};
