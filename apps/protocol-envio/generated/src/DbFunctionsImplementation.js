// db operations for raw_events:
const MAX_ITEMS_PER_QUERY = 500;

module.exports.readLatestSyncedEventOnChainId = (sql, chainId) => sql`
  SELECT *
  FROM public.event_sync_state
  WHERE chain_id = ${chainId}`;

module.exports.batchSetEventSyncState = (sql, entityDataArray) => {
  return sql`
    INSERT INTO public.event_sync_state
  ${sql(
    entityDataArray,
    "chain_id",
    "block_number",
    "log_index",
    "transaction_index",
    "block_timestamp"
  )}
    ON CONFLICT(chain_id) DO UPDATE
    SET
    "chain_id" = EXCLUDED."chain_id",
    "block_number" = EXCLUDED."block_number",
    "log_index" = EXCLUDED."log_index",
    "transaction_index" = EXCLUDED."transaction_index",
    "block_timestamp" = EXCLUDED."block_timestamp";
    `;
};

module.exports.setChainMetadata = (sql, entityDataArray) => {
  return (sql`
    INSERT INTO public.chain_metadata
  ${sql(
    entityDataArray,
    "chain_id",
    "start_block", // this is left out of the on conflict below as it only needs to be set once
    "block_height"
  )}
  ON CONFLICT(chain_id) DO UPDATE
  SET
  "chain_id" = EXCLUDED."chain_id",
  "block_height" = EXCLUDED."block_height";`).then(res => {
    
  }).catch(err => {
    console.log("errored", err)
  });
};

module.exports.readLatestRawEventsBlockNumberProcessedOnChainId = (
  sql,
  chainId
) => sql`
  SELECT block_number
  FROM "public"."raw_events"
  WHERE chain_id = ${chainId}
  ORDER BY event_id DESC
  LIMIT 1;`;

module.exports.readRawEventsEntities = (sql, entityIdArray) => sql`
  SELECT *
  FROM "public"."raw_events"
  WHERE (chain_id, event_id) IN ${sql(entityIdArray)}`;

module.exports.getRawEventsPageGtOrEqEventId = (
  sql,
  chainId,
  eventId,
  limit,
  contractAddresses
) => sql`
  SELECT *
  FROM "public"."raw_events"
  WHERE "chain_id" = ${chainId}
  AND "event_id" >= ${eventId}
  AND "src_address" IN ${sql(contractAddresses)}
  ORDER BY "event_id" ASC
  LIMIT ${limit}
`;

module.exports.getRawEventsPageWithinEventIdRangeInclusive = (
  sql,
  chainId,
  fromEventIdInclusive,
  toEventIdInclusive,
  limit,
  contractAddresses
) => sql`
  SELECT *
  FROM public.raw_events
  WHERE "chain_id" = ${chainId}
  AND "event_id" >= ${fromEventIdInclusive}
  AND "event_id" <= ${toEventIdInclusive}
  AND "src_address" IN ${sql(contractAddresses)}
  ORDER BY "event_id" ASC
  LIMIT ${limit}
`;

const batchSetRawEventsCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."raw_events"
  ${sql(
    entityDataArray,
    "chain_id",
    "event_id",
    "block_number",
    "log_index",
    "transaction_index",
    "transaction_hash",
    "src_address",
    "block_hash",
    "block_timestamp",
    "event_type",
    "params"
  )}
    ON CONFLICT(chain_id, event_id) DO UPDATE
    SET
    "chain_id" = EXCLUDED."chain_id",
    "event_id" = EXCLUDED."event_id",
    "block_number" = EXCLUDED."block_number",
    "log_index" = EXCLUDED."log_index",
    "transaction_index" = EXCLUDED."transaction_index",
    "transaction_hash" = EXCLUDED."transaction_hash",
    "src_address" = EXCLUDED."src_address",
    "block_hash" = EXCLUDED."block_hash",
    "block_timestamp" = EXCLUDED."block_timestamp",
    "event_type" = EXCLUDED."event_type",
    "params" = EXCLUDED."params";`;
};

const chunkBatchQuery = (
  sql,
  entityDataArray,
  queryToExecute
) => {
  const promises = [];

  // Split entityDataArray into chunks of MAX_ITEMS_PER_QUERY
  for (let i = 0; i < entityDataArray.length; i += MAX_ITEMS_PER_QUERY) {
    const chunk = entityDataArray.slice(i, i + MAX_ITEMS_PER_QUERY);

    promises.push(queryToExecute(sql, chunk));
  }

  // Execute all promises
  return Promise.all(promises).catch(e => {
    console.error("Sql query failed", e);
    throw e;
    });
};

module.exports.batchSetRawEvents = (sql, entityDataArray) => {
  return chunkBatchQuery(
    sql,
    entityDataArray,
    batchSetRawEventsCore
  );
};

module.exports.batchDeleteRawEvents = (sql, entityIdArray) => sql`
  DELETE
  FROM "public"."raw_events"
  WHERE (chain_id, event_id) IN ${sql(entityIdArray)};`;
// end db operations for raw_events

module.exports.readDynamicContractsOnChainIdAtOrBeforeBlock = (
  sql,
  chainId,
  block_number
) => sql`
  SELECT c.contract_address, c.contract_type, c.event_id
  FROM "public"."dynamic_contract_registry" as c
  JOIN raw_events e ON c.chain_id = e.chain_id
  AND c.event_id = e.event_id
  WHERE e.block_number <= ${block_number} AND e.chain_id = ${chainId};`;

//Start db operations dynamic_contract_registry
module.exports.readDynamicContractRegistryEntities = (
  sql,
  entityIdArray
) => sql`
  SELECT *
  FROM "public"."dynamic_contract_registry"
  WHERE (chain_id, contract_address) IN ${sql(entityIdArray)}`;

const batchSetDynamicContractRegistryCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."dynamic_contract_registry"
  ${sql(
    entityDataArray,
    "chain_id",
    "event_id",
    "contract_address",
    "contract_type"
  )}
    ON CONFLICT(chain_id, contract_address) DO UPDATE
    SET
    "chain_id" = EXCLUDED."chain_id",
    "event_id" = EXCLUDED."event_id",
    "contract_address" = EXCLUDED."contract_address",
    "contract_type" = EXCLUDED."contract_type";`;
};

module.exports.batchSetDynamicContractRegistry = (sql, entityDataArray) => {
  return chunkBatchQuery(
    sql,
    entityDataArray,
    batchSetDynamicContractRegistryCore
  );
};

module.exports.batchDeleteDynamicContractRegistry = (sql, entityIdArray) => sql`
  DELETE
  FROM "public"."dynamic_contract_registry"
  WHERE (chain_id, contract_address) IN ${sql(entityIdArray)};`;
// end db operations for dynamic_contract_registry

//////////////////////////////////////////////
// DB operations for Action:
//////////////////////////////////////////////

module.exports.readActionEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"addressA",
"addressB",
"amountA",
"amountB",
"block",
"category",
"chainId",
"contract",
"hash",
"from",
"stream",
"subgraphId",
"timestamp"
FROM "public"."Action"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetActionCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Action"
${sql(entityDataArray,
    "id",
    "addressA",
    "addressB",
    "amountA",
    "amountB",
    "block",
    "category",
    "chainId",
    "contract",
    "hash",
    "from",
    "stream",
    "subgraphId",
    "timestamp"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "addressA" = EXCLUDED."addressA",
  "addressB" = EXCLUDED."addressB",
  "amountA" = EXCLUDED."amountA",
  "amountB" = EXCLUDED."amountB",
  "block" = EXCLUDED."block",
  "category" = EXCLUDED."category",
  "chainId" = EXCLUDED."chainId",
  "contract" = EXCLUDED."contract",
  "hash" = EXCLUDED."hash",
  "from" = EXCLUDED."from",
  "stream" = EXCLUDED."stream",
  "subgraphId" = EXCLUDED."subgraphId",
  "timestamp" = EXCLUDED."timestamp"
  `;
}

module.exports.batchSetAction = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetActionCore
  );
}

module.exports.batchDeleteAction = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Action"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Action

//////////////////////////////////////////////
// DB operations for Asset:
//////////////////////////////////////////////

module.exports.readAssetEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"address",
"chainId",
"decimals",
"name",
"symbol"
FROM "public"."Asset"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetAssetCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Asset"
${sql(entityDataArray,
    "id",
    "address",
    "chainId",
    "decimals",
    "name",
    "symbol"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "address" = EXCLUDED."address",
  "chainId" = EXCLUDED."chainId",
  "decimals" = EXCLUDED."decimals",
  "name" = EXCLUDED."name",
  "symbol" = EXCLUDED."symbol"
  `;
}

module.exports.batchSetAsset = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetAssetCore
  );
}

module.exports.batchDeleteAsset = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Asset"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Asset

//////////////////////////////////////////////
// DB operations for Batch:
//////////////////////////////////////////////

module.exports.readBatchEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"size",
"label",
"batcher",
"hash",
"timestamp"
FROM "public"."Batch"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetBatchCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Batch"
${sql(entityDataArray,
    "id",
    "size",
    "label",
    "batcher",
    "hash",
    "timestamp"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "size" = EXCLUDED."size",
  "label" = EXCLUDED."label",
  "batcher" = EXCLUDED."batcher",
  "hash" = EXCLUDED."hash",
  "timestamp" = EXCLUDED."timestamp"
  `;
}

module.exports.batchSetBatch = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetBatchCore
  );
}

module.exports.batchDeleteBatch = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Batch"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Batch

//////////////////////////////////////////////
// DB operations for Batcher:
//////////////////////////////////////////////

module.exports.readBatcherEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"address",
"batchIndex"
FROM "public"."Batcher"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetBatcherCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Batcher"
${sql(entityDataArray,
    "id",
    "address",
    "batchIndex"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "address" = EXCLUDED."address",
  "batchIndex" = EXCLUDED."batchIndex"
  `;
}

module.exports.batchSetBatcher = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetBatcherCore
  );
}

module.exports.batchDeleteBatcher = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Batcher"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Batcher

//////////////////////////////////////////////
// DB operations for Contract:
//////////////////////////////////////////////

module.exports.readContractEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"address",
"admin",
"alias",
"chainId",
"category",
"version"
FROM "public"."Contract"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetContractCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Contract"
${sql(entityDataArray,
    "id",
    "address",
    "admin",
    "alias",
    "chainId",
    "category",
    "version"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "address" = EXCLUDED."address",
  "admin" = EXCLUDED."admin",
  "alias" = EXCLUDED."alias",
  "chainId" = EXCLUDED."chainId",
  "category" = EXCLUDED."category",
  "version" = EXCLUDED."version"
  `;
}

module.exports.batchSetContract = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetContractCore
  );
}

module.exports.batchDeleteContract = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Contract"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Contract

//////////////////////////////////////////////
// DB operations for Segment:
//////////////////////////////////////////////

module.exports.readSegmentEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"position",
"stream",
"amount",
"exponent",
"milestone",
"endTime",
"startTime",
"startAmount",
"endAmount"
FROM "public"."Segment"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetSegmentCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Segment"
${sql(entityDataArray,
    "id",
    "position",
    "stream",
    "amount",
    "exponent",
    "milestone",
    "endTime",
    "startTime",
    "startAmount",
    "endAmount"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "position" = EXCLUDED."position",
  "stream" = EXCLUDED."stream",
  "amount" = EXCLUDED."amount",
  "exponent" = EXCLUDED."exponent",
  "milestone" = EXCLUDED."milestone",
  "endTime" = EXCLUDED."endTime",
  "startTime" = EXCLUDED."startTime",
  "startAmount" = EXCLUDED."startAmount",
  "endAmount" = EXCLUDED."endAmount"
  `;
}

module.exports.batchSetSegment = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetSegmentCore
  );
}

module.exports.batchDeleteSegment = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Segment"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Segment

//////////////////////////////////////////////
// DB operations for Stream:
//////////////////////////////////////////////

module.exports.readStreamEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"alias",
"subgraphId",
"tokenId",
"version",
"asset",
"category",
"chainId",
"contract",
"hash",
"timestamp",
"funder",
"sender",
"recipient",
"parties",
"proxender",
"proxied",
"cliff",
"cancelable",
"canceled",
"transferable",
"canceledAction",
"renounceAction",
"renounceTime",
"canceledTime",
"cliffTime",
"endTime",
"startTime",
"duration",
"brokerFeeAmount",
"cliffAmount",
"depositAmount",
"intactAmount",
"protocolFeeAmount",
"withdrawnAmount",
"batch",
"position"
FROM "public"."Stream"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetStreamCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Stream"
${sql(entityDataArray,
    "id",
    "alias",
    "subgraphId",
    "tokenId",
    "version",
    "asset",
    "category",
    "chainId",
    "contract",
    "hash",
    "timestamp",
    "funder",
    "sender",
    "recipient",
    "parties",
    "proxender",
    "proxied",
    "cliff",
    "cancelable",
    "canceled",
    "transferable",
    "canceledAction",
    "renounceAction",
    "renounceTime",
    "canceledTime",
    "cliffTime",
    "endTime",
    "startTime",
    "duration",
    "brokerFeeAmount",
    "cliffAmount",
    "depositAmount",
    "intactAmount",
    "protocolFeeAmount",
    "withdrawnAmount",
    "batch",
    "position"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "alias" = EXCLUDED."alias",
  "subgraphId" = EXCLUDED."subgraphId",
  "tokenId" = EXCLUDED."tokenId",
  "version" = EXCLUDED."version",
  "asset" = EXCLUDED."asset",
  "category" = EXCLUDED."category",
  "chainId" = EXCLUDED."chainId",
  "contract" = EXCLUDED."contract",
  "hash" = EXCLUDED."hash",
  "timestamp" = EXCLUDED."timestamp",
  "funder" = EXCLUDED."funder",
  "sender" = EXCLUDED."sender",
  "recipient" = EXCLUDED."recipient",
  "parties" = EXCLUDED."parties",
  "proxender" = EXCLUDED."proxender",
  "proxied" = EXCLUDED."proxied",
  "cliff" = EXCLUDED."cliff",
  "cancelable" = EXCLUDED."cancelable",
  "canceled" = EXCLUDED."canceled",
  "transferable" = EXCLUDED."transferable",
  "canceledAction" = EXCLUDED."canceledAction",
  "renounceAction" = EXCLUDED."renounceAction",
  "renounceTime" = EXCLUDED."renounceTime",
  "canceledTime" = EXCLUDED."canceledTime",
  "cliffTime" = EXCLUDED."cliffTime",
  "endTime" = EXCLUDED."endTime",
  "startTime" = EXCLUDED."startTime",
  "duration" = EXCLUDED."duration",
  "brokerFeeAmount" = EXCLUDED."brokerFeeAmount",
  "cliffAmount" = EXCLUDED."cliffAmount",
  "depositAmount" = EXCLUDED."depositAmount",
  "intactAmount" = EXCLUDED."intactAmount",
  "protocolFeeAmount" = EXCLUDED."protocolFeeAmount",
  "withdrawnAmount" = EXCLUDED."withdrawnAmount",
  "batch" = EXCLUDED."batch",
  "position" = EXCLUDED."position"
  `;
}

module.exports.batchSetStream = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetStreamCore
  );
}

module.exports.batchDeleteStream = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Stream"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Stream

//////////////////////////////////////////////
// DB operations for Watcher:
//////////////////////////////////////////////

module.exports.readWatcherEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"chainId",
"streamIndex",
"actionIndex",
"initialized",
"logs"
FROM "public"."Watcher"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetWatcherCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Watcher"
${sql(entityDataArray,
    "id",
    "chainId",
    "streamIndex",
    "actionIndex",
    "initialized",
    "logs"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "chainId" = EXCLUDED."chainId",
  "streamIndex" = EXCLUDED."streamIndex",
  "actionIndex" = EXCLUDED."actionIndex",
  "initialized" = EXCLUDED."initialized",
  "logs" = EXCLUDED."logs"
  `;
}

module.exports.batchSetWatcher = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetWatcherCore
  );
}

module.exports.batchDeleteWatcher = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Watcher"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Watcher

