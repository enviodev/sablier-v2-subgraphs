let registerLockupV20Handlers = () => {
  try {
    let _ = %raw(`require("../../src/mappings/index.ts")`)
  } catch {
  | err => {
      Logging.error(
        "EE500: There was an issue importing the handler file for LockupV20. Expected file to parse at src/mappings/index.ts",
      )
      Js.log(err)
    }
  }
}
let registerLockupV21Handlers = () => {
  try {
    let _ = %raw(`require("../../src/mappings/index.ts")`)
  } catch {
  | err => {
      Logging.error(
        "EE500: There was an issue importing the handler file for LockupV21. Expected file to parse at src/mappings/index.ts",
      )
      Js.log(err)
    }
  }
}

let registerAllHandlers = () => {
  registerLockupV20Handlers()
  registerLockupV21Handlers()
}
