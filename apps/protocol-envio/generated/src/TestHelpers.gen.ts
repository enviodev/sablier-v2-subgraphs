/* TypeScript file generated from TestHelpers.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const TestHelpersBS = require('./TestHelpers.bs');

import type {BigInt_t as Ethers_BigInt_t} from '../src/bindings/Ethers.gen';

import type {LockupV20Contract_ApprovalEvent_eventArgs as Types_LockupV20Contract_ApprovalEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_ApprovalForAllEvent_eventArgs as Types_LockupV20Contract_ApprovalForAllEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_CancelLockupStreamEvent_eventArgs as Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs as Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs as Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_RenounceLockupStreamEvent_eventArgs as Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_TransferAdminEvent_eventArgs as Types_LockupV20Contract_TransferAdminEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_TransferEvent_eventArgs as Types_LockupV20Contract_TransferEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs as Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_ApprovalEvent_eventArgs as Types_LockupV21Contract_ApprovalEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_ApprovalForAllEvent_eventArgs as Types_LockupV21Contract_ApprovalForAllEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_CancelLockupStreamEvent_eventArgs as Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs as Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs as Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_RenounceLockupStreamEvent_eventArgs as Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_TransferAdminEvent_eventArgs as Types_LockupV21Contract_TransferAdminEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_TransferEvent_eventArgs as Types_LockupV21Contract_TransferEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs as Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs} from './Types.gen';

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
export type LockupV20_Approval_createMockArgs = {
  readonly owner?: Ethers_ethAddress; 
  readonly approved?: Ethers_ethAddress; 
  readonly tokenId?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_ApprovalForAll_createMockArgs = {
  readonly owner?: Ethers_ethAddress; 
  readonly operator?: Ethers_ethAddress; 
  readonly approved?: boolean; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_CancelLockupStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly sender?: Ethers_ethAddress; 
  readonly recipient?: Ethers_ethAddress; 
  readonly senderAmount?: Ethers_BigInt_t; 
  readonly recipientAmount?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_CreateLockupLinearStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly funder?: Ethers_ethAddress; 
  readonly sender?: Ethers_ethAddress; 
  readonly recipient?: Ethers_ethAddress; 
  readonly amounts?: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset?: Ethers_ethAddress; 
  readonly cancelable?: boolean; 
  readonly range?: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_CreateLockupDynamicStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly funder?: Ethers_ethAddress; 
  readonly sender?: Ethers_ethAddress; 
  readonly recipient?: Ethers_ethAddress; 
  readonly amounts?: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset?: Ethers_ethAddress; 
  readonly cancelable?: boolean; 
  readonly segments?: Array<[Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]>; 
  readonly range?: [Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_RenounceLockupStream_createMockArgs = { readonly streamId?: Ethers_BigInt_t; readonly mockEventData?: EventFunctions_mockEventData };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_Transfer_createMockArgs = {
  readonly from?: Ethers_ethAddress; 
  readonly to?: Ethers_ethAddress; 
  readonly tokenId?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_TransferAdmin_createMockArgs = {
  readonly oldAdmin?: Ethers_ethAddress; 
  readonly newAdmin?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV20_WithdrawFromLockupStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly to?: Ethers_ethAddress; 
  readonly amount?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_Approval_createMockArgs = {
  readonly owner?: Ethers_ethAddress; 
  readonly approved?: Ethers_ethAddress; 
  readonly tokenId?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_ApprovalForAll_createMockArgs = {
  readonly owner?: Ethers_ethAddress; 
  readonly operator?: Ethers_ethAddress; 
  readonly approved?: boolean; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_CancelLockupStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly sender?: Ethers_ethAddress; 
  readonly recipient?: Ethers_ethAddress; 
  readonly asset?: Ethers_ethAddress; 
  readonly senderAmount?: Ethers_BigInt_t; 
  readonly recipientAmount?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_CreateLockupLinearStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly funder?: Ethers_ethAddress; 
  readonly sender?: Ethers_ethAddress; 
  readonly recipient?: Ethers_ethAddress; 
  readonly amounts?: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset?: Ethers_ethAddress; 
  readonly cancelable?: boolean; 
  readonly transferable?: boolean; 
  readonly range?: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_CreateLockupDynamicStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly funder?: Ethers_ethAddress; 
  readonly sender?: Ethers_ethAddress; 
  readonly recipient?: Ethers_ethAddress; 
  readonly amounts?: [Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly asset?: Ethers_ethAddress; 
  readonly cancelable?: boolean; 
  readonly transferable?: boolean; 
  readonly segments?: Array<[Ethers_BigInt_t, Ethers_BigInt_t, Ethers_BigInt_t]>; 
  readonly range?: [Ethers_BigInt_t, Ethers_BigInt_t]; 
  readonly broker?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_RenounceLockupStream_createMockArgs = { readonly streamId?: Ethers_BigInt_t; readonly mockEventData?: EventFunctions_mockEventData };

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_Transfer_createMockArgs = {
  readonly from?: Ethers_ethAddress; 
  readonly to?: Ethers_ethAddress; 
  readonly tokenId?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_TransferAdmin_createMockArgs = {
  readonly oldAdmin?: Ethers_ethAddress; 
  readonly newAdmin?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type LockupV21_WithdrawFromLockupStream_createMockArgs = {
  readonly streamId?: Ethers_BigInt_t; 
  readonly to?: Ethers_ethAddress; 
  readonly asset?: Ethers_ethAddress; 
  readonly amount?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

export const MockDb_createMockDb: () => TestHelpers_MockDb_t = TestHelpersBS.MockDb.createMockDb;

export const LockupV20_Approval_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.Approval.processEvent;

export const LockupV20_Approval_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.Approval.processEventAsync;

export const LockupV20_Approval_createMockEvent: (args:LockupV20_Approval_createMockArgs) => Types_eventLog<Types_LockupV20Contract_ApprovalEvent_eventArgs> = TestHelpersBS.LockupV20.Approval.createMockEvent;

export const LockupV20_ApprovalForAll_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.ApprovalForAll.processEvent;

export const LockupV20_ApprovalForAll_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.ApprovalForAll.processEventAsync;

export const LockupV20_ApprovalForAll_createMockEvent: (args:LockupV20_ApprovalForAll_createMockArgs) => Types_eventLog<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs> = TestHelpersBS.LockupV20.ApprovalForAll.createMockEvent;

export const LockupV20_CancelLockupStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.CancelLockupStream.processEvent;

export const LockupV20_CancelLockupStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.CancelLockupStream.processEventAsync;

export const LockupV20_CancelLockupStream_createMockEvent: (args:LockupV20_CancelLockupStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs> = TestHelpersBS.LockupV20.CancelLockupStream.createMockEvent;

export const LockupV20_CreateLockupLinearStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.CreateLockupLinearStream.processEvent;

export const LockupV20_CreateLockupLinearStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.CreateLockupLinearStream.processEventAsync;

export const LockupV20_CreateLockupLinearStream_createMockEvent: (args:LockupV20_CreateLockupLinearStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs> = TestHelpersBS.LockupV20.CreateLockupLinearStream.createMockEvent;

export const LockupV20_CreateLockupDynamicStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.CreateLockupDynamicStream.processEvent;

export const LockupV20_CreateLockupDynamicStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.CreateLockupDynamicStream.processEventAsync;

export const LockupV20_CreateLockupDynamicStream_createMockEvent: (args:LockupV20_CreateLockupDynamicStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs> = TestHelpersBS.LockupV20.CreateLockupDynamicStream.createMockEvent;

export const LockupV20_RenounceLockupStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.RenounceLockupStream.processEvent;

export const LockupV20_RenounceLockupStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.RenounceLockupStream.processEventAsync;

export const LockupV20_RenounceLockupStream_createMockEvent: (args:LockupV20_RenounceLockupStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs> = TestHelpersBS.LockupV20.RenounceLockupStream.createMockEvent;

export const LockupV20_Transfer_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.Transfer.processEvent;

export const LockupV20_Transfer_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.Transfer.processEventAsync;

export const LockupV20_Transfer_createMockEvent: (args:LockupV20_Transfer_createMockArgs) => Types_eventLog<Types_LockupV20Contract_TransferEvent_eventArgs> = TestHelpersBS.LockupV20.Transfer.createMockEvent;

export const LockupV20_TransferAdmin_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferAdminEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.TransferAdmin.processEvent;

export const LockupV20_TransferAdmin_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferAdminEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.TransferAdmin.processEventAsync;

export const LockupV20_TransferAdmin_createMockEvent: (args:LockupV20_TransferAdmin_createMockArgs) => Types_eventLog<Types_LockupV20Contract_TransferAdminEvent_eventArgs> = TestHelpersBS.LockupV20.TransferAdmin.createMockEvent;

export const LockupV20_WithdrawFromLockupStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV20.WithdrawFromLockupStream.processEvent;

export const LockupV20_WithdrawFromLockupStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV20.WithdrawFromLockupStream.processEventAsync;

export const LockupV20_WithdrawFromLockupStream_createMockEvent: (args:LockupV20_WithdrawFromLockupStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs> = TestHelpersBS.LockupV20.WithdrawFromLockupStream.createMockEvent;

export const LockupV21_Approval_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.Approval.processEvent;

export const LockupV21_Approval_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.Approval.processEventAsync;

export const LockupV21_Approval_createMockEvent: (args:LockupV21_Approval_createMockArgs) => Types_eventLog<Types_LockupV21Contract_ApprovalEvent_eventArgs> = TestHelpersBS.LockupV21.Approval.createMockEvent;

export const LockupV21_ApprovalForAll_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.ApprovalForAll.processEvent;

export const LockupV21_ApprovalForAll_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.ApprovalForAll.processEventAsync;

export const LockupV21_ApprovalForAll_createMockEvent: (args:LockupV21_ApprovalForAll_createMockArgs) => Types_eventLog<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs> = TestHelpersBS.LockupV21.ApprovalForAll.createMockEvent;

export const LockupV21_CancelLockupStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.CancelLockupStream.processEvent;

export const LockupV21_CancelLockupStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.CancelLockupStream.processEventAsync;

export const LockupV21_CancelLockupStream_createMockEvent: (args:LockupV21_CancelLockupStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs> = TestHelpersBS.LockupV21.CancelLockupStream.createMockEvent;

export const LockupV21_CreateLockupLinearStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.CreateLockupLinearStream.processEvent;

export const LockupV21_CreateLockupLinearStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.CreateLockupLinearStream.processEventAsync;

export const LockupV21_CreateLockupLinearStream_createMockEvent: (args:LockupV21_CreateLockupLinearStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs> = TestHelpersBS.LockupV21.CreateLockupLinearStream.createMockEvent;

export const LockupV21_CreateLockupDynamicStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.CreateLockupDynamicStream.processEvent;

export const LockupV21_CreateLockupDynamicStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.CreateLockupDynamicStream.processEventAsync;

export const LockupV21_CreateLockupDynamicStream_createMockEvent: (args:LockupV21_CreateLockupDynamicStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs> = TestHelpersBS.LockupV21.CreateLockupDynamicStream.createMockEvent;

export const LockupV21_RenounceLockupStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.RenounceLockupStream.processEvent;

export const LockupV21_RenounceLockupStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.RenounceLockupStream.processEventAsync;

export const LockupV21_RenounceLockupStream_createMockEvent: (args:LockupV21_RenounceLockupStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs> = TestHelpersBS.LockupV21.RenounceLockupStream.createMockEvent;

export const LockupV21_Transfer_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.Transfer.processEvent;

export const LockupV21_Transfer_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.Transfer.processEventAsync;

export const LockupV21_Transfer_createMockEvent: (args:LockupV21_Transfer_createMockArgs) => Types_eventLog<Types_LockupV21Contract_TransferEvent_eventArgs> = TestHelpersBS.LockupV21.Transfer.createMockEvent;

export const LockupV21_TransferAdmin_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferAdminEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.TransferAdmin.processEvent;

export const LockupV21_TransferAdmin_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferAdminEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.TransferAdmin.processEventAsync;

export const LockupV21_TransferAdmin_createMockEvent: (args:LockupV21_TransferAdmin_createMockArgs) => Types_eventLog<Types_LockupV21Contract_TransferAdminEvent_eventArgs> = TestHelpersBS.LockupV21.TransferAdmin.createMockEvent;

export const LockupV21_WithdrawFromLockupStream_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.LockupV21.WithdrawFromLockupStream.processEvent;

export const LockupV21_WithdrawFromLockupStream_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.LockupV21.WithdrawFromLockupStream.processEventAsync;

export const LockupV21_WithdrawFromLockupStream_createMockEvent: (args:LockupV21_WithdrawFromLockupStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs> = TestHelpersBS.LockupV21.WithdrawFromLockupStream.createMockEvent;

export const LockupV21: {
  CreateLockupLinearStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_CreateLockupLinearStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs>
  }; 
  ApprovalForAll: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_ApprovalForAll_createMockArgs) => Types_eventLog<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs>
  }; 
  WithdrawFromLockupStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_WithdrawFromLockupStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs>
  }; 
  TransferAdmin: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferAdminEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferAdminEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_TransferAdmin_createMockArgs) => Types_eventLog<Types_LockupV21Contract_TransferAdminEvent_eventArgs>
  }; 
  CreateLockupDynamicStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_CreateLockupDynamicStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs>
  }; 
  RenounceLockupStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_RenounceLockupStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs>
  }; 
  CancelLockupStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_CancelLockupStream_createMockArgs) => Types_eventLog<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs>
  }; 
  Transfer: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_TransferEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_Transfer_createMockArgs) => Types_eventLog<Types_LockupV21Contract_TransferEvent_eventArgs>
  }; 
  Approval: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV21Contract_ApprovalEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV21_Approval_createMockArgs) => Types_eventLog<Types_LockupV21Contract_ApprovalEvent_eventArgs>
  }
} = TestHelpersBS.LockupV21

export const LockupV20: {
  CreateLockupLinearStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_CreateLockupLinearStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs>
  }; 
  ApprovalForAll: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_ApprovalForAll_createMockArgs) => Types_eventLog<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs>
  }; 
  WithdrawFromLockupStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_WithdrawFromLockupStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs>
  }; 
  TransferAdmin: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferAdminEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferAdminEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_TransferAdmin_createMockArgs) => Types_eventLog<Types_LockupV20Contract_TransferAdminEvent_eventArgs>
  }; 
  CreateLockupDynamicStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_CreateLockupDynamicStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs>
  }; 
  RenounceLockupStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_RenounceLockupStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs>
  }; 
  CancelLockupStream: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_CancelLockupStream_createMockArgs) => Types_eventLog<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs>
  }; 
  Transfer: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_TransferEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_Transfer_createMockArgs) => Types_eventLog<Types_LockupV20Contract_TransferEvent_eventArgs>
  }; 
  Approval: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_LockupV20Contract_ApprovalEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:LockupV20_Approval_createMockArgs) => Types_eventLog<Types_LockupV20Contract_ApprovalEvent_eventArgs>
  }
} = TestHelpersBS.LockupV20

export const MockDb: { createMockDb: () => TestHelpers_MockDb_t } = TestHelpersBS.MockDb
