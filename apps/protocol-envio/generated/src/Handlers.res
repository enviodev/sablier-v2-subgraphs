type functionRegister = Loader | Handler

let mapFunctionRegisterName = (functionRegister: functionRegister) => {
  switch functionRegister {
  | Loader => "Loader"
  | Handler => "Handler"
  }
}

// This set makes sure that the warning doesn't print for every event of a type, but rather only prints the first time.
let hasPrintedWarning = Set.make()

@genType
type handlerFunction<'eventArgs, 'context, 'returned> = (
  ~event: Types.eventLog<'eventArgs>,
  ~context: 'context,
) => 'returned

@genType
type handlerWithContextGetter<
  'eventArgs,
  'context,
  'returned,
  'loaderContext,
  'handlerContextSync,
  'handlerContextAsync,
> = {
  handler: handlerFunction<'eventArgs, 'context, 'returned>,
  contextGetter: Context.genericContextCreatorFunctions<
    'loaderContext,
    'handlerContextSync,
    'handlerContextAsync,
  > => 'context,
}

@genType
type handlerWithContextGetterSyncAsync<
  'eventArgs,
  'loaderContext,
  'handlerContextSync,
  'handlerContextAsync,
> = SyncAsync.t<
  handlerWithContextGetter<
    'eventArgs,
    'handlerContextSync,
    unit,
    'loaderContext,
    'handlerContextSync,
    'handlerContextAsync,
  >,
  handlerWithContextGetter<
    'eventArgs,
    'handlerContextAsync,
    promise<unit>,
    'loaderContext,
    'handlerContextSync,
    'handlerContextAsync,
  >,
>

@genType
type loader<'eventArgs, 'loaderContext> = (
  ~event: Types.eventLog<'eventArgs>,
  ~context: 'loaderContext,
) => unit

let getDefaultLoaderHandler: (
  ~functionRegister: functionRegister,
  ~eventName: string,
  ~event: 'a,
  ~context: 'b,
) => unit = (~functionRegister, ~eventName, ~event as _, ~context as _) => {
  let functionName = mapFunctionRegisterName(functionRegister)

  // Here we use this key to prevent flooding the users terminal with
  let repeatKey = `${eventName}-${functionName}`
  if !(hasPrintedWarning->Set.has(repeatKey)) {
    // Here are docs on the 'terminal hyperlink' formatting that I use to link to the docs: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
    Logging.warn(
      `Skipped ${eventName} in the ${functionName}, as there is no ${functionName} registered. You need to implement a ${eventName}${functionName} method in your handler file or ignore this warning if you don't intend to implement it. Here are our docs on this topic: \\u001b]8;;https://docs.envio.dev/docs/event-handlers\u0007https://docs.envio.dev/docs/event-handlers\u001b]8;;\u0007`,
    )
    let _ = hasPrintedWarning->Set.add(repeatKey)
  }
}

let getDefaultLoaderHandlerWithContextGetter = (~functionRegister, ~eventName) => SyncAsync.Sync({
  handler: getDefaultLoaderHandler(~functionRegister, ~eventName),
  contextGetter: ctx => ctx.getHandlerContextSync(),
})

module LockupV20Contract = {
  module Approval = {
    open Types.LockupV20Contract.ApprovalEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let approvalLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let approvalHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      approvalLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      approvalHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      approvalHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      approvalLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Approval", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch approvalHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Approval", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module ApprovalForAll = {
    open Types.LockupV20Contract.ApprovalForAllEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let approvalForAllLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let approvalForAllHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      approvalForAllLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      approvalForAllHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      approvalForAllHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      approvalForAllLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="ApprovalForAll", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch approvalForAllHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="ApprovalForAll",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module CancelLockupStream = {
    open Types.LockupV20Contract.CancelLockupStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let cancelLockupStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let cancelLockupStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      cancelLockupStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      cancelLockupStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      cancelLockupStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      cancelLockupStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="CancelLockupStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch cancelLockupStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="CancelLockupStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module CreateLockupLinearStream = {
    open Types.LockupV20Contract.CreateLockupLinearStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let createLockupLinearStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let createLockupLinearStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      createLockupLinearStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      createLockupLinearStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      createLockupLinearStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      createLockupLinearStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="CreateLockupLinearStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch createLockupLinearStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="CreateLockupLinearStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module CreateLockupDynamicStream = {
    open Types.LockupV20Contract.CreateLockupDynamicStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let createLockupDynamicStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let createLockupDynamicStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      createLockupDynamicStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      createLockupDynamicStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      createLockupDynamicStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      createLockupDynamicStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="CreateLockupDynamicStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch createLockupDynamicStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="CreateLockupDynamicStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module RenounceLockupStream = {
    open Types.LockupV20Contract.RenounceLockupStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let renounceLockupStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let renounceLockupStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      renounceLockupStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      renounceLockupStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      renounceLockupStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      renounceLockupStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="RenounceLockupStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch renounceLockupStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="RenounceLockupStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module Transfer = {
    open Types.LockupV20Contract.TransferEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let transferLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let transferHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      transferLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      transferHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      transferHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      transferLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Transfer", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch transferHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Transfer", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module TransferAdmin = {
    open Types.LockupV20Contract.TransferAdminEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let transferAdminLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let transferAdminHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      transferAdminLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      transferAdminHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      transferAdminHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      transferAdminLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="TransferAdmin", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch transferAdminHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="TransferAdmin",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module WithdrawFromLockupStream = {
    open Types.LockupV20Contract.WithdrawFromLockupStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let withdrawFromLockupStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let withdrawFromLockupStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      withdrawFromLockupStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      withdrawFromLockupStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      withdrawFromLockupStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      withdrawFromLockupStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="WithdrawFromLockupStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch withdrawFromLockupStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="WithdrawFromLockupStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
}

module LockupV21Contract = {
  module Approval = {
    open Types.LockupV21Contract.ApprovalEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let approvalLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let approvalHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      approvalLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      approvalHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      approvalHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      approvalLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Approval", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch approvalHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Approval", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module ApprovalForAll = {
    open Types.LockupV21Contract.ApprovalForAllEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let approvalForAllLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let approvalForAllHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      approvalForAllLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      approvalForAllHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      approvalForAllHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      approvalForAllLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="ApprovalForAll", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch approvalForAllHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="ApprovalForAll",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module CancelLockupStream = {
    open Types.LockupV21Contract.CancelLockupStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let cancelLockupStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let cancelLockupStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      cancelLockupStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      cancelLockupStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      cancelLockupStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      cancelLockupStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="CancelLockupStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch cancelLockupStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="CancelLockupStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module CreateLockupLinearStream = {
    open Types.LockupV21Contract.CreateLockupLinearStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let createLockupLinearStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let createLockupLinearStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      createLockupLinearStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      createLockupLinearStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      createLockupLinearStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      createLockupLinearStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="CreateLockupLinearStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch createLockupLinearStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="CreateLockupLinearStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module CreateLockupDynamicStream = {
    open Types.LockupV21Contract.CreateLockupDynamicStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let createLockupDynamicStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let createLockupDynamicStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      createLockupDynamicStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      createLockupDynamicStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      createLockupDynamicStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      createLockupDynamicStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="CreateLockupDynamicStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch createLockupDynamicStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="CreateLockupDynamicStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module RenounceLockupStream = {
    open Types.LockupV21Contract.RenounceLockupStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let renounceLockupStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let renounceLockupStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      renounceLockupStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      renounceLockupStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      renounceLockupStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      renounceLockupStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="RenounceLockupStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch renounceLockupStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="RenounceLockupStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module Transfer = {
    open Types.LockupV21Contract.TransferEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let transferLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let transferHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      transferLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      transferHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      transferHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      transferLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Transfer", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch transferHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Transfer", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module TransferAdmin = {
    open Types.LockupV21Contract.TransferAdminEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let transferAdminLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let transferAdminHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      transferAdminLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      transferAdminHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      transferAdminHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      transferAdminLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="TransferAdmin", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch transferAdminHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="TransferAdmin",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module WithdrawFromLockupStream = {
    open Types.LockupV21Contract.WithdrawFromLockupStreamEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let withdrawFromLockupStreamLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let withdrawFromLockupStreamHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      withdrawFromLockupStreamLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      withdrawFromLockupStreamHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      withdrawFromLockupStreamHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      withdrawFromLockupStreamLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="WithdrawFromLockupStream", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch withdrawFromLockupStreamHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="WithdrawFromLockupStream",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
}
