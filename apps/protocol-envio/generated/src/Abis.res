// TODO: move to `eventFetching`

let lockupV20Abi = `
[{"type":"event","name":"Approval","inputs":[{"name":"owner","type":"address","indexed":true},{"name":"approved","type":"address","indexed":true},{"name":"tokenId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"ApprovalForAll","inputs":[{"name":"owner","type":"address","indexed":true},{"name":"operator","type":"address","indexed":true},{"name":"approved","type":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"CancelLockupStream","inputs":[{"name":"streamId","type":"uint256","indexed":true},{"name":"sender","type":"address","indexed":true},{"name":"recipient","type":"address","indexed":true},{"name":"senderAmount","type":"uint128","indexed":false},{"name":"recipientAmount","type":"uint128","indexed":false}],"anonymous":false},{"type":"event","name":"CreateLockupDynamicStream","inputs":[{"name":"streamId","type":"uint256","indexed":false},{"name":"funder","type":"address","indexed":false},{"name":"sender","type":"address","indexed":true},{"name":"recipient","type":"address","indexed":true},{"name":"amounts","type":"tuple","indexed":false,"components":[{"type":"uint128"},{"type":"uint128"},{"type":"uint128"}]},{"name":"asset","type":"address","indexed":true},{"name":"cancelable","type":"bool","indexed":false},{"name":"segments","type":"tuple[]","indexed":false,"components":[{"type":"uint128"},{"type":"uint64"},{"type":"uint40"}]},{"name":"range","type":"tuple","indexed":false,"components":[{"type":"uint40"},{"type":"uint40"}]},{"name":"broker","type":"address","indexed":false}],"anonymous":false},{"type":"event","name":"CreateLockupLinearStream","inputs":[{"name":"streamId","type":"uint256","indexed":false},{"name":"funder","type":"address","indexed":false},{"name":"sender","type":"address","indexed":true},{"name":"recipient","type":"address","indexed":true},{"name":"amounts","type":"tuple","indexed":false,"components":[{"type":"uint128"},{"type":"uint128"},{"type":"uint128"}]},{"name":"asset","type":"address","indexed":true},{"name":"cancelable","type":"bool","indexed":false},{"name":"range","type":"tuple","indexed":false,"components":[{"type":"uint40"},{"type":"uint40"},{"type":"uint40"}]},{"name":"broker","type":"address","indexed":false}],"anonymous":false},{"type":"event","name":"RenounceLockupStream","inputs":[{"name":"streamId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"name":"from","type":"address","indexed":true},{"name":"to","type":"address","indexed":true},{"name":"tokenId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"TransferAdmin","inputs":[{"name":"oldAdmin","type":"address","indexed":true},{"name":"newAdmin","type":"address","indexed":true}],"anonymous":false},{"type":"event","name":"WithdrawFromLockupStream","inputs":[{"name":"streamId","type":"uint256","indexed":true},{"name":"to","type":"address","indexed":true},{"name":"amount","type":"uint128","indexed":false}],"anonymous":false}]
`->Js.Json.parseExn
let lockupV21Abi = `
[{"type":"event","name":"Approval","inputs":[{"name":"owner","type":"address","indexed":true},{"name":"approved","type":"address","indexed":true},{"name":"tokenId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"ApprovalForAll","inputs":[{"name":"owner","type":"address","indexed":true},{"name":"operator","type":"address","indexed":true},{"name":"approved","type":"bool","indexed":false}],"anonymous":false},{"type":"event","name":"CancelLockupStream","inputs":[{"name":"streamId","type":"uint256","indexed":false},{"name":"sender","type":"address","indexed":true},{"name":"recipient","type":"address","indexed":true},{"name":"asset","type":"address","indexed":true},{"name":"senderAmount","type":"uint128","indexed":false},{"name":"recipientAmount","type":"uint128","indexed":false}],"anonymous":false},{"type":"event","name":"CreateLockupDynamicStream","inputs":[{"name":"streamId","type":"uint256","indexed":false},{"name":"funder","type":"address","indexed":false},{"name":"sender","type":"address","indexed":true},{"name":"recipient","type":"address","indexed":true},{"name":"amounts","type":"tuple","indexed":false,"components":[{"type":"uint128"},{"type":"uint128"},{"type":"uint128"}]},{"name":"asset","type":"address","indexed":true},{"name":"cancelable","type":"bool","indexed":false},{"name":"transferable","type":"bool","indexed":false},{"name":"segments","type":"tuple[]","indexed":false,"components":[{"type":"uint128"},{"type":"uint64"},{"type":"uint40"}]},{"name":"range","type":"tuple","indexed":false,"components":[{"type":"uint40"},{"type":"uint40"}]},{"name":"broker","type":"address","indexed":false}],"anonymous":false},{"type":"event","name":"CreateLockupLinearStream","inputs":[{"name":"streamId","type":"uint256","indexed":false},{"name":"funder","type":"address","indexed":false},{"name":"sender","type":"address","indexed":true},{"name":"recipient","type":"address","indexed":true},{"name":"amounts","type":"tuple","indexed":false,"components":[{"type":"uint128"},{"type":"uint128"},{"type":"uint128"}]},{"name":"asset","type":"address","indexed":true},{"name":"cancelable","type":"bool","indexed":false},{"name":"transferable","type":"bool","indexed":false},{"name":"range","type":"tuple","indexed":false,"components":[{"type":"uint40"},{"type":"uint40"},{"type":"uint40"}]},{"name":"broker","type":"address","indexed":false}],"anonymous":false},{"type":"event","name":"RenounceLockupStream","inputs":[{"name":"streamId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"name":"from","type":"address","indexed":true},{"name":"to","type":"address","indexed":true},{"name":"tokenId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"TransferAdmin","inputs":[{"name":"oldAdmin","type":"address","indexed":true},{"name":"newAdmin","type":"address","indexed":true}],"anonymous":false},{"type":"event","name":"WithdrawFromLockupStream","inputs":[{"name":"streamId","type":"uint256","indexed":true},{"name":"to","type":"address","indexed":true},{"name":"asset","type":"address","indexed":true},{"name":"amount","type":"uint128","indexed":false}],"anonymous":false}]
`->Js.Json.parseExn
