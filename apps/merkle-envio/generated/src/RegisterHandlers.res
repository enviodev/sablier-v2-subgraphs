let registerMerkleLLV21Handlers = () => {
  try {
    let _ = %raw(`require("../../src/mappings/index.ts")`)
  } catch {
  | err => {
      Logging.error(
        "EE500: There was an issue importing the handler file for MerkleLLV21. Expected file to parse at src/mappings/index.ts",
      )
      Js.log(err)
    }
  }
}
let registerMerkleLockupFactoryV21Handlers = () => {
  try {
    let _ = %raw(`require("../../src/mappings/index.ts")`)
  } catch {
  | err => {
      Logging.error(
        "EE500: There was an issue importing the handler file for MerkleLockupFactoryV21. Expected file to parse at src/mappings/index.ts",
      )
      Js.log(err)
    }
  }
}

let registerAllHandlers = () => {
  registerMerkleLLV21Handlers()
  registerMerkleLockupFactoryV21Handlers()
}
