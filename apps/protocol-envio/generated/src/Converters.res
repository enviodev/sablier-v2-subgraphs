exception UndefinedEvent(string)

let eventStringToEvent = (eventName: string, contractName: string): Types.eventName => {
  switch (eventName, contractName) {
  | ("Approval", "LockupV20") => LockupV20_Approval
  | ("ApprovalForAll", "LockupV20") => LockupV20_ApprovalForAll
  | ("CancelLockupStream", "LockupV20") => LockupV20_CancelLockupStream
  | ("CreateLockupLinearStream", "LockupV20") => LockupV20_CreateLockupLinearStream
  | ("CreateLockupDynamicStream", "LockupV20") => LockupV20_CreateLockupDynamicStream
  | ("RenounceLockupStream", "LockupV20") => LockupV20_RenounceLockupStream
  | ("Transfer", "LockupV20") => LockupV20_Transfer
  | ("TransferAdmin", "LockupV20") => LockupV20_TransferAdmin
  | ("WithdrawFromLockupStream", "LockupV20") => LockupV20_WithdrawFromLockupStream
  | ("Approval", "LockupV21") => LockupV21_Approval
  | ("ApprovalForAll", "LockupV21") => LockupV21_ApprovalForAll
  | ("CancelLockupStream", "LockupV21") => LockupV21_CancelLockupStream
  | ("CreateLockupLinearStream", "LockupV21") => LockupV21_CreateLockupLinearStream
  | ("CreateLockupDynamicStream", "LockupV21") => LockupV21_CreateLockupDynamicStream
  | ("RenounceLockupStream", "LockupV21") => LockupV21_RenounceLockupStream
  | ("Transfer", "LockupV21") => LockupV21_Transfer
  | ("TransferAdmin", "LockupV21") => LockupV21_TransferAdmin
  | ("WithdrawFromLockupStream", "LockupV21") => LockupV21_WithdrawFromLockupStream
  | _ => UndefinedEvent(eventName)->raise
  }
}

module LockupV20 = {
  let convertApprovalViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.ApprovalEvent.eventArgs,
  > = Obj.magic

  let convertApprovalLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV20Contract.ApprovalEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.LockupV20Contract.ApprovalEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        owner: args.owner,
        approved: args.approved,
        tokenId: args.tokenId,
      },
    }
  }

  let convertApprovalLog = (
    logDescription: Ethers.logDescription<Types.LockupV20Contract.ApprovalEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.ApprovalEvent.eventArgs = {
      owner: logDescription.args.owner,
      approved: logDescription.args.approved,
      tokenId: logDescription.args.tokenId,
    }

    let approvalLog: Types.eventLog<Types.LockupV20Contract.ApprovalEvent.eventArgs> = {
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

    Types.LockupV20Contract_Approval(approvalLog)
  }
  let convertApprovalLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV20Contract.ApprovalEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.ApprovalEvent.eventArgs = {
      owner: decodedEvent.args.owner,
      approved: decodedEvent.args.approved,
      tokenId: decodedEvent.args.tokenId,
    }

    let approvalLog: Types.eventLog<Types.LockupV20Contract.ApprovalEvent.eventArgs> = {
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

    Types.LockupV20Contract_Approval(approvalLog)
  }

  let convertApprovalForAllViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.ApprovalForAllEvent.eventArgs,
  > = Obj.magic

  let convertApprovalForAllLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV20Contract.ApprovalForAllEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV20Contract.ApprovalForAllEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        owner: args.owner,
        operator: args.operator,
        approved: args.approved,
      },
    }
  }

  let convertApprovalForAllLog = (
    logDescription: Ethers.logDescription<Types.LockupV20Contract.ApprovalForAllEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.ApprovalForAllEvent.eventArgs = {
      owner: logDescription.args.owner,
      operator: logDescription.args.operator,
      approved: logDescription.args.approved,
    }

    let approvalForAllLog: Types.eventLog<Types.LockupV20Contract.ApprovalForAllEvent.eventArgs> = {
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

    Types.LockupV20Contract_ApprovalForAll(approvalForAllLog)
  }
  let convertApprovalForAllLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV20Contract.ApprovalForAllEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.ApprovalForAllEvent.eventArgs = {
      owner: decodedEvent.args.owner,
      operator: decodedEvent.args.operator,
      approved: decodedEvent.args.approved,
    }

    let approvalForAllLog: Types.eventLog<Types.LockupV20Contract.ApprovalForAllEvent.eventArgs> = {
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

    Types.LockupV20Contract_ApprovalForAll(approvalForAllLog)
  }

  let convertCancelLockupStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs,
  > = Obj.magic

  let convertCancelLockupStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV20Contract.CancelLockupStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        sender: args.sender,
        recipient: args.recipient,
        senderAmount: args.senderAmount,
        recipientAmount: args.recipientAmount,
      },
    }
  }

  let convertCancelLockupStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      sender: logDescription.args.sender,
      recipient: logDescription.args.recipient,
      senderAmount: logDescription.args.senderAmount,
      recipientAmount: logDescription.args.recipientAmount,
    }

    let cancelLockupStreamLog: Types.eventLog<
      Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs,
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

    Types.LockupV20Contract_CancelLockupStream(cancelLockupStreamLog)
  }
  let convertCancelLockupStreamLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      sender: decodedEvent.args.sender,
      recipient: decodedEvent.args.recipient,
      senderAmount: decodedEvent.args.senderAmount,
      recipientAmount: decodedEvent.args.recipientAmount,
    }

    let cancelLockupStreamLog: Types.eventLog<
      Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs,
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

    Types.LockupV20Contract_CancelLockupStream(cancelLockupStreamLog)
  }

  let convertCreateLockupLinearStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs,
  > = Obj.magic

  let convertCreateLockupLinearStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV20Contract.CreateLockupLinearStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        funder: args.funder,
        sender: args.sender,
        recipient: args.recipient,
        amounts: args.amounts,
        asset: args.asset,
        cancelable: args.cancelable,
        range: args.range,
        broker: args.broker,
      },
    }
  }

  let convertCreateLockupLinearStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      funder: logDescription.args.funder,
      sender: logDescription.args.sender,
      recipient: logDescription.args.recipient,
      amounts: logDescription.args.amounts,
      asset: logDescription.args.asset,
      cancelable: logDescription.args.cancelable,
      range: logDescription.args.range,
      broker: logDescription.args.broker,
    }

    let createLockupLinearStreamLog: Types.eventLog<
      Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs,
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

    Types.LockupV20Contract_CreateLockupLinearStream(createLockupLinearStreamLog)
  }
  let convertCreateLockupLinearStreamLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      funder: decodedEvent.args.funder,
      sender: decodedEvent.args.sender,
      recipient: decodedEvent.args.recipient,
      amounts: decodedEvent.args.amounts,
      asset: decodedEvent.args.asset,
      cancelable: decodedEvent.args.cancelable,
      range: decodedEvent.args.range,
      broker: decodedEvent.args.broker,
    }

    let createLockupLinearStreamLog: Types.eventLog<
      Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs,
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

    Types.LockupV20Contract_CreateLockupLinearStream(createLockupLinearStreamLog)
  }

  let convertCreateLockupDynamicStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs,
  > = Obj.magic

  let convertCreateLockupDynamicStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV20Contract.CreateLockupDynamicStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        funder: args.funder,
        sender: args.sender,
        recipient: args.recipient,
        amounts: args.amounts,
        asset: args.asset,
        cancelable: args.cancelable,
        segments: args.segments,
        range: args.range,
        broker: args.broker,
      },
    }
  }

  let convertCreateLockupDynamicStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      funder: logDescription.args.funder,
      sender: logDescription.args.sender,
      recipient: logDescription.args.recipient,
      amounts: logDescription.args.amounts,
      asset: logDescription.args.asset,
      cancelable: logDescription.args.cancelable,
      segments: logDescription.args.segments,
      range: logDescription.args.range,
      broker: logDescription.args.broker,
    }

    let createLockupDynamicStreamLog: Types.eventLog<
      Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs,
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

    Types.LockupV20Contract_CreateLockupDynamicStream(createLockupDynamicStreamLog)
  }
  let convertCreateLockupDynamicStreamLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      funder: decodedEvent.args.funder,
      sender: decodedEvent.args.sender,
      recipient: decodedEvent.args.recipient,
      amounts: decodedEvent.args.amounts,
      asset: decodedEvent.args.asset,
      cancelable: decodedEvent.args.cancelable,
      segments: decodedEvent.args.segments,
      range: decodedEvent.args.range,
      broker: decodedEvent.args.broker,
    }

    let createLockupDynamicStreamLog: Types.eventLog<
      Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs,
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

    Types.LockupV20Contract_CreateLockupDynamicStream(createLockupDynamicStreamLog)
  }

  let convertRenounceLockupStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs,
  > = Obj.magic

  let convertRenounceLockupStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV20Contract.RenounceLockupStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
      },
    }
  }

  let convertRenounceLockupStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
    }

    let renounceLockupStreamLog: Types.eventLog<
      Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs,
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

    Types.LockupV20Contract_RenounceLockupStream(renounceLockupStreamLog)
  }
  let convertRenounceLockupStreamLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
    }

    let renounceLockupStreamLog: Types.eventLog<
      Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs,
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

    Types.LockupV20Contract_RenounceLockupStream(renounceLockupStreamLog)
  }

  let convertTransferViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.TransferEvent.eventArgs,
  > = Obj.magic

  let convertTransferLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV20Contract.TransferEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.LockupV20Contract.TransferEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        from: args.from,
        to: args.to,
        tokenId: args.tokenId,
      },
    }
  }

  let convertTransferLog = (
    logDescription: Ethers.logDescription<Types.LockupV20Contract.TransferEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.TransferEvent.eventArgs = {
      from: logDescription.args.from,
      to: logDescription.args.to,
      tokenId: logDescription.args.tokenId,
    }

    let transferLog: Types.eventLog<Types.LockupV20Contract.TransferEvent.eventArgs> = {
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

    Types.LockupV20Contract_Transfer(transferLog)
  }
  let convertTransferLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV20Contract.TransferEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.TransferEvent.eventArgs = {
      from: decodedEvent.args.from,
      to: decodedEvent.args.to,
      tokenId: decodedEvent.args.tokenId,
    }

    let transferLog: Types.eventLog<Types.LockupV20Contract.TransferEvent.eventArgs> = {
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

    Types.LockupV20Contract_Transfer(transferLog)
  }

  let convertTransferAdminViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.TransferAdminEvent.eventArgs,
  > = Obj.magic

  let convertTransferAdminLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV20Contract.TransferAdminEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV20Contract.TransferAdminEvent.ethersEventArgs,
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
    logDescription: Ethers.logDescription<Types.LockupV20Contract.TransferAdminEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.TransferAdminEvent.eventArgs = {
      oldAdmin: logDescription.args.oldAdmin,
      newAdmin: logDescription.args.newAdmin,
    }

    let transferAdminLog: Types.eventLog<Types.LockupV20Contract.TransferAdminEvent.eventArgs> = {
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

    Types.LockupV20Contract_TransferAdmin(transferAdminLog)
  }
  let convertTransferAdminLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV20Contract.TransferAdminEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.TransferAdminEvent.eventArgs = {
      oldAdmin: decodedEvent.args.oldAdmin,
      newAdmin: decodedEvent.args.newAdmin,
    }

    let transferAdminLog: Types.eventLog<Types.LockupV20Contract.TransferAdminEvent.eventArgs> = {
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

    Types.LockupV20Contract_TransferAdmin(transferAdminLog)
  }

  let convertWithdrawFromLockupStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs,
  > = Obj.magic

  let convertWithdrawFromLockupStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV20Contract.WithdrawFromLockupStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        to: args.to,
        amount: args.amount,
      },
    }
  }

  let convertWithdrawFromLockupStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      to: logDescription.args.to,
      amount: logDescription.args.amount,
    }

    let withdrawFromLockupStreamLog: Types.eventLog<
      Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs,
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

    Types.LockupV20Contract_WithdrawFromLockupStream(withdrawFromLockupStreamLog)
  }
  let convertWithdrawFromLockupStreamLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      to: decodedEvent.args.to,
      amount: decodedEvent.args.amount,
    }

    let withdrawFromLockupStreamLog: Types.eventLog<
      Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs,
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

    Types.LockupV20Contract_WithdrawFromLockupStream(withdrawFromLockupStreamLog)
  }
}

module LockupV21 = {
  let convertApprovalViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.ApprovalEvent.eventArgs,
  > = Obj.magic

  let convertApprovalLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV21Contract.ApprovalEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.LockupV21Contract.ApprovalEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        owner: args.owner,
        approved: args.approved,
        tokenId: args.tokenId,
      },
    }
  }

  let convertApprovalLog = (
    logDescription: Ethers.logDescription<Types.LockupV21Contract.ApprovalEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.ApprovalEvent.eventArgs = {
      owner: logDescription.args.owner,
      approved: logDescription.args.approved,
      tokenId: logDescription.args.tokenId,
    }

    let approvalLog: Types.eventLog<Types.LockupV21Contract.ApprovalEvent.eventArgs> = {
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

    Types.LockupV21Contract_Approval(approvalLog)
  }
  let convertApprovalLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV21Contract.ApprovalEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.ApprovalEvent.eventArgs = {
      owner: decodedEvent.args.owner,
      approved: decodedEvent.args.approved,
      tokenId: decodedEvent.args.tokenId,
    }

    let approvalLog: Types.eventLog<Types.LockupV21Contract.ApprovalEvent.eventArgs> = {
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

    Types.LockupV21Contract_Approval(approvalLog)
  }

  let convertApprovalForAllViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.ApprovalForAllEvent.eventArgs,
  > = Obj.magic

  let convertApprovalForAllLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV21Contract.ApprovalForAllEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV21Contract.ApprovalForAllEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        owner: args.owner,
        operator: args.operator,
        approved: args.approved,
      },
    }
  }

  let convertApprovalForAllLog = (
    logDescription: Ethers.logDescription<Types.LockupV21Contract.ApprovalForAllEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.ApprovalForAllEvent.eventArgs = {
      owner: logDescription.args.owner,
      operator: logDescription.args.operator,
      approved: logDescription.args.approved,
    }

    let approvalForAllLog: Types.eventLog<Types.LockupV21Contract.ApprovalForAllEvent.eventArgs> = {
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

    Types.LockupV21Contract_ApprovalForAll(approvalForAllLog)
  }
  let convertApprovalForAllLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV21Contract.ApprovalForAllEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.ApprovalForAllEvent.eventArgs = {
      owner: decodedEvent.args.owner,
      operator: decodedEvent.args.operator,
      approved: decodedEvent.args.approved,
    }

    let approvalForAllLog: Types.eventLog<Types.LockupV21Contract.ApprovalForAllEvent.eventArgs> = {
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

    Types.LockupV21Contract_ApprovalForAll(approvalForAllLog)
  }

  let convertCancelLockupStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs,
  > = Obj.magic

  let convertCancelLockupStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV21Contract.CancelLockupStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        sender: args.sender,
        recipient: args.recipient,
        asset: args.asset,
        senderAmount: args.senderAmount,
        recipientAmount: args.recipientAmount,
      },
    }
  }

  let convertCancelLockupStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      sender: logDescription.args.sender,
      recipient: logDescription.args.recipient,
      asset: logDescription.args.asset,
      senderAmount: logDescription.args.senderAmount,
      recipientAmount: logDescription.args.recipientAmount,
    }

    let cancelLockupStreamLog: Types.eventLog<
      Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs,
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

    Types.LockupV21Contract_CancelLockupStream(cancelLockupStreamLog)
  }
  let convertCancelLockupStreamLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      sender: decodedEvent.args.sender,
      recipient: decodedEvent.args.recipient,
      asset: decodedEvent.args.asset,
      senderAmount: decodedEvent.args.senderAmount,
      recipientAmount: decodedEvent.args.recipientAmount,
    }

    let cancelLockupStreamLog: Types.eventLog<
      Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs,
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

    Types.LockupV21Contract_CancelLockupStream(cancelLockupStreamLog)
  }

  let convertCreateLockupLinearStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs,
  > = Obj.magic

  let convertCreateLockupLinearStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV21Contract.CreateLockupLinearStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        funder: args.funder,
        sender: args.sender,
        recipient: args.recipient,
        amounts: args.amounts,
        asset: args.asset,
        cancelable: args.cancelable,
        transferable: args.transferable,
        range: args.range,
        broker: args.broker,
      },
    }
  }

  let convertCreateLockupLinearStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      funder: logDescription.args.funder,
      sender: logDescription.args.sender,
      recipient: logDescription.args.recipient,
      amounts: logDescription.args.amounts,
      asset: logDescription.args.asset,
      cancelable: logDescription.args.cancelable,
      transferable: logDescription.args.transferable,
      range: logDescription.args.range,
      broker: logDescription.args.broker,
    }

    let createLockupLinearStreamLog: Types.eventLog<
      Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs,
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

    Types.LockupV21Contract_CreateLockupLinearStream(createLockupLinearStreamLog)
  }
  let convertCreateLockupLinearStreamLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      funder: decodedEvent.args.funder,
      sender: decodedEvent.args.sender,
      recipient: decodedEvent.args.recipient,
      amounts: decodedEvent.args.amounts,
      asset: decodedEvent.args.asset,
      cancelable: decodedEvent.args.cancelable,
      transferable: decodedEvent.args.transferable,
      range: decodedEvent.args.range,
      broker: decodedEvent.args.broker,
    }

    let createLockupLinearStreamLog: Types.eventLog<
      Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs,
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

    Types.LockupV21Contract_CreateLockupLinearStream(createLockupLinearStreamLog)
  }

  let convertCreateLockupDynamicStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs,
  > = Obj.magic

  let convertCreateLockupDynamicStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV21Contract.CreateLockupDynamicStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        funder: args.funder,
        sender: args.sender,
        recipient: args.recipient,
        amounts: args.amounts,
        asset: args.asset,
        cancelable: args.cancelable,
        transferable: args.transferable,
        segments: args.segments,
        range: args.range,
        broker: args.broker,
      },
    }
  }

  let convertCreateLockupDynamicStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      funder: logDescription.args.funder,
      sender: logDescription.args.sender,
      recipient: logDescription.args.recipient,
      amounts: logDescription.args.amounts,
      asset: logDescription.args.asset,
      cancelable: logDescription.args.cancelable,
      transferable: logDescription.args.transferable,
      segments: logDescription.args.segments,
      range: logDescription.args.range,
      broker: logDescription.args.broker,
    }

    let createLockupDynamicStreamLog: Types.eventLog<
      Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs,
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

    Types.LockupV21Contract_CreateLockupDynamicStream(createLockupDynamicStreamLog)
  }
  let convertCreateLockupDynamicStreamLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      funder: decodedEvent.args.funder,
      sender: decodedEvent.args.sender,
      recipient: decodedEvent.args.recipient,
      amounts: decodedEvent.args.amounts,
      asset: decodedEvent.args.asset,
      cancelable: decodedEvent.args.cancelable,
      transferable: decodedEvent.args.transferable,
      segments: decodedEvent.args.segments,
      range: decodedEvent.args.range,
      broker: decodedEvent.args.broker,
    }

    let createLockupDynamicStreamLog: Types.eventLog<
      Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs,
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

    Types.LockupV21Contract_CreateLockupDynamicStream(createLockupDynamicStreamLog)
  }

  let convertRenounceLockupStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs,
  > = Obj.magic

  let convertRenounceLockupStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV21Contract.RenounceLockupStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
      },
    }
  }

  let convertRenounceLockupStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
    }

    let renounceLockupStreamLog: Types.eventLog<
      Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs,
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

    Types.LockupV21Contract_RenounceLockupStream(renounceLockupStreamLog)
  }
  let convertRenounceLockupStreamLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
    }

    let renounceLockupStreamLog: Types.eventLog<
      Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs,
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

    Types.LockupV21Contract_RenounceLockupStream(renounceLockupStreamLog)
  }

  let convertTransferViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.TransferEvent.eventArgs,
  > = Obj.magic

  let convertTransferLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV21Contract.TransferEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.LockupV21Contract.TransferEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        from: args.from,
        to: args.to,
        tokenId: args.tokenId,
      },
    }
  }

  let convertTransferLog = (
    logDescription: Ethers.logDescription<Types.LockupV21Contract.TransferEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.TransferEvent.eventArgs = {
      from: logDescription.args.from,
      to: logDescription.args.to,
      tokenId: logDescription.args.tokenId,
    }

    let transferLog: Types.eventLog<Types.LockupV21Contract.TransferEvent.eventArgs> = {
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

    Types.LockupV21Contract_Transfer(transferLog)
  }
  let convertTransferLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV21Contract.TransferEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.TransferEvent.eventArgs = {
      from: decodedEvent.args.from,
      to: decodedEvent.args.to,
      tokenId: decodedEvent.args.tokenId,
    }

    let transferLog: Types.eventLog<Types.LockupV21Contract.TransferEvent.eventArgs> = {
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

    Types.LockupV21Contract_Transfer(transferLog)
  }

  let convertTransferAdminViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.TransferAdminEvent.eventArgs,
  > = Obj.magic

  let convertTransferAdminLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.LockupV21Contract.TransferAdminEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV21Contract.TransferAdminEvent.ethersEventArgs,
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
    logDescription: Ethers.logDescription<Types.LockupV21Contract.TransferAdminEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.TransferAdminEvent.eventArgs = {
      oldAdmin: logDescription.args.oldAdmin,
      newAdmin: logDescription.args.newAdmin,
    }

    let transferAdminLog: Types.eventLog<Types.LockupV21Contract.TransferAdminEvent.eventArgs> = {
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

    Types.LockupV21Contract_TransferAdmin(transferAdminLog)
  }
  let convertTransferAdminLogViem = (
    decodedEvent: Viem.decodedEvent<Types.LockupV21Contract.TransferAdminEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.TransferAdminEvent.eventArgs = {
      oldAdmin: decodedEvent.args.oldAdmin,
      newAdmin: decodedEvent.args.newAdmin,
    }

    let transferAdminLog: Types.eventLog<Types.LockupV21Contract.TransferAdminEvent.eventArgs> = {
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

    Types.LockupV21Contract_TransferAdmin(transferAdminLog)
  }

  let convertWithdrawFromLockupStreamViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs,
  > = Obj.magic

  let convertWithdrawFromLockupStreamLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs> => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.LockupV21Contract.WithdrawFromLockupStreamEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        streamId: args.streamId,
        to: args.to,
        asset: args.asset,
        amount: args.amount,
      },
    }
  }

  let convertWithdrawFromLockupStreamLog = (
    logDescription: Ethers.logDescription<
      Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs = {
      streamId: logDescription.args.streamId,
      to: logDescription.args.to,
      asset: logDescription.args.asset,
      amount: logDescription.args.amount,
    }

    let withdrawFromLockupStreamLog: Types.eventLog<
      Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs,
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

    Types.LockupV21Contract_WithdrawFromLockupStream(withdrawFromLockupStreamLog)
  }
  let convertWithdrawFromLockupStreamLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
  ) => {
    let params: Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs = {
      streamId: decodedEvent.args.streamId,
      to: decodedEvent.args.to,
      asset: decodedEvent.args.asset,
      amount: decodedEvent.args.amount,
    }

    let withdrawFromLockupStreamLog: Types.eventLog<
      Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs,
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

    Types.LockupV21Contract_WithdrawFromLockupStream(withdrawFromLockupStreamLog)
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
      | LockupV20_Approval =>
        logDescription
        ->LockupV20.convertApprovalLogDescription
        ->LockupV20.convertApprovalLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_ApprovalForAll =>
        logDescription
        ->LockupV20.convertApprovalForAllLogDescription
        ->LockupV20.convertApprovalForAllLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_CancelLockupStream =>
        logDescription
        ->LockupV20.convertCancelLockupStreamLogDescription
        ->LockupV20.convertCancelLockupStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_CreateLockupLinearStream =>
        logDescription
        ->LockupV20.convertCreateLockupLinearStreamLogDescription
        ->LockupV20.convertCreateLockupLinearStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_CreateLockupDynamicStream =>
        logDescription
        ->LockupV20.convertCreateLockupDynamicStreamLogDescription
        ->LockupV20.convertCreateLockupDynamicStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_RenounceLockupStream =>
        logDescription
        ->LockupV20.convertRenounceLockupStreamLogDescription
        ->LockupV20.convertRenounceLockupStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_Transfer =>
        logDescription
        ->LockupV20.convertTransferLogDescription
        ->LockupV20.convertTransferLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_TransferAdmin =>
        logDescription
        ->LockupV20.convertTransferAdminLogDescription
        ->LockupV20.convertTransferAdminLog(~log, ~blockTimestamp, ~chainId)
      | LockupV20_WithdrawFromLockupStream =>
        logDescription
        ->LockupV20.convertWithdrawFromLockupStreamLogDescription
        ->LockupV20.convertWithdrawFromLockupStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_Approval =>
        logDescription
        ->LockupV21.convertApprovalLogDescription
        ->LockupV21.convertApprovalLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_ApprovalForAll =>
        logDescription
        ->LockupV21.convertApprovalForAllLogDescription
        ->LockupV21.convertApprovalForAllLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_CancelLockupStream =>
        logDescription
        ->LockupV21.convertCancelLockupStreamLogDescription
        ->LockupV21.convertCancelLockupStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_CreateLockupLinearStream =>
        logDescription
        ->LockupV21.convertCreateLockupLinearStreamLogDescription
        ->LockupV21.convertCreateLockupLinearStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_CreateLockupDynamicStream =>
        logDescription
        ->LockupV21.convertCreateLockupDynamicStreamLogDescription
        ->LockupV21.convertCreateLockupDynamicStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_RenounceLockupStream =>
        logDescription
        ->LockupV21.convertRenounceLockupStreamLogDescription
        ->LockupV21.convertRenounceLockupStreamLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_Transfer =>
        logDescription
        ->LockupV21.convertTransferLogDescription
        ->LockupV21.convertTransferLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_TransferAdmin =>
        logDescription
        ->LockupV21.convertTransferAdminLogDescription
        ->LockupV21.convertTransferAdminLog(~log, ~blockTimestamp, ~chainId)
      | LockupV21_WithdrawFromLockupStream =>
        logDescription
        ->LockupV21.convertWithdrawFromLockupStreamLogDescription
        ->LockupV21.convertWithdrawFromLockupStreamLog(~log, ~blockTimestamp, ~chainId)
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
      | LockupV20_Approval =>
        decodedEvent
        ->LockupV20.convertApprovalViemDecodedEvent
        ->LockupV20.convertApprovalLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_ApprovalForAll =>
        decodedEvent
        ->LockupV20.convertApprovalForAllViemDecodedEvent
        ->LockupV20.convertApprovalForAllLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_CancelLockupStream =>
        decodedEvent
        ->LockupV20.convertCancelLockupStreamViemDecodedEvent
        ->LockupV20.convertCancelLockupStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_CreateLockupLinearStream =>
        decodedEvent
        ->LockupV20.convertCreateLockupLinearStreamViemDecodedEvent
        ->LockupV20.convertCreateLockupLinearStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_CreateLockupDynamicStream =>
        decodedEvent
        ->LockupV20.convertCreateLockupDynamicStreamViemDecodedEvent
        ->LockupV20.convertCreateLockupDynamicStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_RenounceLockupStream =>
        decodedEvent
        ->LockupV20.convertRenounceLockupStreamViemDecodedEvent
        ->LockupV20.convertRenounceLockupStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_Transfer =>
        decodedEvent
        ->LockupV20.convertTransferViemDecodedEvent
        ->LockupV20.convertTransferLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_TransferAdmin =>
        decodedEvent
        ->LockupV20.convertTransferAdminViemDecodedEvent
        ->LockupV20.convertTransferAdminLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV20_WithdrawFromLockupStream =>
        decodedEvent
        ->LockupV20.convertWithdrawFromLockupStreamViemDecodedEvent
        ->LockupV20.convertWithdrawFromLockupStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_Approval =>
        decodedEvent
        ->LockupV21.convertApprovalViemDecodedEvent
        ->LockupV21.convertApprovalLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_ApprovalForAll =>
        decodedEvent
        ->LockupV21.convertApprovalForAllViemDecodedEvent
        ->LockupV21.convertApprovalForAllLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_CancelLockupStream =>
        decodedEvent
        ->LockupV21.convertCancelLockupStreamViemDecodedEvent
        ->LockupV21.convertCancelLockupStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_CreateLockupLinearStream =>
        decodedEvent
        ->LockupV21.convertCreateLockupLinearStreamViemDecodedEvent
        ->LockupV21.convertCreateLockupLinearStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_CreateLockupDynamicStream =>
        decodedEvent
        ->LockupV21.convertCreateLockupDynamicStreamViemDecodedEvent
        ->LockupV21.convertCreateLockupDynamicStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_RenounceLockupStream =>
        decodedEvent
        ->LockupV21.convertRenounceLockupStreamViemDecodedEvent
        ->LockupV21.convertRenounceLockupStreamLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_Transfer =>
        decodedEvent
        ->LockupV21.convertTransferViemDecodedEvent
        ->LockupV21.convertTransferLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_TransferAdmin =>
        decodedEvent
        ->LockupV21.convertTransferAdminViemDecodedEvent
        ->LockupV21.convertTransferAdminLogViem(~log, ~blockTimestamp, ~chainId)
      | LockupV21_WithdrawFromLockupStream =>
        decodedEvent
        ->LockupV21.convertWithdrawFromLockupStreamViemDecodedEvent
        ->LockupV21.convertWithdrawFromLockupStreamLogViem(~log, ~blockTimestamp, ~chainId)
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
    | LockupV20_Approval =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.ApprovalEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_Approval,
        ~chainId,
      )
    | LockupV20_ApprovalForAll =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.ApprovalForAllEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_ApprovalForAll,
        ~chainId,
      )
    | LockupV20_CancelLockupStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.CancelLockupStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_CancelLockupStream,
        ~chainId,
      )
    | LockupV20_CreateLockupLinearStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.CreateLockupLinearStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_CreateLockupLinearStream,
        ~chainId,
      )
    | LockupV20_CreateLockupDynamicStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.CreateLockupDynamicStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_CreateLockupDynamicStream,
        ~chainId,
      )
    | LockupV20_RenounceLockupStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.RenounceLockupStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_RenounceLockupStream,
        ~chainId,
      )
    | LockupV20_Transfer =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.TransferEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_Transfer,
        ~chainId,
      )
    | LockupV20_TransferAdmin =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.TransferAdminEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_TransferAdmin,
        ~chainId,
      )
    | LockupV20_WithdrawFromLockupStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV20Contract.WithdrawFromLockupStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV20Contract_WithdrawFromLockupStream,
        ~chainId,
      )
    | LockupV21_Approval =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.ApprovalEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_Approval,
        ~chainId,
      )
    | LockupV21_ApprovalForAll =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.ApprovalForAllEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_ApprovalForAll,
        ~chainId,
      )
    | LockupV21_CancelLockupStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.CancelLockupStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_CancelLockupStream,
        ~chainId,
      )
    | LockupV21_CreateLockupLinearStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.CreateLockupLinearStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_CreateLockupLinearStream,
        ~chainId,
      )
    | LockupV21_CreateLockupDynamicStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.CreateLockupDynamicStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_CreateLockupDynamicStream,
        ~chainId,
      )
    | LockupV21_RenounceLockupStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.RenounceLockupStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_RenounceLockupStream,
        ~chainId,
      )
    | LockupV21_Transfer =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.TransferEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_Transfer,
        ~chainId,
      )
    | LockupV21_TransferAdmin =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.TransferAdminEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_TransferAdmin,
        ~chainId,
      )
    | LockupV21_WithdrawFromLockupStream =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.LockupV21Contract.WithdrawFromLockupStreamEvent.eventArgs_decode,
        ~variantAccessor=Types.lockupV21Contract_WithdrawFromLockupStream,
        ~chainId,
      )
    }
  })
}
