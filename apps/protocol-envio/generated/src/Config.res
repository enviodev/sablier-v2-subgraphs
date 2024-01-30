type contract = {
  name: string,
  abi: Ethers.abi,
  addresses: array<Ethers.ethAddress>,
  events: array<Types.eventName>,
}

type syncConfig = {
  initialBlockInterval: int,
  backoffMultiplicative: float,
  accelerationAdditive: int,
  intervalCeiling: int,
  backoffMillis: int,
  queryTimeoutMillis: int,
}

type serverUrl = string

type rpcConfig = {
  provider: Ethers.JsonRpcProvider.t,
  syncConfig: syncConfig,
}

type syncSource = Rpc(rpcConfig) | HyperSync(serverUrl)

type chainConfig = {
  syncSource: syncSource,
  startBlock: int,
  chainId: int,
  contracts: array<contract>,
}

type chainConfigs = Js.Dict.t<chainConfig>

// Logging:
%%private(let envSafe = EnvSafe.make())

let getLogLevelConfig = (~name, ~default): Pino.logLevel =>
  envSafe->EnvSafe.get(
    ~name,
    ~struct=S.union([
      S.literalVariant(String("trace"), #trace),
      S.literalVariant(String("debug"), #debug),
      S.literalVariant(String("info"), #info),
      S.literalVariant(String("warn"), #warn),
      S.literalVariant(String("error"), #error),
      S.literalVariant(String("fatal"), #fatal),
      S.literalVariant(String("udebug"), #udebug),
      S.literalVariant(String("uinfo"), #uinfo),
      S.literalVariant(String("uwarn"), #uwarn),
      S.literalVariant(String("uerror"), #uerror),
      S.literalVariant(String(""), default),
      S.literalVariant(EmptyOption, default),
    ]),
    (),
  )

let isUnorderedHeadMode =
  envSafe->EnvSafe.get(
    ~name="UNSTABLE__TEMP_UNORDERED_HEAD_MODE",
    ~struct=S.bool(),
    ~devFallback=false,
    (),
  )

let logFilePath =
  envSafe->EnvSafe.get(~name="LOG_FILE", ~struct=S.string(), ~devFallback="logs/envio.log", ())
let userLogLevel = getLogLevelConfig(~name="LOG_LEVEL", ~default=#info)
let defaultFileLogLevel = getLogLevelConfig(~name="FILE_LOG_LEVEL", ~default=#trace)

type logStrategyType = EcsFile | EcsConsole | FileOnly | ConsoleRaw | ConsolePretty | Both
let logStrategy = envSafe->EnvSafe.get(
  ~name="LOG_STRATEGY",
  ~struct=S.union([
    S.literalVariant(String("ecs-file"), EcsFile),
    S.literalVariant(String("ecs-console"), EcsConsole),
    S.literalVariant(String("file-only"), FileOnly),
    S.literalVariant(String("console-raw"), ConsoleRaw),
    S.literalVariant(String("console-pretty"), ConsolePretty),
    S.literalVariant(String("both-prettyconsole"), Both),
    // Two default values are pretty print to the console only.
    S.literalVariant(String(""), ConsolePretty),
    S.literalVariant(EmptyOption, ConsolePretty),
  ]),
  (),
)

let db: Postgres.poolConfig = {
  host: envSafe->EnvSafe.get(
    ~name="ENVIO_PG_HOST",
    ~struct=S.string(),
    ~devFallback="localhost",
    (),
  ),
  port: envSafe->EnvSafe.get(
    ~name="ENVIO_PG_PORT",
    ~struct=S.int()->S.Int.port(),
    ~devFallback=5433,
    (),
  ),
  user: envSafe->EnvSafe.get(
    ~name="ENVIO_PG_USER",
    ~struct=S.string(),
    ~devFallback="postgres",
    (),
  ),
  password: envSafe->EnvSafe.get(
    ~name="ENVIO_POSTGRES_PASSWORD",
    ~struct=S.string(),
    ~devFallback="testing",
    (),
  ),
  database: envSafe->EnvSafe.get(
    ~name="ENVIO_PG_DATABASE",
    ~struct=S.string(),
    ~devFallback="envio-dev",
    (),
  ),
  ssl: envSafe->EnvSafe.get(
    ~name="ENVIO_PG_SSL_MODE",
    ~struct=S.string(),
    //this is a dev fallback option for local deployments, shouldn't run in the prod env
    //the SSL modes should be provided as string otherwise as 'require' | 'allow' | 'prefer' | 'verify-full'
    ~devFallback=false->Obj.magic,
    (),
  ),
  // TODO: think how we want to pipe these logs to pino.
  onnotice: userLogLevel == #warn || userLogLevel == #error ? None : Some(() => ()),
}

let config: chainConfigs = [
  (
    "1",
    {
      syncSource: HyperSync("https://eth.hypersync.xyz"),
      startBlock: 17613130,
      chainId: 1,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0xb10daee1fcf62243ae27776d7a92d39dc8740f95"->Ethers.getAddressFromStringUnsafe,
            "0x39efdc3dbb57b2388ccc4bb40ac4cb1226bc9e44"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0xafb979d9afad1ad27c5eff4e27226e3ab9e5dcc9"->Ethers.getAddressFromStringUnsafe,
            "0x7cc7e125d83a581ff438608490cc0f7bdff79127"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "10",
    {
      syncSource: HyperSync("https://optimism.hypersync.xyz"),
      startBlock: 106405050,
      chainId: 10,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0xb923abdca17aed90eb5ec5e407bd37164f632bfd"->Ethers.getAddressFromStringUnsafe,
            "0x6f68516c21e248cddfaf4898e66b2b0adee0e0d6"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0x4b45090152a5731b5bc71b5baf71e60e05b33867"->Ethers.getAddressFromStringUnsafe,
            "0xd6920c1094eabc4b71f3dc411a1566f64f4c206e"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "56",
    {
      syncSource: HyperSync("https://bsc.hypersync.xyz"),
      startBlock: 29646270,
      chainId: 56,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0x3fe4333f62a75c2a85c8211c6aefd1b9bfde6e51"->Ethers.getAddressFromStringUnsafe,
            "0xf2f3fef2454dca59eca929d2d8cd2a8669cc6214"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0x14c35e126d75234a90c9fb185bf8ad3edb6a90d2"->Ethers.getAddressFromStringUnsafe,
            "0xf900c5e3aa95b59cc976e6bc9c0998618729a5fa"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "100",
    {
      syncSource: HyperSync("https://gnosis.hypersync.xyz"),
      startBlock: 28766600,
      chainId: 100,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0x685e92c9ca2bb23f1b596d0a7d749c0603e88585"->Ethers.getAddressFromStringUnsafe,
            "0xeb148e4ec13aaa65328c0ba089a278138e9e53f9"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0xce49854a647a1723e8fb7cc3d190cab29a44ab48"->Ethers.getAddressFromStringUnsafe,
            "0x1df83c7682080b0f0c26a20c6c9cb8623e0df24e"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "137",
    {
      syncSource: HyperSync("https://polygon.hypersync.xyz"),
      startBlock: 44637120,
      chainId: 137,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0x67422c3e36a908d5c3237e9cffeb40bde7060f6e"->Ethers.getAddressFromStringUnsafe,
            "0x7313addb53f96a4f710d3b91645c62b434190725"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0x5f0e1dea4a635976ef51ec2a2ed41490d1eba003"->Ethers.getAddressFromStringUnsafe,
            "0xb194c7278c627d52e440316b74c5f24fc70c1565"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "8453",
    {
      syncSource: HyperSync("https://base.hypersync.xyz"),
      startBlock: 1750270,
      chainId: 8453,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0x6b9a46c8377f21517e65fa3899b3a9fab19d17f5"->Ethers.getAddressFromStringUnsafe,
            "0x645b00960dc352e699f89a81fc845c0c645231cf"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0xfcf737582d167c7d20a336532eb8bcca8cf8e350"->Ethers.getAddressFromStringUnsafe,
            "0x461e13056a3a3265cef4c593f01b2e960755de91"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "42161",
    {
      syncSource: HyperSync("https://arbitrum.hypersync.xyz"),
      startBlock: 107509950,
      chainId: 42161,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0x197d655f3be03903fd25e7828c3534504bfe525e"->Ethers.getAddressFromStringUnsafe,
            "0xa9efbef1a35ff80041f567391bdc9813b2d50197"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0xfdd9d122b451f549f48c4942c6fa6646d849e8c1"->Ethers.getAddressFromStringUnsafe,
            "0xf390ce6f54e4dc7c5a5f7f8689062b7591f7111d"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "43114",
    {
      syncSource: HyperSync("https://avalanche.hypersync.xyz"),
      startBlock: 32164210,
      chainId: 43114,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0x610346e9088afa70d6b03e96a800b3267e75ca19"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0x665d1c8337f1035cfbe13dd94bb669110b975f5f"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "534352",
    {
      syncSource: HyperSync("https://scroll.hypersync.xyz"),
      startBlock: 284000,
      chainId: 534352,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0x80640ca758615ee83801ec43452feea09a202d33"->Ethers.getAddressFromStringUnsafe,
            "0xde6a30d851efd0fc2a9c922f294801cfd5fcb3a1"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0x57e14ab4dad920548899d86b54ad47ea27f00987"->Ethers.getAddressFromStringUnsafe,
            "0xaaff2d11f9e7cd2a9cdc674931fac0358a165995"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
  (
    "11155111",
    {
      syncSource: HyperSync("https://sepolia.hypersync.xyz"),
      startBlock: 4067889,
      chainId: 11155111,
      contracts: [
        {
          name: "LockupV20",
          abi: Abis.lockupV20Abi->Ethers.makeAbi,
          addresses: [
            "0xd4300c5bc0b9e27c73ebabdc747ba990b1b570db"->Ethers.getAddressFromStringUnsafe,
            "0x421e1e7a53ff360f70a2d02037ee394fa474e035"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV20_Approval,
            LockupV20_ApprovalForAll,
            LockupV20_CancelLockupStream,
            LockupV20_CreateLockupLinearStream,
            LockupV20_CreateLockupDynamicStream,
            LockupV20_RenounceLockupStream,
            LockupV20_Transfer,
            LockupV20_TransferAdmin,
            LockupV20_WithdrawFromLockupStream,
          ],
        },
        {
          name: "LockupV21",
          abi: Abis.lockupV21Abi->Ethers.makeAbi,
          addresses: [
            "0x7a43f8a888fa15e68c103e18b0439eb1e98e4301"->Ethers.getAddressFromStringUnsafe,
            "0xc9940ad8f43aad8e8f33a4d5dbbf0a8f7ff4429a"->Ethers.getAddressFromStringUnsafe,
          ],
          events: [
            LockupV21_Approval,
            LockupV21_ApprovalForAll,
            LockupV21_CancelLockupStream,
            LockupV21_CreateLockupLinearStream,
            LockupV21_CreateLockupDynamicStream,
            LockupV21_RenounceLockupStream,
            LockupV21_Transfer,
            LockupV21_TransferAdmin,
            LockupV21_WithdrawFromLockupStream,
          ],
        },
      ],
    },
  ),
]->Js.Dict.fromArray

let metricsPort =
  envSafe->EnvSafe.get(~name="METRICS_PORT", ~struct=S.int()->S.Int.port(), ~devFallback=9898, ())

// You need to close the envSafe after you're done with it so that it immediately tells you about your  misconfigured environment on startup.
envSafe->EnvSafe.close()
