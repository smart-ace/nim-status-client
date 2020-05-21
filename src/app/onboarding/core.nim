import NimQml
import json
import ../../status/accounts as status_accounts
import nimcrypto
import ../../status/utils
import ../../status/libstatus
import ../../models/accounts as Models
import ../../constants/constants
import ../../status/test as status_test
# import "../../status/core" as status
import ../signals/types
import uuids
import eventemitter
import view

proc storeAccountAndLogin(model: AccountModel, selectedAccountIndex: int, password: string): string =
  # let account = to(json.parseJson(selectedAccount), Models.GeneratedAccount)
  echo "account index selected is "
  echo selectedAccountIndex

  let account: GeneratedAccount = model.generatedAddresses[selectedAccountIndex]
  echo "account selected is "
  echo account
  let password = "0x" & $keccak_256.digest(password)
  let multiAccount = %* {
    "accountID": account.id,
    "paths": [constants.PATH_WALLET_ROOT, constants.PATH_EIP_1581, constants.PATH_WHISPER,
      constants.PATH_DEFAULT_WALLET],
    "password": password
  }
  let storeResult = $libstatus.multiAccountStoreDerivedAccounts($multiAccount);
  let multiAccounts = storeResult.parseJson
  let whisperPubKey = account.derived[constants.PATH_WHISPER]["publicKey"].getStr
  let alias = $libstatus.generateAlias(whisperPubKey.toGoString)
  let identicon = $libstatus.identicon(whisperPubKey.toGoString)
  let accountData = %* {
    "name": alias,
    "address": account.address,
    "photo-path": identicon,
    "key-uid": account.keyUid,
    "keycard-pairing": nil
  }
  var nodeConfig = constants.NODE_CONFIG
  let defaultNetworks = constants.DEFAULT_NETWORKS
  let settingsJSON = %* {
    "key-uid": account.keyUid,
    "mnemonic": account.mnemonic,
    "public-key": multiAccounts[constants.PATH_WHISPER]["publicKey"].getStr,
    "name": alias,
    "address": account.address,
    "eip1581-address": multiAccounts[constants.PATH_EIP_1581]["address"].getStr,
    "dapps-address": multiAccounts[constants.PATH_DEFAULT_WALLET]["address"].getStr,
    "wallet-root-address": multiAccounts[constants.PATH_WALLET_ROOT]["address"].getStr,
    "preview-privacy?": true,
    "signing-phrase": generateSigningPhrase(3),
    "log-level": "INFO",
    "latest-derived-path": 0,
    "networks/networks": $defaultNetworks,
    "currency": "usd",
    "photo-path": identicon,
    "waku-enabled": true,
    "wallet/visible-tokens": {
      "mainnet": ["SNT"]
    },
    "appearance": 0,
    "networks/current-network": "mainnet_rpc",
    "installation-id": $genUUID()
  }

  let subaccountData = %* [
    {
      "public-key": multiAccounts[constants.PATH_DEFAULT_WALLET]["publicKey"],
      "address": multiAccounts[constants.PATH_DEFAULT_WALLET]["address"],
      "color": "#4360df",
      "wallet": true,
      "path": constants.PATH_DEFAULT_WALLET,
      "name": "Status account"
    },
    {
      "public-key": multiAccounts[constants.PATH_WHISPER]["publicKey"],
      "address": multiAccounts[constants.PATH_WHISPER]["address"],
      "name": alias,
      "photo-path": identicon,
      "path": constants.PATH_WHISPER,
      "chat": true
    }
  ]

  result = $libstatus.saveAccountAndLogin($accountData, password, $settingsJSON,
    $nodeConfig, $subaccountData)

  let saveResult = result.parseJson

  if saveResult["error"].getStr == "":
    model.events.emit("node:ready", Args())
    echo "Account saved succesfully"

# TODO: this is temporary and will be removed once accounts import and creation is working
proc generateRandomAccountAndLogin*(events: EventEmitter) =
  discard status_test.setupNewAccount()
  events.emit("node:ready", Args())

type OnboardingController* = ref object of SignalSubscriber
  view*: OnboardingView
  variant*: QVariant
  model*: AccountModel

proc newController*(events: EventEmitter): OnboardingController =
  result = OnboardingController()
  # TODO: events should be specific to the model itself
  result.model = newAccountModel(events)
  result.view = newOnboardingView(result.model, storeAccountAndLogin, generateRandomAccountAndLogin)
  result.variant = newQVariant(result.view)

proc delete*(self: OnboardingController) =
  delete self.view
  delete self.variant

proc init*(self: OnboardingController) =
  # let addresses = parseJson(status_accounts.generateAddresses())
  let accounts = self.model.generateAddresses()

  for account in accounts:
    # self.view.addAddressToList("account.username", "account.identicon", "account.key")
    self.view.addAddressToList(account.username, account.identicon, account.key)
    # echo address
    # var username = $libstatus.generateAlias(address["publicKey"].str.toGoString)
    # var identicon = $libstatus.identicon(address["publicKey"].str.toGoString)
    # var generatedAddress = address["address"].str
    # self.view.addAddressToList(username, identicon, generatedAddress)

# method onSignal(self: OnboardingController, data: Signal) =
#   echo "new signal received"
#   var msg = cast[WalletSignal](data)
#   self.view.setLastMessage(msg.content)