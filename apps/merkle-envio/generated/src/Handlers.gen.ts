/* TypeScript file generated from Handlers.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const Curry = require('rescript/lib/js/curry.js');

// @ts-ignore: Implicit any on import
const HandlersBS = require('./Handlers.bs');

import type {MerkleLLV21Contract_ClaimEvent_eventArgs as Types_MerkleLLV21Contract_ClaimEvent_eventArgs} from './Types.gen';

import type {MerkleLLV21Contract_ClaimEvent_handlerContextAsync as Types_MerkleLLV21Contract_ClaimEvent_handlerContextAsync} from './Types.gen';

import type {MerkleLLV21Contract_ClaimEvent_handlerContext as Types_MerkleLLV21Contract_ClaimEvent_handlerContext} from './Types.gen';

import type {MerkleLLV21Contract_ClaimEvent_loaderContext as Types_MerkleLLV21Contract_ClaimEvent_loaderContext} from './Types.gen';

import type {MerkleLLV21Contract_ClawbackEvent_eventArgs as Types_MerkleLLV21Contract_ClawbackEvent_eventArgs} from './Types.gen';

import type {MerkleLLV21Contract_ClawbackEvent_handlerContextAsync as Types_MerkleLLV21Contract_ClawbackEvent_handlerContextAsync} from './Types.gen';

import type {MerkleLLV21Contract_ClawbackEvent_handlerContext as Types_MerkleLLV21Contract_ClawbackEvent_handlerContext} from './Types.gen';

import type {MerkleLLV21Contract_ClawbackEvent_loaderContext as Types_MerkleLLV21Contract_ClawbackEvent_loaderContext} from './Types.gen';

import type {MerkleLLV21Contract_TransferAdminEvent_eventArgs as Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs} from './Types.gen';

import type {MerkleLLV21Contract_TransferAdminEvent_handlerContextAsync as Types_MerkleLLV21Contract_TransferAdminEvent_handlerContextAsync} from './Types.gen';

import type {MerkleLLV21Contract_TransferAdminEvent_handlerContext as Types_MerkleLLV21Contract_TransferAdminEvent_handlerContext} from './Types.gen';

import type {MerkleLLV21Contract_TransferAdminEvent_loaderContext as Types_MerkleLLV21Contract_TransferAdminEvent_loaderContext} from './Types.gen';

import type {MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs as Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs} from './Types.gen';

import type {MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContextAsync as Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContextAsync} from './Types.gen';

import type {MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContext as Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContext} from './Types.gen';

import type {MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_loaderContext as Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_loaderContext} from './Types.gen';

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

export const MerkleLLV21Contract_Claim_loader: (loader:loader<Types_MerkleLLV21Contract_ClaimEvent_eventArgs,Types_MerkleLLV21Contract_ClaimEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.Claim.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Activity:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Activity.load, Arg12, Arg21.loaders);
          return result3
        }}, Campaign:{load:function (Arg13: any, Arg22: any) {
          const result4 = Curry._2(Argcontext.Campaign.load, Arg13, Arg22.loaders);
          return result4
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_Claim_handler: (handler:handlerFunction<Types_MerkleLLV21Contract_ClaimEvent_eventArgs,Types_MerkleLLV21Contract_ClaimEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.Claim.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_Claim_handlerAsync: (handler:handlerFunction<Types_MerkleLLV21Contract_ClaimEvent_eventArgs,Types_MerkleLLV21Contract_ClaimEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.Claim.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_Clawback_loader: (loader:loader<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs,Types_MerkleLLV21Contract_ClawbackEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.Clawback.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Campaign:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Campaign.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_Clawback_handler: (handler:handlerFunction<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs,Types_MerkleLLV21Contract_ClawbackEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.Clawback.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_Clawback_handlerAsync: (handler:handlerFunction<Types_MerkleLLV21Contract_ClawbackEvent_eventArgs,Types_MerkleLLV21Contract_ClawbackEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.Clawback.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_TransferAdmin_loader: (loader:loader<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs,Types_MerkleLLV21Contract_TransferAdminEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.TransferAdmin.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Campaign:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Campaign.load, Arg12, Arg21.loaders);
          return result3
        }}, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_TransferAdmin_handler: (handler:handlerFunction<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs,Types_MerkleLLV21Contract_TransferAdminEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.TransferAdmin.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLLV21Contract_TransferAdmin_handlerAsync: (handler:handlerFunction<Types_MerkleLLV21Contract_TransferAdminEvent_eventArgs,Types_MerkleLLV21Contract_TransferAdminEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLLV21Contract.TransferAdmin.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL_loader: (loader:loader<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs,Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLL.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Asset:Argcontext.Asset, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL_handler: (handler:handlerFunction<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs,Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLL.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};

export const MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL_handlerAsync: (handler:handlerFunction<Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_eventArgs,Types_MerkleLockupFactoryV21Contract_CreateMerkleStreamerLLEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLL.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Action:Argcontext.Action, Activity:Argcontext.Activity, Asset:Argcontext.Asset, Campaign:Argcontext.Campaign, Factory:Argcontext.Factory, Watcher:Argcontext.Watcher}});
      return result1
    });
  return result
};
