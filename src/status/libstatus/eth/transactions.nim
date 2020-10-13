import
  json

import
  json_serialization, chronicles, web3/ethtypes

import
  ../core, ../types, ../conversions

proc estimateGas*(tx: EthSend): RpcResponse =
  let response = core.callPrivateRPC("eth_estimateGas", %*[%tx])
  result = Json.decode(response, RpcResponse)
  if not result.error.isNil:
    raise newException(RpcException, "Error getting gas estimate: " & result.error.message)

  trace "Gas estimated succesfully", estimate=result.result

proc sendTransaction*(tx: EthSend, password: string): RpcResponse =
  let responseStr = core.sendTransaction($(%tx), password)
  result = Json.decode(responseStr, RpcResponse)
  if not result.error.isNil:
    raise newException(RpcException, "Error sending transaction: " & result.error.message)

  trace "Transaction sent succesfully", hash=result.result

proc call*(tx: EthSend): RpcResponse =
  let responseStr = core.callPrivateRPC("eth_call", %*[%tx])
  result = Json.decode(responseStr, RpcResponse)
  if not result.error.isNil:
    raise newException(RpcException, "Error calling method: " & result.error.message)

proc signTransaction*(tx: EthSend, nonce: string, password: string, chainId: int): RpcResponse =
  var trxJson = %*tx
  trxJson["nonce"] = newJString(nonce)
  let responseStr = core.signTransaction($trxJson, password, chainId)
  result = Json.decode(responseStr, RpcResponse)
  if not result.error.isNil:
    raise newException(RpcException, "Error signing transaction: " & result.error.message)

  trace "Transaction signed succesfully", hash=result.result
