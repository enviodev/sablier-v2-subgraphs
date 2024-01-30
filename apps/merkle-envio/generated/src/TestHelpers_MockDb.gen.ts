/* TypeScript file generated from TestHelpers_MockDb.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const TestHelpers_MockDbBS = require('./TestHelpers_MockDb.bs');

import type {EventSyncState_eventSyncState as DbFunctions_EventSyncState_eventSyncState} from './DbFunctions.gen';

import type {InMemoryStore_dynamicContractRegistryKey as IO_InMemoryStore_dynamicContractRegistryKey} from './IO.gen';

import type {InMemoryStore_rawEventsKey as IO_InMemoryStore_rawEventsKey} from './IO.gen';

import type {InMemoryStore_t as IO_InMemoryStore_t} from './IO.gen';

import type {actionEntity as Types_actionEntity} from './Types.gen';

import type {activityEntity as Types_activityEntity} from './Types.gen';

import type {assetEntity as Types_assetEntity} from './Types.gen';

import type {campaignEntity as Types_campaignEntity} from './Types.gen';

import type {chainId as Types_chainId} from './Types.gen';

import type {dynamicContractRegistryEntity as Types_dynamicContractRegistryEntity} from './Types.gen';

import type {factoryEntity as Types_factoryEntity} from './Types.gen';

import type {rawEventsEntity as Types_rawEventsEntity} from './Types.gen';

import type {watcherEntity as Types_watcherEntity} from './Types.gen';

// tslint:disable-next-line:interface-over-type-literal
export type t = {
  readonly __dbInternal__: IO_InMemoryStore_t; 
  readonly entities: entities; 
  readonly rawEvents: storeOperations<IO_InMemoryStore_rawEventsKey,Types_rawEventsEntity>; 
  readonly eventSyncState: storeOperations<Types_chainId,DbFunctions_EventSyncState_eventSyncState>; 
  readonly dynamicContractRegistry: storeOperations<IO_InMemoryStore_dynamicContractRegistryKey,Types_dynamicContractRegistryEntity>
};

// tslint:disable-next-line:interface-over-type-literal
export type entities = {
  readonly Action: entityStoreOperations<Types_actionEntity>; 
  readonly Activity: entityStoreOperations<Types_activityEntity>; 
  readonly Asset: entityStoreOperations<Types_assetEntity>; 
  readonly Campaign: entityStoreOperations<Types_campaignEntity>; 
  readonly Factory: entityStoreOperations<Types_factoryEntity>; 
  readonly Watcher: entityStoreOperations<Types_watcherEntity>
};

// tslint:disable-next-line:interface-over-type-literal
export type entityStoreOperations<entity> = storeOperations<string,entity>;

// tslint:disable-next-line:interface-over-type-literal
export type storeOperations<entityKey,entity> = {
  readonly getAll: () => entity[]; 
  readonly get: (_1:entityKey) => (undefined | entity); 
  readonly set: (_1:entity) => t; 
  readonly delete: (_1:entityKey) => t
};

export const createMockDb: () => t = TestHelpers_MockDbBS.createMockDb;
