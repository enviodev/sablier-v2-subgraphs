let sql = Postgres.makeSql(~config=Config.db->Obj.magic /* TODO: make this have the correct type */)

module EventSyncState = {
  let createEventSyncStateTable: unit => promise<unit> = async () => {
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.event_sync_state (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        transaction_index INTEGER NOT NULL,
        block_timestamp INTEGER NOT NULL,
        PRIMARY KEY (chain_id)
      );
      `")
  }

  let dropEventSyncStateTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.event_sync_state;
    `")
  }
}

module ChainMetadata = {
  let createChainMetadataTable: unit => promise<unit> = async () => {
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.chain_metadata (
        chain_id INTEGER NOT NULL,
        start_block INTEGER NOT NULL,
        block_height INTEGER NOT NULL,
        PRIMARY KEY (chain_id)
      );
      `")
  }

  let dropChainMetadataTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.chain_metadata;
    `")
  }
}

module PersistedState = {
  let createPersistedStateTable: unit => promise<unit> = async () => {
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.persisted_state (
        id SERIAL PRIMARY KEY,
        envio_version TEXT NOT NULL, 
        config_hash TEXT NOT NULL,
        schema_hash TEXT NOT NULL,
        handler_files_hash TEXT NOT NULL,
        abi_files_hash TEXT NOT NULL
      );
      `")
  }

  let dropPersistedStateTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.persisted_state;
    `")
  }
}

module RawEventsTable = {
  let createEventTypeEnum: unit => promise<unit> = async () => {
    @warning("-21")
    let _ = await %raw("sql`
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'event_type') THEN
          CREATE TYPE EVENT_TYPE AS ENUM(
          'LockupV20_Approval',
          'LockupV20_ApprovalForAll',
          'LockupV20_CancelLockupStream',
          'LockupV20_CreateLockupLinearStream',
          'LockupV20_CreateLockupDynamicStream',
          'LockupV20_RenounceLockupStream',
          'LockupV20_Transfer',
          'LockupV20_TransferAdmin',
          'LockupV20_WithdrawFromLockupStream',
          'LockupV21_Approval',
          'LockupV21_ApprovalForAll',
          'LockupV21_CancelLockupStream',
          'LockupV21_CreateLockupLinearStream',
          'LockupV21_CreateLockupDynamicStream',
          'LockupV21_RenounceLockupStream',
          'LockupV21_Transfer',
          'LockupV21_TransferAdmin',
          'LockupV21_WithdrawFromLockupStream'
          );
        END IF;
      END $$;
      `")
  }

  let createRawEventsTable: unit => promise<unit> = async () => {
    let _ = await createEventTypeEnum()

    @warning("-21")
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.raw_events (
        chain_id INTEGER NOT NULL,
        event_id NUMERIC NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        transaction_index INTEGER NOT NULL,
        transaction_hash TEXT NOT NULL,
        src_address TEXT NOT NULL,
        block_hash TEXT NOT NULL,
        block_timestamp INTEGER NOT NULL,
        event_type EVENT_TYPE NOT NULL,
        params JSON NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (chain_id, event_id)
      );
      `")
  }

  @@warning("-21")
  let dropRawEventsTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.raw_events;
    `")
    let _ = await %raw("sql`
      DROP TYPE IF EXISTS EVENT_TYPE CASCADE;
    `")
  }
  @@warning("+21")
}

module DynamicContractRegistryTable = {
  let createDynamicContractRegistryTable: unit => promise<unit> = async () => {
    @warning("-21")
    let _ = await %raw("sql`
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contract_type') THEN
          CREATE TYPE CONTRACT_TYPE AS ENUM (
          'LockupV20',
          'LockupV21'
          );
        END IF;
      END $$;
      `")

    @warning("-21")
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.dynamic_contract_registry (
        chain_id INTEGER NOT NULL,
        event_id NUMERIC NOT NULL,
        contract_address TEXT NOT NULL,
        contract_type CONTRACT_TYPE NOT NULL,
        PRIMARY KEY (chain_id, contract_address)
      );
      `")
  }

  @@warning("-21")
  let dropDynamicContractRegistryTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.dynamic_contract_registry;
    `")
    let _ = await %raw("sql`
      DROP TYPE IF EXISTS EVENT_TYPE CASCADE;
    `")
  }
  @@warning("+21")
}

module Action = {
  let createActionTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Action\" (\"id\" text NOT NULL,\"addressA\" text,\"addressB\" text,\"amountA\" numeric,\"amountB\" numeric,\"block\" numeric NOT NULL,\"category\" text NOT NULL,\"chainId\" numeric NOT NULL,\"contract\" text NOT NULL,\"hash\" text NOT NULL,\"from\" text NOT NULL,\"stream\" text,\"subgraphId\" numeric NOT NULL,\"timestamp\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteActionTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Action\";`")
  }
}

module Asset = {
  let createAssetTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Asset\" (\"id\" text NOT NULL,\"address\" text NOT NULL,\"chainId\" numeric NOT NULL,\"decimals\" numeric NOT NULL,\"name\" text NOT NULL,\"symbol\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteAssetTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Asset\";`")
  }
}

module Batch = {
  let createBatchTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Batch\" (\"id\" text NOT NULL,\"size\" numeric NOT NULL,\"label\" text,\"batcher\" text,\"hash\" text NOT NULL,\"timestamp\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteBatchTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Batch\";`")
  }
}

module Batcher = {
  let createBatcherTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Batcher\" (\"id\" text NOT NULL,\"address\" text NOT NULL,\"batchIndex\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteBatcherTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Batcher\";`")
  }
}

module Contract = {
  let createContractTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Contract\" (\"id\" text NOT NULL,\"address\" text NOT NULL,\"admin\" text,\"alias\" text NOT NULL,\"chainId\" numeric NOT NULL,\"category\" text NOT NULL,\"version\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteContractTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Contract\";`")
  }
}

module Segment = {
  let createSegmentTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Segment\" (\"id\" text NOT NULL,\"position\" numeric NOT NULL,\"stream\" text NOT NULL,\"amount\" numeric NOT NULL,\"exponent\" numeric NOT NULL,\"milestone\" numeric NOT NULL,\"endTime\" numeric NOT NULL,\"startTime\" numeric NOT NULL,\"startAmount\" numeric NOT NULL,\"endAmount\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteSegmentTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Segment\";`")
  }
}

module Stream = {
  let createStreamTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Stream\" (\"id\" text NOT NULL,\"alias\" text NOT NULL,\"subgraphId\" numeric NOT NULL,\"tokenId\" numeric NOT NULL,\"version\" text NOT NULL,\"asset\" text NOT NULL,\"category\" text NOT NULL,\"chainId\" numeric NOT NULL,\"contract\" text NOT NULL,\"hash\" text NOT NULL,\"timestamp\" numeric NOT NULL,\"funder\" text NOT NULL,\"sender\" text NOT NULL,\"recipient\" text NOT NULL,\"parties\" text[] NOT NULL,\"proxender\" text,\"proxied\" boolean NOT NULL,\"cliff\" boolean NOT NULL,\"cancelable\" boolean NOT NULL,\"canceled\" boolean NOT NULL,\"transferable\" boolean NOT NULL,\"canceledAction\" text,\"renounceAction\" text,\"renounceTime\" numeric,\"canceledTime\" numeric,\"cliffTime\" numeric,\"endTime\" numeric NOT NULL,\"startTime\" numeric NOT NULL,\"duration\" numeric NOT NULL,\"brokerFeeAmount\" numeric NOT NULL,\"cliffAmount\" numeric,\"depositAmount\" numeric NOT NULL,\"intactAmount\" numeric NOT NULL,\"protocolFeeAmount\" numeric NOT NULL,\"withdrawnAmount\" numeric NOT NULL,\"batch\" text NOT NULL,\"position\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteStreamTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Stream\";`")
  }
}

module Watcher = {
  let createWatcherTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Watcher\" (\"id\" text NOT NULL,\"chainId\" numeric NOT NULL,\"streamIndex\" numeric NOT NULL,\"actionIndex\" numeric NOT NULL,\"initialized\" boolean NOT NULL,\"logs\" text[] NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let deleteWatcherTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Watcher\";`")
  }
}

let deleteAllTables: unit => promise<unit> = async () => {
  Logging.trace("Dropping all tables")
  // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).

  @warning("-21")
  await (
    %raw(
      "sql.unsafe`DROP SCHEMA public CASCADE;CREATE SCHEMA public;GRANT ALL ON SCHEMA public TO postgres;GRANT ALL ON SCHEMA public TO public;`"
    )
  )
}

let deleteAllTablesExceptRawEventsAndDynamicContractRegistry: unit => promise<unit> = async () => {
  // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).

  @warning("-21")
  await (
    %raw("sql.unsafe`
    DO $$ 
    DECLARE
        table_name_var text;
    BEGIN
        FOR table_name_var IN (SELECT table_name
                           FROM information_schema.tables
                           WHERE table_schema = 'public'
                           AND table_name != 'raw_events'
                           AND table_name != 'dynamic_contract_registry') 
        LOOP
            EXECUTE 'DROP TABLE IF EXISTS ' || table_name_var || ' CASCADE';
        END LOOP;
    END $$;
  `")
  )
}

type t
@module external process: t = "process"

type exitCode = Success | Failure
@send external exit: (t, exitCode) => unit = "exit"

// TODO: all the migration steps should run as a single transaction
let runUpMigrations = async (~shouldExit) => {
  let exitCode = ref(Success)
  await PersistedState.createPersistedStateTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating persisted_state table`)->Promise.resolve
  })

  await EventSyncState.createEventSyncStateTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating event_sync_state table`)->Promise.resolve
  })
  await ChainMetadata.createChainMetadataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating chain_metadata table`)->Promise.resolve
  })
  await RawEventsTable.createRawEventsTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating raw_events table`)->Promise.resolve
  })
  await DynamicContractRegistryTable.createDynamicContractRegistryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE801: Error creating dynamic_contracts table`)->Promise.resolve
  })
  // TODO: catch and handle query errors
  await Action.createActionTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Action table`)->Promise.resolve
  })
  await Asset.createAssetTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Asset table`)->Promise.resolve
  })
  await Batch.createBatchTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Batch table`)->Promise.resolve
  })
  await Batcher.createBatcherTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Batcher table`)->Promise.resolve
  })
  await Contract.createContractTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Contract table`)->Promise.resolve
  })
  await Segment.createSegmentTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Segment table`)->Promise.resolve
  })
  await Stream.createStreamTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Stream table`)->Promise.resolve
  })
  await Watcher.createWatcherTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Watcher table`)->Promise.resolve
  })
  await TrackTables.trackAllTables()->Promise.catch(err => {
    Logging.errorWithExn(err, `EE803: Error tracking tables`)->Promise.resolve
  })
  if shouldExit {
    process->exit(exitCode.contents)
  }
  exitCode.contents
}

let runDownMigrations = async (~shouldExit, ~shouldDropRawEvents) => {
  let exitCode = ref(Success)

  //
  // await Action.deleteActionTable()
  //
  // await Asset.deleteAssetTable()
  //
  // await Batch.deleteBatchTable()
  //
  // await Batcher.deleteBatcherTable()
  //
  // await Contract.deleteContractTable()
  //
  // await Segment.deleteSegmentTable()
  //
  // await Stream.deleteStreamTable()
  //
  // await Watcher.deleteWatcherTable()
  //

  // NOTE: For now delete any remaining tables.
  if shouldDropRawEvents {
    await deleteAllTables()->Promise.catch(err => {
      exitCode := Failure
      Logging.errorWithExn(err, "EE804: Error dropping entity tables")->Promise.resolve
    })
  } else {
    await deleteAllTablesExceptRawEventsAndDynamicContractRegistry()->Promise.catch(err => {
      exitCode := Failure
      Logging.errorWithExn(
        err,
        "EE805: Error dropping entity tables except for raw events",
      )->Promise.resolve
    })
  }
  if shouldExit {
    process->exit(exitCode.contents)
  }
  exitCode.contents
}

let setupDb = async (~shouldDropRawEvents) => {
  Logging.info("Provisioning Database")
  // TODO: we should make a hash of the schema file (that gets stored in the DB) and either drop the tables and create new ones or keep this migration.
  //       for now we always run the down migration.
  // if (process.env.MIGRATE === "force" || hash_of_schema_file !== hash_of_current_schema)
  let exitCodeDown = await runDownMigrations(~shouldExit=false, ~shouldDropRawEvents)
  // else
  //   await clearDb()

  let exitCodeUp = await runUpMigrations(~shouldExit=false)

  let exitCode = switch (exitCodeDown, exitCodeUp) {
  | (Success, Success) => Success
  | _ => Failure
  }

  process->exit(exitCode)
}
