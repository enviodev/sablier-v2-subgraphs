// TODO: move to `eventFetching`

let merkleLLV21Abi = `
[{"type":"event","name":"Claim","inputs":[{"name":"index","type":"uint256","indexed":false},{"name":"recipient","type":"address","indexed":true},{"name":"amount","type":"uint128","indexed":false},{"name":"streamId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"Clawback","inputs":[{"name":"admin","type":"address","indexed":true},{"name":"to","type":"address","indexed":true},{"name":"amount","type":"uint128","indexed":false}],"anonymous":false},{"type":"event","name":"TransferAdmin","inputs":[{"name":"oldAdmin","type":"address","indexed":true},{"name":"newAdmin","type":"address","indexed":true}],"anonymous":false}]
`->Js.Json.parseExn
let merkleLockupFactoryV21Abi = `
[{"type":"event","name":"CreateMerkleStreamerLL","inputs":[{"name":"merkleStreamer","type":"address","indexed":false},{"name":"admin","type":"address","indexed":true},{"name":"lockupLinear","type":"address","indexed":true},{"name":"asset","type":"address","indexed":true},{"name":"merkleRoot","type":"bytes32","indexed":false},{"name":"expiration","type":"uint40","indexed":false},{"name":"streamDurations","type":"tuple","indexed":false,"components":[{"type":"uint40"},{"type":"uint40"}]},{"name":"cancelable","type":"bool","indexed":false},{"name":"transferable","type":"bool","indexed":false},{"name":"ipfsCID","type":"string","indexed":false},{"name":"aggregateAmount","type":"uint256","indexed":false},{"name":"recipientsCount","type":"uint256","indexed":false}],"anonymous":false}]
`->Js.Json.parseExn
