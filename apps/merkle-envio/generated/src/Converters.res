exception UndefinedEvent(string)

let eventStringToEvent = (eventName: string, contractName: string): Types.eventName => {
  switch (eventName, contractName) {
  | ("Claim", "MerkleLLV21") => MerkleLLV21_Claim
  | ("Clawback", "MerkleLLV21") => MerkleLLV21_Clawback
  | ("TransferAdmin", "MerkleLLV21") => MerkleLLV21_TransferAdmin
  | ("CreateMerkleStreamerLL", "MerkleLockupFactoryV21") =>
    MerkleLockupFactoryV21_CreateMerkleStreamerLL
  | _ => UndefinedEvent(eventName)->raise
  }
}

module MerkleLLV21 = {
  let convertClaimViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.MerkleLLV21Contract.ClaimEvent.eventArgs,
  > = Obj.magic

  let convertClaimLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.MerkleLLV21Contract.ClaimEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.MerkleLLV21Contract.ClaimEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        index: args.index,
        recipient: args.recipient,
        amount: args.amount,
        streamId: args.streamId,
      },
    }
  }

  let convertClaimLog = (
    logDescription: Ethers.logDescription<Types.MerkleLLV21Contract.ClaimEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLLV21Contract.ClaimEvent.eventArgs = {
      index: logDescription.args.index,
      recipient: logDescription.args.recipient,
      amount: logDescription.args.amount,
      streamId: logDescription.args.streamId,
    }

    let claimLog: Types.eventLog<Types.MerkleLLV21Contract.ClaimEvent.eventArgs> = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLLV21Contract_Claim(claimLog)
  }
  let convertClaimLogViem = (
    decodedEvent: Viem.decodedEvent<Types.MerkleLLV21Contract.ClaimEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLLV21Contract.ClaimEvent.eventArgs = {
      index: decodedEvent.args.index,
      recipient: decodedEvent.args.recipient,
      amount: decodedEvent.args.amount,
      streamId: decodedEvent.args.streamId,
    }

    let claimLog: Types.eventLog<Types.MerkleLLV21Contract.ClaimEvent.eventArgs> = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLLV21Contract_Claim(claimLog)
  }

  let convertClawbackViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.MerkleLLV21Contract.ClawbackEvent.eventArgs,
  > = Obj.magic

  let convertClawbackLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.MerkleLLV21Contract.ClawbackEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.MerkleLLV21Contract.ClawbackEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        admin: args.admin,
        to: args.to,
        amount: args.amount,
      },
    }
  }

  let convertClawbackLog = (
    logDescription: Ethers.logDescription<Types.MerkleLLV21Contract.ClawbackEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLLV21Contract.ClawbackEvent.eventArgs = {
      admin: logDescription.args.admin,
      to: logDescription.args.to,
      amount: logDescription.args.amount,
    }

    let clawbackLog: Types.eventLog<Types.MerkleLLV21Contract.ClawbackEvent.eventArgs> = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLLV21Contract_Clawback(clawbackLog)
  }
  let convertClawbackLogViem = (
    decodedEvent: Viem.decodedEvent<Types.MerkleLLV21Contract.ClawbackEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLLV21Contract.ClawbackEvent.eventArgs = {
      admin: decodedEvent.args.admin,
      to: decodedEvent.args.to,
      amount: decodedEvent.args.amount,
    }

    let clawbackLog: Types.eventLog<Types.MerkleLLV21Contract.ClawbackEvent.eventArgs> = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLLV21Contract_Clawback(clawbackLog)
  }

  let convertTransferAdminViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs,
  > = Obj.magic

  let convertTransferAdminLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.MerkleLLV21Contract.TransferAdminEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        oldAdmin: args.oldAdmin,
        newAdmin: args.newAdmin,
      },
    }
  }

  let convertTransferAdminLog = (
    logDescription: Ethers.logDescription<Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs = {
      oldAdmin: logDescription.args.oldAdmin,
      newAdmin: logDescription.args.newAdmin,
    }

    let transferAdminLog: Types.eventLog<Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs> = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLLV21Contract_TransferAdmin(transferAdminLog)
  }
  let convertTransferAdminLogViem = (
    decodedEvent: Viem.decodedEvent<Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs = {
      oldAdmin: decodedEvent.args.oldAdmin,
      newAdmin: decodedEvent.args.newAdmin,
    }

    let transferAdminLog: Types.eventLog<Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs> = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLLV21Contract_TransferAdmin(transferAdminLog)
  }
}

module MerkleLockupFactoryV21 = {
  let convertCreateMerkleStreamerLLViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs,
  > = Obj.magic

  let convertCreateMerkleStreamerLLLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<
    Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        merkleStreamer: args.merkleStreamer,
        admin: args.admin,
        lockupLinear: args.lockupLinear,
        asset: args.asset,
        merkleRoot: args.merkleRoot,
        expiration: args.expiration,
        streamDurations: args.streamDurations,
        cancelable: args.cancelable,
        transferable: args.transferable,
        ipfsCID: args.ipfsCID,
        aggregateAmount: args.aggregateAmount,
        recipientsCount: args.recipientsCount,
      },
    }
  }

  let convertCreateMerkleStreamerLLLog = (
    logDescription: Ethers.logDescription<
      Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs = {
      merkleStreamer: logDescription.args.merkleStreamer,
      admin: logDescription.args.admin,
      lockupLinear: logDescription.args.lockupLinear,
      asset: logDescription.args.asset,
      merkleRoot: logDescription.args.merkleRoot,
      expiration: logDescription.args.expiration,
      streamDurations: logDescription.args.streamDurations,
      cancelable: logDescription.args.cancelable,
      transferable: logDescription.args.transferable,
      ipfsCID: logDescription.args.ipfsCID,
      aggregateAmount: logDescription.args.aggregateAmount,
      recipientsCount: logDescription.args.recipientsCount,
    }

    let createMerkleStreamerLLLog: Types.eventLog<
      Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs,
    > = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL(createMerkleStreamerLLLog)
  }
  let convertCreateMerkleStreamerLLLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs = {
      merkleStreamer: decodedEvent.args.merkleStreamer,
      admin: decodedEvent.args.admin,
      lockupLinear: decodedEvent.args.lockupLinear,
      asset: decodedEvent.args.asset,
      merkleRoot: decodedEvent.args.merkleRoot,
      expiration: decodedEvent.args.expiration,
      streamDurations: decodedEvent.args.streamDurations,
      cancelable: decodedEvent.args.cancelable,
      transferable: decodedEvent.args.transferable,
      ipfsCID: decodedEvent.args.ipfsCID,
      aggregateAmount: decodedEvent.args.aggregateAmount,
      recipientsCount: decodedEvent.args.recipientsCount,
    }

    let createMerkleStreamerLLLog: Types.eventLog<
      Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs,
    > = {
      params,
      chainId,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.MerkleLockupFactoryV21Contract_CreateMerkleStreamerLL(createMerkleStreamerLLLog)
  }
}

type parseEventError =
  ParseError(Ethers.Interface.parseLogError) | UnregisteredContract(Ethers.ethAddress)

exception ParseEventErrorExn(parseEventError)

let parseEventEthers = (~log, ~blockTimestamp, ~contractInterfaceManager, ~chainId): Belt.Result.t<
  Types.event,
  _,
> => {
  let logDescriptionResult = contractInterfaceManager->ContractInterfaceManager.parseLogEthers(~log)
  switch logDescriptionResult {
  | Error(e) =>
    switch e {
    | ParseError(parseError) => ParseError(parseError)
    | UndefinedInterface(contractAddress) => UnregisteredContract(contractAddress)
    }->Error

  | Ok(logDescription) =>
    switch contractInterfaceManager->ContractInterfaceManager.getContractNameFromAddress(
      ~contractAddress=log.address,
    ) {
    | None => Error(UnregisteredContract(log.address))
    | Some(contractName) =>
      let event = switch eventStringToEvent(logDescription.name, contractName) {
      | MerkleLLV21_Claim =>
        logDescription
        ->MerkleLLV21.convertClaimLogDescription
        ->MerkleLLV21.convertClaimLog(~log, ~blockTimestamp, ~chainId)
      | MerkleLLV21_Clawback =>
        logDescription
        ->MerkleLLV21.convertClawbackLogDescription
        ->MerkleLLV21.convertClawbackLog(~log, ~blockTimestamp, ~chainId)
      | MerkleLLV21_TransferAdmin =>
        logDescription
        ->MerkleLLV21.convertTransferAdminLogDescription
        ->MerkleLLV21.convertTransferAdminLog(~log, ~blockTimestamp, ~chainId)
      | MerkleLockupFactoryV21_CreateMerkleStreamerLL =>
        logDescription
        ->MerkleLockupFactoryV21.convertCreateMerkleStreamerLLLogDescription
        ->MerkleLockupFactoryV21.convertCreateMerkleStreamerLLLog(~log, ~blockTimestamp, ~chainId)
      }

      Ok(event)
    }
  }
}

let parseEvent = (~log, ~blockTimestamp, ~contractInterfaceManager, ~chainId): Belt.Result.t<
  Types.event,
  _,
> => {
  let decodedEventResult = contractInterfaceManager->ContractInterfaceManager.parseLogViem(~log)
  switch decodedEventResult {
  | Error(e) =>
    switch e {
    | ParseError(parseError) => ParseError(parseError)
    | UndefinedInterface(contractAddress) => UnregisteredContract(contractAddress)
    }->Error

  | Ok(decodedEvent) =>
    switch contractInterfaceManager->ContractInterfaceManager.getContractNameFromAddress(
      ~contractAddress=log.address,
    ) {
    | None => Error(UnregisteredContract(log.address))
    | Some(contractName) =>
      let event = switch eventStringToEvent(decodedEvent.eventName, contractName) {
      | MerkleLLV21_Claim =>
        decodedEvent
        ->MerkleLLV21.convertClaimViemDecodedEvent
        ->MerkleLLV21.convertClaimLogViem(~log, ~blockTimestamp, ~chainId)
      | MerkleLLV21_Clawback =>
        decodedEvent
        ->MerkleLLV21.convertClawbackViemDecodedEvent
        ->MerkleLLV21.convertClawbackLogViem(~log, ~blockTimestamp, ~chainId)
      | MerkleLLV21_TransferAdmin =>
        decodedEvent
        ->MerkleLLV21.convertTransferAdminViemDecodedEvent
        ->MerkleLLV21.convertTransferAdminLogViem(~log, ~blockTimestamp, ~chainId)
      | MerkleLockupFactoryV21_CreateMerkleStreamerLL =>
        decodedEvent
        ->MerkleLockupFactoryV21.convertCreateMerkleStreamerLLViemDecodedEvent
        ->MerkleLockupFactoryV21.convertCreateMerkleStreamerLLLogViem(
          ~log,
          ~blockTimestamp,
          ~chainId,
        )
      }

      Ok(event)
    }
  }
}

let decodeRawEventWith = (
  rawEvent: Types.rawEventsEntity,
  ~decoder: Spice.decoder<'a>,
  ~variantAccessor: Types.eventLog<'a> => Types.event,
  ~chainId: int,
): Spice.result<Types.eventBatchQueueItem> => {
  switch rawEvent.params->Js.Json.parseExn {
  | exception exn =>
    let message =
      exn
      ->Js.Exn.asJsExn
      ->Belt.Option.flatMap(jsexn => jsexn->Js.Exn.message)
      ->Belt.Option.getWithDefault("No message on exn")

    Spice.error(`Failed at JSON.parse. Error: ${message}`, rawEvent.params->Obj.magic)
  | v => Ok(v)
  }
  ->Belt.Result.flatMap(json => {
    json->decoder
  })
  ->Belt.Result.map(params => {
    let event = {
      chainId,
      blockNumber: rawEvent.blockNumber,
      blockTimestamp: rawEvent.blockTimestamp,
      blockHash: rawEvent.blockHash,
      srcAddress: rawEvent.srcAddress,
      transactionHash: rawEvent.transactionHash,
      transactionIndex: rawEvent.transactionIndex,
      logIndex: rawEvent.logIndex,
      params,
    }->variantAccessor

    let queueItem: Types.eventBatchQueueItem = {
      timestamp: rawEvent.blockTimestamp,
      chainId: rawEvent.chainId,
      blockNumber: rawEvent.blockNumber,
      logIndex: rawEvent.logIndex,
      event,
    }

    queueItem
  })
}

let parseRawEvent = (rawEvent: Types.rawEventsEntity, ~chainId: int): Spice.result<
  Types.eventBatchQueueItem,
> => {
  rawEvent.eventType
  ->Types.eventName_decode
  ->Belt.Result.flatMap(eventName => {
    switch eventName {
    | MerkleLLV21_Claim =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.MerkleLLV21Contract.ClaimEvent.eventArgs_decode,
        ~variantAccessor=Types.merkleLLV21Contract_Claim,
        ~chainId,
      )
    | MerkleLLV21_Clawback =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.MerkleLLV21Contract.ClawbackEvent.eventArgs_decode,
        ~variantAccessor=Types.merkleLLV21Contract_Clawback,
        ~chainId,
      )
    | MerkleLLV21_TransferAdmin =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.MerkleLLV21Contract.TransferAdminEvent.eventArgs_decode,
        ~variantAccessor=Types.merkleLLV21Contract_TransferAdmin,
        ~chainId,
      )
    | MerkleLockupFactoryV21_CreateMerkleStreamerLL =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.MerkleLockupFactoryV21Contract.CreateMerkleStreamerLLEvent.eventArgs_decode,
        ~variantAccessor=Types.merkleLockupFactoryV21Contract_CreateMerkleStreamerLL,
        ~chainId,
      )
    }
  })
}
