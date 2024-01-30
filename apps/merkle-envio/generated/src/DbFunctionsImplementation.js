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
"block",
"category",
"chainId",
"campaign",
"hash",
"from",
"subgraphId",
"timestamp",
"claimStreamId",
"claimTokenId",
"claimAmount",
"claimIndex",
"claimRecipient",
"clawbackAmount",
"clawbackFrom",
"clawbackTo"
FROM "public"."Action"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetActionCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Action"
${sql(entityDataArray,
    "id",
    "block",
    "category",
    "chainId",
    "campaign",
    "hash",
    "from",
    "subgraphId",
    "timestamp",
    "claimStreamId",
    "claimTokenId",
    "claimAmount",
    "claimIndex",
    "claimRecipient",
    "clawbackAmount",
    "clawbackFrom",
    "clawbackTo"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "block" = EXCLUDED."block",
  "category" = EXCLUDED."category",
  "chainId" = EXCLUDED."chainId",
  "campaign" = EXCLUDED."campaign",
  "hash" = EXCLUDED."hash",
  "from" = EXCLUDED."from",
  "subgraphId" = EXCLUDED."subgraphId",
  "timestamp" = EXCLUDED."timestamp",
  "claimStreamId" = EXCLUDED."claimStreamId",
  "claimTokenId" = EXCLUDED."claimTokenId",
  "claimAmount" = EXCLUDED."claimAmount",
  "claimIndex" = EXCLUDED."claimIndex",
  "claimRecipient" = EXCLUDED."claimRecipient",
  "clawbackAmount" = EXCLUDED."clawbackAmount",
  "clawbackFrom" = EXCLUDED."clawbackFrom",
  "clawbackTo" = EXCLUDED."clawbackTo"
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
// DB operations for Activity:
//////////////////////////////////////////////

module.exports.readActivityEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"campaign",
"timestamp",
"day",
"amount",
"claims"
FROM "public"."Activity"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetActivityCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Activity"
${sql(entityDataArray,
    "id",
    "campaign",
    "timestamp",
    "day",
    "amount",
    "claims"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "campaign" = EXCLUDED."campaign",
  "timestamp" = EXCLUDED."timestamp",
  "day" = EXCLUDED."day",
  "amount" = EXCLUDED."amount",
  "claims" = EXCLUDED."claims"
  `;
}

module.exports.batchSetActivity = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetActivityCore
  );
}

module.exports.batchDeleteActivity = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Activity"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Activity

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
// DB operations for Campaign:
//////////////////////////////////////////////

module.exports.readCampaignEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"subgraphId",
"address",
"asset",
"factory",
"chainId",
"hash",
"timestamp",
"category",
"admin",
"lockup",
"root",
"expires",
"expiration",
"ipfsCID",
"aggregateAmount",
"totalRecipients",
"clawbackAction",
"clawbackTime",
"streamCliff",
"streamCliffDuration",
"streamTotalDuration",
"streamCancelable",
"streamTransferable",
"claimedAmount",
"claimedCount",
"version"
FROM "public"."Campaign"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetCampaignCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Campaign"
${sql(entityDataArray,
    "id",
    "subgraphId",
    "address",
    "asset",
    "factory",
    "chainId",
    "hash",
    "timestamp",
    "category",
    "admin",
    "lockup",
    "root",
    "expires",
    "expiration",
    "ipfsCID",
    "aggregateAmount",
    "totalRecipients",
    "clawbackAction",
    "clawbackTime",
    "streamCliff",
    "streamCliffDuration",
    "streamTotalDuration",
    "streamCancelable",
    "streamTransferable",
    "claimedAmount",
    "claimedCount",
    "version"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "subgraphId" = EXCLUDED."subgraphId",
  "address" = EXCLUDED."address",
  "asset" = EXCLUDED."asset",
  "factory" = EXCLUDED."factory",
  "chainId" = EXCLUDED."chainId",
  "hash" = EXCLUDED."hash",
  "timestamp" = EXCLUDED."timestamp",
  "category" = EXCLUDED."category",
  "admin" = EXCLUDED."admin",
  "lockup" = EXCLUDED."lockup",
  "root" = EXCLUDED."root",
  "expires" = EXCLUDED."expires",
  "expiration" = EXCLUDED."expiration",
  "ipfsCID" = EXCLUDED."ipfsCID",
  "aggregateAmount" = EXCLUDED."aggregateAmount",
  "totalRecipients" = EXCLUDED."totalRecipients",
  "clawbackAction" = EXCLUDED."clawbackAction",
  "clawbackTime" = EXCLUDED."clawbackTime",
  "streamCliff" = EXCLUDED."streamCliff",
  "streamCliffDuration" = EXCLUDED."streamCliffDuration",
  "streamTotalDuration" = EXCLUDED."streamTotalDuration",
  "streamCancelable" = EXCLUDED."streamCancelable",
  "streamTransferable" = EXCLUDED."streamTransferable",
  "claimedAmount" = EXCLUDED."claimedAmount",
  "claimedCount" = EXCLUDED."claimedCount",
  "version" = EXCLUDED."version"
  `;
}

module.exports.batchSetCampaign = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetCampaignCore
  );
}

module.exports.batchDeleteCampaign = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Campaign"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Campaign

//////////////////////////////////////////////
// DB operations for Factory:
//////////////////////////////////////////////

module.exports.readFactoryEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"alias",
"address",
"chainId",
"version"
FROM "public"."Factory"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetFactoryCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Factory"
${sql(entityDataArray,
    "id",
    "alias",
    "address",
    "chainId",
    "version"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "alias" = EXCLUDED."alias",
  "address" = EXCLUDED."address",
  "chainId" = EXCLUDED."chainId",
  "version" = EXCLUDED."version"
  `;
}

module.exports.batchSetFactory = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetFactoryCore
  );
}

module.exports.batchDeleteFactory = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Factory"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Factory

//////////////////////////////////////////////
// DB operations for Watcher:
//////////////////////////////////////////////

module.exports.readWatcherEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"chainId",
"actionIndex",
"campaignIndex",
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
    "actionIndex",
    "campaignIndex",
    "initialized",
    "logs"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "chainId" = EXCLUDED."chainId",
  "actionIndex" = EXCLUDED."actionIndex",
  "campaignIndex" = EXCLUDED."campaignIndex",
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

