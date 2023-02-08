import { BigInt, dataSource, ethereum, log } from "@graphprotocol/graph-ts";
import { Stream } from "../generated/types/schema";
import { CreateLockupLinearStream as EventCreateLinear } from "../generated/types/templates/ContractLockupLinear/SablierV2LockupLinear";
import { CreateLockupProStream as EventCreatePro } from "../generated/types/templates/ContractLockupPro/SablierV2LockupPro";
import { getChainId, one, zero } from "../constants";
import {
  generateStreamAlias,
  generateStreamId,
  getContractById,
  getOrCreateAsset,
  getOrCreateBatch,
  getOrCreateWatcher,
} from "../helpers";
import { createSegments } from "./segments";

function createStream(tokenId: BigInt, event: ethereum.Event): Stream | null {
  let watcher = getOrCreateWatcher();
  let contract = getContractById(dataSource.address().toHexString());
  if (contract == null) {
    log.critical(
      "[SABLIER] Contract hasn't been registered before this create event: {}",
      [dataSource.address().toHexString()],
    );
    return null;
  }

  /** --------------- */
  let id = generateStreamId(tokenId);
  if (id == null) {
    return null;
  }

  let alias = generateStreamAlias(tokenId);

  /** --------------- */
  let entity = new Stream(id);
  /** --------------- */
  entity.tokenId = tokenId;
  entity.alias = alias;
  entity.contract = contract.id;
  entity.subgraphId = watcher.streamIndex;
  entity.hash = event.transaction.hash;
  entity.timestamp = event.block.timestamp;
  entity.chainId = getChainId();

  /** --------------- */
  entity.canceled = false;
  entity.cancelableAction = null;
  entity.canceledAction = null;
  entity.cliffAmount = null;
  entity.cliffTime = null;
  entity.withdrawnAmount = zero;

  /** --------------- */
  watcher.streamIndex = watcher.streamIndex.plus(one);
  watcher.save();

  return entity;
}

export function createLinearStream(event: EventCreateLinear): Stream | null {
  let tokenId = event.params.streamId;
  let entity = createStream(tokenId, event);

  if (entity == null) {
    return null;
  }

  /** --------------- */
  entity.funder = event.params.funder;
  entity.sender = event.params.sender;
  entity.recipient = event.params.recipient;
  entity.parties = [event.params.sender, event.params.recipient];

  entity.depositAmount = event.params.amounts.deposit;
  entity.brokerFeeAmount = event.params.amounts.brokerFee;
  entity.protocolFeeAmount = event.params.amounts.protocolFee;
  entity.intactAmount = event.params.amounts.deposit;

  entity.startTime = event.params.range.start;
  entity.endTime = event.params.range.end;
  entity.cancelable = event.params.cancelable;

  /** --------------- */
  entity.cliffTime = event.params.range.cliff;
  let duration = event.params.range.end.minus(event.params.range.start);
  let cliff = event.params.range.cliff.minus(event.params.range.start);
  if (!cliff.isZero()) {
    entity.cliffAmount = entity.depositAmount.times(cliff.div(duration));
  }
  entity.category = cliff.isZero() ? "Linear" : "Cliff";

  /** --------------- */
  let asset = getOrCreateAsset(event.params.asset);
  entity.asset = asset.id;

  /** --------------- */
  let batch = getOrCreateBatch(event, event.params.sender);
  entity.batch = batch.id;

  entity.save();
  return entity;
}

export function createProStream(event: EventCreatePro): Stream | null {
  let tokenId = event.params.streamId;
  let entity = createStream(tokenId, event);

  if (entity == null) {
    return null;
  }

  /** --------------- */
  entity.category = "Pro";
  entity.funder = event.params.funder;
  entity.sender = event.params.sender;
  entity.recipient = event.params.recipient;
  entity.parties = [event.params.sender, event.params.recipient];

  entity.depositAmount = event.params.amounts.deposit;
  entity.brokerFeeAmount = event.params.amounts.brokerFee;
  entity.protocolFeeAmount = event.params.amounts.protocolFee;
  entity.intactAmount = event.params.amounts.deposit;

  entity.startTime = event.params.range.start;
  entity.endTime = event.params.range.end;
  entity.cancelable = event.params.cancelable;

  /** --------------- */
  let asset = getOrCreateAsset(event.params.asset);
  entity.asset = asset.id;

  /** --------------- */
  let batch = getOrCreateBatch(event, event.params.sender);
  entity.batch = batch.id;

  /** --------------- */
  entity.save();

  /** --------------- */
  entity = createSegments(entity, event);

  /** --------------- */
  return entity;
}
