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

module MerkleLLV21Contract = {
  module Claim = {
    open Types.MerkleLLV21Contract.ClaimEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let claimLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let claimHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      claimLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      claimHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      claimHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      claimLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Claim", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch claimHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Claim", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module Clawback = {
    open Types.MerkleLLV21Contract.ClawbackEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let clawbackLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let clawbackHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      clawbackLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      clawbackHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      clawbackHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      clawbackLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Clawback", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch clawbackHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Clawback", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module TransferAdmin = {
    open Types.MerkleLLV21Contract.TransferAdminEvent

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
}

module MerkleLockupFactoryV21Contract = {
  module CreateMerkleStreamerLL = {
    open Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let createMerkleStreamerLLLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let createMerkleStreamerLLHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      createMerkleStreamerLLLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      createMerkleStreamerLLHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      createMerkleStreamerLLHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      createMerkleStreamerLLLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="CreateMerkleStreamerLL", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch createMerkleStreamerLLHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="CreateMerkleStreamerLL",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
}
