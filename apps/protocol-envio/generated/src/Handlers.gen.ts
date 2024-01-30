/* TypeScript file generated from Handlers.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const Curry = require('rescript/lib/js/curry.js');

// @ts-ignore: Implicit any on import
const HandlersBS = require('./Handlers.bs');

import type {LockupV20Contract_ApprovalEvent_eventArgs as Types_LockupV20Contract_ApprovalEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_ApprovalEvent_handlerContextAsync as Types_LockupV20Contract_ApprovalEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_ApprovalEvent_handlerContext as Types_LockupV20Contract_ApprovalEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_ApprovalEvent_loaderContext as Types_LockupV20Contract_ApprovalEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_ApprovalForAllEvent_eventArgs as Types_LockupV20Contract_ApprovalForAllEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_ApprovalForAllEvent_handlerContextAsync as Types_LockupV20Contract_ApprovalForAllEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_ApprovalForAllEvent_handlerContext as Types_LockupV20Contract_ApprovalForAllEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_ApprovalForAllEvent_loaderContext as Types_LockupV20Contract_ApprovalForAllEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_CancelLockupStreamEvent_eventArgs as Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_CancelLockupStreamEvent_handlerContextAsync as Types_LockupV20Contract_CancelLockupStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_CancelLockupStreamEvent_handlerContext as Types_LockupV20Contract_CancelLockupStreamEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_CancelLockupStreamEvent_loaderContext as Types_LockupV20Contract_CancelLockupStreamEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs as Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContextAsync as Types_LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContext as Types_LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_CreateLockupDynamicStreamEvent_loaderContext as Types_LockupV20Contract_CreateLockupDynamicStreamEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs as Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_CreateLockupLinearStreamEvent_handlerContextAsync as Types_LockupV20Contract_CreateLockupLinearStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_CreateLockupLinearStreamEvent_handlerContext as Types_LockupV20Contract_CreateLockupLinearStreamEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_CreateLockupLinearStreamEvent_loaderContext as Types_LockupV20Contract_CreateLockupLinearStreamEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_RenounceLockupStreamEvent_eventArgs as Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_RenounceLockupStreamEvent_handlerContextAsync as Types_LockupV20Contract_RenounceLockupStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_RenounceLockupStreamEvent_handlerContext as Types_LockupV20Contract_RenounceLockupStreamEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_RenounceLockupStreamEvent_loaderContext as Types_LockupV20Contract_RenounceLockupStreamEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_TransferAdminEvent_eventArgs as Types_LockupV20Contract_TransferAdminEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_TransferAdminEvent_handlerContextAsync as Types_LockupV20Contract_TransferAdminEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_TransferAdminEvent_handlerContext as Types_LockupV20Contract_TransferAdminEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_TransferAdminEvent_loaderContext as Types_LockupV20Contract_TransferAdminEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_TransferEvent_eventArgs as Types_LockupV20Contract_TransferEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_TransferEvent_handlerContextAsync as Types_LockupV20Contract_TransferEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_TransferEvent_handlerContext as Types_LockupV20Contract_TransferEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_TransferEvent_loaderContext as Types_LockupV20Contract_TransferEvent_loaderContext} from './Types.gen';

import type {LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs as Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContextAsync as Types_LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContext as Types_LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContext} from './Types.gen';

import type {LockupV20Contract_WithdrawFromLockupStreamEvent_loaderContext as Types_LockupV20Contract_WithdrawFromLockupStreamEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_ApprovalEvent_eventArgs as Types_LockupV21Contract_ApprovalEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_ApprovalEvent_handlerContextAsync as Types_LockupV21Contract_ApprovalEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_ApprovalEvent_handlerContext as Types_LockupV21Contract_ApprovalEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_ApprovalEvent_loaderContext as Types_LockupV21Contract_ApprovalEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_ApprovalForAllEvent_eventArgs as Types_LockupV21Contract_ApprovalForAllEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_ApprovalForAllEvent_handlerContextAsync as Types_LockupV21Contract_ApprovalForAllEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_ApprovalForAllEvent_handlerContext as Types_LockupV21Contract_ApprovalForAllEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_ApprovalForAllEvent_loaderContext as Types_LockupV21Contract_ApprovalForAllEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_CancelLockupStreamEvent_eventArgs as Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_CancelLockupStreamEvent_handlerContextAsync as Types_LockupV21Contract_CancelLockupStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_CancelLockupStreamEvent_handlerContext as Types_LockupV21Contract_CancelLockupStreamEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_CancelLockupStreamEvent_loaderContext as Types_LockupV21Contract_CancelLockupStreamEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs as Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContextAsync as Types_LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContext as Types_LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_CreateLockupDynamicStreamEvent_loaderContext as Types_LockupV21Contract_CreateLockupDynamicStreamEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs as Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_CreateLockupLinearStreamEvent_handlerContextAsync as Types_LockupV21Contract_CreateLockupLinearStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_CreateLockupLinearStreamEvent_handlerContext as Types_LockupV21Contract_CreateLockupLinearStreamEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_CreateLockupLinearStreamEvent_loaderContext as Types_LockupV21Contract_CreateLockupLinearStreamEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_RenounceLockupStreamEvent_eventArgs as Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_RenounceLockupStreamEvent_handlerContextAsync as Types_LockupV21Contract_RenounceLockupStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_RenounceLockupStreamEvent_handlerContext as Types_LockupV21Contract_RenounceLockupStreamEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_RenounceLockupStreamEvent_loaderContext as Types_LockupV21Contract_RenounceLockupStreamEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_TransferAdminEvent_eventArgs as Types_LockupV21Contract_TransferAdminEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_TransferAdminEvent_handlerContextAsync as Types_LockupV21Contract_TransferAdminEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_TransferAdminEvent_handlerContext as Types_LockupV21Contract_TransferAdminEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_TransferAdminEvent_loaderContext as Types_LockupV21Contract_TransferAdminEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_TransferEvent_eventArgs as Types_LockupV21Contract_TransferEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_TransferEvent_handlerContextAsync as Types_LockupV21Contract_TransferEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_TransferEvent_handlerContext as Types_LockupV21Contract_TransferEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_TransferEvent_loaderContext as Types_LockupV21Contract_TransferEvent_loaderContext} from './Types.gen';

import type {LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs as Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs} from './Types.gen';

import type {LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContextAsync as Types_LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContextAsync} from './Types.gen';

import type {LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContext as Types_LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContext} from './Types.gen';

import type {LockupV21Contract_WithdrawFromLockupStreamEvent_loaderContext as Types_LockupV21Contract_WithdrawFromLockupStreamEvent_loaderContext} from './Types.gen';

import type {eventLog as Types_eventLog} from './Types.gen';

import type {genericContextCreatorFunctions as Context_genericContextCreatorFunctions} from './Context.gen';

import type {t as SyncAsync_t} from './SyncAsync.gen';

// tslint:disable-next-line:interface-over-type-literal
export type handlerFunction<eventArgs,context,returned> = (_1:{ readonly event: Types_eventLog<eventArgs>; readonly context: context }) => returned;

// tslint:disable-next-line:interface-over-type-literal
export type handlerWithContextGetter<eventArgs,context,returned,loaderContext,handlerContextSync,handlerContextAsync> = { readonly handler: handlerFunction<eventArgs,context,returned>; readonly contextGetter: (_1:Context_genericContextCreatorFunctions<loaderContext,handlerContextSync,handlerContextAsync>) => context };

// tslint:disable-next-line:interface-over-type-literal
export type handlerWithContextGetterSyncAsync<eventArgs,loaderContext,handlerContextSync,handlerContextAsync> = SyncAsync_t<handlerWithContextGetter<eventArgs,handlerContextSync,void,loaderContext,handlerContextSync,handlerContextAsync>,handlerWithContextGetter<eventArgs,handlerContextAsync,Promise<void>,loaderContext,handlerContextSync,handlerContextAsync>>;

// tslint:disable-next-line:interface-over-type-literal
export type loader<eventArgs,loaderContext> = (_1:{ readonly event: Types_eventLog<eventArgs>; readonly context: loaderContext }) => void;

export const LockupV20Contract_Approval_loader: (loader:loader<Types_LockupV20Contract_ApprovalEvent_eventArgs,Types_LockupV20Contract_ApprovalEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.Approval.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_Approval_handler: (handler:handlerFunction<Types_LockupV20Contract_ApprovalEvent_eventArgs,Types_LockupV20Contract_ApprovalEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.Approval.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_Approval_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_ApprovalEvent_eventArgs,Types_LockupV20Contract_ApprovalEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.Approval.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_ApprovalForAll_loader: (loader:loader<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs,Types_LockupV20Contract_ApprovalForAllEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.ApprovalForAll.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_ApprovalForAll_handler: (handler:handlerFunction<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs,Types_LockupV20Contract_ApprovalForAllEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.ApprovalForAll.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_ApprovalForAll_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_ApprovalForAllEvent_eventArgs,Types_LockupV20Contract_ApprovalForAllEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.ApprovalForAll.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CancelLockupStream_loader: (loader:loader<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs,Types_LockupV20Contract_CancelLockupStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CancelLockupStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CancelLockupStream_handler: (handler:handlerFunction<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs,Types_LockupV20Contract_CancelLockupStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CancelLockupStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CancelLockupStream_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_CancelLockupStreamEvent_eventArgs,Types_LockupV20Contract_CancelLockupStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CancelLockupStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CreateLockupLinearStream_loader: (loader:loader<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs,Types_LockupV20Contract_CreateLockupLinearStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CreateLockupLinearStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Asset:Argcontext.Asset, Batch:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Batch.load, Arg12, Arg21.loaders);
          return result3
        }}, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CreateLockupLinearStream_handler: (handler:handlerFunction<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs,Types_LockupV20Contract_CreateLockupLinearStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CreateLockupLinearStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CreateLockupLinearStream_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_CreateLockupLinearStreamEvent_eventArgs,Types_LockupV20Contract_CreateLockupLinearStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CreateLockupLinearStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CreateLockupDynamicStream_loader: (loader:loader<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs,Types_LockupV20Contract_CreateLockupDynamicStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CreateLockupDynamicStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Asset:Argcontext.Asset, Batch:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Batch.load, Arg12, Arg21.loaders);
          return result3
        }}, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CreateLockupDynamicStream_handler: (handler:handlerFunction<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs,Types_LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CreateLockupDynamicStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_CreateLockupDynamicStream_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_CreateLockupDynamicStreamEvent_eventArgs,Types_LockupV20Contract_CreateLockupDynamicStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.CreateLockupDynamicStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_RenounceLockupStream_loader: (loader:loader<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs,Types_LockupV20Contract_RenounceLockupStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.RenounceLockupStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_RenounceLockupStream_handler: (handler:handlerFunction<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs,Types_LockupV20Contract_RenounceLockupStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.RenounceLockupStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_RenounceLockupStream_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_RenounceLockupStreamEvent_eventArgs,Types_LockupV20Contract_RenounceLockupStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.RenounceLockupStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_Transfer_loader: (loader:loader<Types_LockupV20Contract_TransferEvent_eventArgs,Types_LockupV20Contract_TransferEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.Transfer.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_Transfer_handler: (handler:handlerFunction<Types_LockupV20Contract_TransferEvent_eventArgs,Types_LockupV20Contract_TransferEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.Transfer.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_Transfer_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_TransferEvent_eventArgs,Types_LockupV20Contract_TransferEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.Transfer.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_TransferAdmin_loader: (loader:loader<Types_LockupV20Contract_TransferAdminEvent_eventArgs,Types_LockupV20Contract_TransferAdminEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.TransferAdmin.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Contract:Argcontext.Contract, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_TransferAdmin_handler: (handler:handlerFunction<Types_LockupV20Contract_TransferAdminEvent_eventArgs,Types_LockupV20Contract_TransferAdminEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.TransferAdmin.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_TransferAdmin_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_TransferAdminEvent_eventArgs,Types_LockupV20Contract_TransferAdminEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.TransferAdmin.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_WithdrawFromLockupStream_loader: (loader:loader<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs,Types_LockupV20Contract_WithdrawFromLockupStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.WithdrawFromLockupStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_WithdrawFromLockupStream_handler: (handler:handlerFunction<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs,Types_LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.WithdrawFromLockupStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV20Contract_WithdrawFromLockupStream_handlerAsync: (handler:handlerFunction<Types_LockupV20Contract_WithdrawFromLockupStreamEvent_eventArgs,Types_LockupV20Contract_WithdrawFromLockupStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV20Contract.WithdrawFromLockupStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_Approval_loader: (loader:loader<Types_LockupV21Contract_ApprovalEvent_eventArgs,Types_LockupV21Contract_ApprovalEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.Approval.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_Approval_handler: (handler:handlerFunction<Types_LockupV21Contract_ApprovalEvent_eventArgs,Types_LockupV21Contract_ApprovalEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.Approval.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_Approval_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_ApprovalEvent_eventArgs,Types_LockupV21Contract_ApprovalEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.Approval.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_ApprovalForAll_loader: (loader:loader<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs,Types_LockupV21Contract_ApprovalForAllEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.ApprovalForAll.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_ApprovalForAll_handler: (handler:handlerFunction<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs,Types_LockupV21Contract_ApprovalForAllEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.ApprovalForAll.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_ApprovalForAll_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_ApprovalForAllEvent_eventArgs,Types_LockupV21Contract_ApprovalForAllEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.ApprovalForAll.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CancelLockupStream_loader: (loader:loader<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs,Types_LockupV21Contract_CancelLockupStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CancelLockupStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CancelLockupStream_handler: (handler:handlerFunction<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs,Types_LockupV21Contract_CancelLockupStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CancelLockupStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CancelLockupStream_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_CancelLockupStreamEvent_eventArgs,Types_LockupV21Contract_CancelLockupStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CancelLockupStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CreateLockupLinearStream_loader: (loader:loader<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs,Types_LockupV21Contract_CreateLockupLinearStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CreateLockupLinearStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Asset:Argcontext.Asset, Batch:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Batch.load, Arg12, Arg21.loaders);
          return result3
        }}, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CreateLockupLinearStream_handler: (handler:handlerFunction<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs,Types_LockupV21Contract_CreateLockupLinearStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CreateLockupLinearStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CreateLockupLinearStream_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_CreateLockupLinearStreamEvent_eventArgs,Types_LockupV21Contract_CreateLockupLinearStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CreateLockupLinearStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CreateLockupDynamicStream_loader: (loader:loader<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs,Types_LockupV21Contract_CreateLockupDynamicStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CreateLockupDynamicStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Asset:Argcontext.Asset, Batch:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Batch.load, Arg12, Arg21.loaders);
          return result3
        }}, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CreateLockupDynamicStream_handler: (handler:handlerFunction<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs,Types_LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CreateLockupDynamicStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_CreateLockupDynamicStream_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_CreateLockupDynamicStreamEvent_eventArgs,Types_LockupV21Contract_CreateLockupDynamicStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.CreateLockupDynamicStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_RenounceLockupStream_loader: (loader:loader<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs,Types_LockupV21Contract_RenounceLockupStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.RenounceLockupStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_RenounceLockupStream_handler: (handler:handlerFunction<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs,Types_LockupV21Contract_RenounceLockupStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.RenounceLockupStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_RenounceLockupStream_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_RenounceLockupStreamEvent_eventArgs,Types_LockupV21Contract_RenounceLockupStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.RenounceLockupStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_Transfer_loader: (loader:loader<Types_LockupV21Contract_TransferEvent_eventArgs,Types_LockupV21Contract_TransferEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.Transfer.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_Transfer_handler: (handler:handlerFunction<Types_LockupV21Contract_TransferEvent_eventArgs,Types_LockupV21Contract_TransferEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.Transfer.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_Transfer_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_TransferEvent_eventArgs,Types_LockupV21Contract_TransferEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.Transfer.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_TransferAdmin_loader: (loader:loader<Types_LockupV21Contract_TransferAdminEvent_eventArgs,Types_LockupV21Contract_TransferAdminEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.TransferAdmin.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Contract:Argcontext.Contract, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_TransferAdmin_handler: (handler:handlerFunction<Types_LockupV21Contract_TransferAdminEvent_eventArgs,Types_LockupV21Contract_TransferAdminEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.TransferAdmin.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_TransferAdmin_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_TransferAdminEvent_eventArgs,Types_LockupV21Contract_TransferAdminEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.TransferAdmin.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_WithdrawFromLockupStream_loader: (loader:loader<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs,Types_LockupV21Contract_WithdrawFromLockupStreamEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.WithdrawFromLockupStream.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Stream:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Stream.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_WithdrawFromLockupStream_handler: (handler:handlerFunction<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs,Types_LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.WithdrawFromLockupStream.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const LockupV21Contract_WithdrawFromLockupStream_handlerAsync: (handler:handlerFunction<Types_LockupV21Contract_WithdrawFromLockupStreamEvent_eventArgs,Types_LockupV21Contract_WithdrawFromLockupStreamEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.LockupV21Contract.WithdrawFromLockupStream.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Asset:Argcontext.Asset, Batch:Argcontext.Batch, Batcher:Argcontext.Batcher, Contract:Argcontext.Contract, Segment:Argcontext.Segment, Stream:Argcontext.Stream, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};
