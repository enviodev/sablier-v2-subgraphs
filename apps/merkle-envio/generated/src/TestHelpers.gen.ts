/* TypeScript file generated from TestHelpers.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const TestHelpersBS = require('./TestHelpers.bs');

import type {BigInt_t as Ethers_BigInt_t} from '../src/bindings/Ethers.gen';

import type {MerkleLLV21Contract_ClaimEvent_eventArgs as Types_MerkleLLV21Contract_ClaimEvent_eventArgs} from './Types.gen';

import type {MerkleLLV21Contract_ClawbackEvent_eventArgs as Types_MerkleLLV21Contract_ClawbackEvent_eventArgs} from './Types.gen';

import type {MerkleLLV21Contract_TransferAdminEvent_eventArgs as Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs} from './Types.gen';

import type {MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs as Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs} from './Types.gen';

import type {ethAddress as Ethers_ethAddress} from '../src/bindings/Ethers.gen';

import type {eventLog as Types_eventLog} from './Types.gen';

import type {t as TestHelpers_MockDb_t} from './TestHelpers_MockDb.gen';

// tslint:disable-next-line:interface-over-type-literal
export type EventFunctions_eventProcessorArgs<eventArgs> = {
  readonly event: Types_eventLog<eventArgs>; 
  readonly mockDb: TestHelpers_MockDb_t; 
  readonly chainId?: number
};

// tslint:disable-next-line:interface-over-type-literal
export type EventFunctions_mockEventData = {
  readonly blockNumber?: number; 
  readonly blockTimestamp?: number; 
  readonly blockHash?: string; 
  readonly chainId?: number; 
  readonly srcAddress?: Ethers_ethAddress; 
  readonly transactionHash?: string; 
  readonly transactionIndex?: number; 
  readonly logIndex?: number
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21_Claim_createMockArgs = {
  readonly index?: Ethers_BigInt_t; 
  readonly recipient?: Ethers_ethAddress; 
  readonly amount?: Ethers_BigInt_t; 
  readonly streamId?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21_Clawback_createMockArgs = {
  readonly admin?: Ethers_ethAddress; 
  readonly to?: Ethers_ethAddress; 
  readonly amount?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLLV21_TransferAdmin_createMockArgs = {
  readonly oldAdmin?: Ethers_ethAddress; 
  readonly newAdmin?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type MerkleLockupFactoryV21_CreateMerkleStreamerLL_createMockArgs = {
  readonly merkleStreamer?: Ethers_ethAddress; 
  readonly admin?: Ethers_ethAddress; 
  readonly lockupLinear?: Ethers_ethAddress; 
  readonly asset?: Ethers_ethAddress; 
  readonly merkleRoot?: string; 
  readonly expiration?: Ethers_BigInt_t; 
  readonly streamDurations?: [Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly cancelable?: boolean; 
  readonly transferable?: boolean; 
  readonly ipfsCID?: string; 
  readonly aggregateAmount?: Ethers_BigInt_t; 
  readonly recipientsCount?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

export const MockDb_createMockDb: () => TestHelpers_MockDb_t = TestHelpersBS.MockDb.createMockDb;

export const MerkleLLV21_Claim_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClaimEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.MerkleLLV21.Claim.processEvent;

export const MerkleLLV21_Claim_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClaimEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.MerkleLLV21.Claim.processEventAsync;

export const MerkleLLV21_Claim_createMockEvent: (args:MerkleLLV21_Claim_createMockArgs) => Types_eventLog<Types_MerkleLLV21Contract_ClaimEvent_eventArgs> = TestHelpersBS.MerkleLLV21.Claim.createMockEvent;

export const MerkleLLV21_Clawback_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.MerkleLLV21.Clawback.processEvent;

export const MerkleLLV21_Clawback_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.MerkleLLV21.Clawback.processEventAsync;

export const MerkleLLV21_Clawback_createMockEvent: (args:MerkleLLV21_Clawback_createMockArgs) => Types_eventLog<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs> = TestHelpersBS.MerkleLLV21.Clawback.createMockEvent;

export const MerkleLLV21_TransferAdmin_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.MerkleLLV21.TransferAdmin.processEvent;

export const MerkleLLV21_TransferAdmin_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.MerkleLLV21.TransferAdmin.processEventAsync;

export const MerkleLLV21_TransferAdmin_createMockEvent: (args:MerkleLLV21_TransferAdmin_createMockArgs) => Types_eventLog<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs> = TestHelpersBS.MerkleLLV21.TransferAdmin.createMockEvent;

export const MerkleLockupFactoryV21_CreateMerkleStreamerLL_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.MerkleLockupFactoryV21.CreateMerkleStreamerLL.processEvent;

export const MerkleLockupFactoryV21_CreateMerkleStreamerLL_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.MerkleLockupFactoryV21.CreateMerkleStreamerLL.processEventAsync;

export const MerkleLockupFactoryV21_CreateMerkleStreamerLL_createMockEvent: (args:MerkleLockupFactoryV21_CreateMerkleStreamerLL_createMockArgs) => Types_eventLog<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs> = TestHelpersBS.MerkleLockupFactoryV21.CreateMerkleStreamerLL.createMockEvent;

export const MerkleLockupFactoryV21: { CreateMerkleStreamerLL: {
  processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs>) => TestHelpers_MockDb_t; 
  processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
  createMockEvent: (args:MerkleLockupFactoryV21_CreateMerkleStreamerLL_createMockArgs) => Types_eventLog<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs>
} } = TestHelpersBS.MerkleLockupFactoryV21

export const MockDb: { createMockDb: () => TestHelpers_MockDb_t } = TestHelpersBS.MockDb

export const MerkleLLV21: {
  Clawback: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:MerkleLLV21_Clawback_createMockArgs) => Types_eventLog<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs>
  }; 
  Claim: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClaimEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_ClaimEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:MerkleLLV21_Claim_createMockArgs) => Types_eventLog<Types_MerkleLLV21Contract_ClaimEvent_eventArgs>
  }; 
  TransferAdmin: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:MerkleLLV21_TransferAdmin_createMockArgs) => Types_eventLog<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs>
  }
} = TestHelpersBS.MerkleLLV21
