import NimQml, Tables, std/wrapnils
import ../../../status/[chat/chat, status]
import channels_list
import ../../../eventemitter
import community_members_list

QtObject:
  type CommunityItemView* = ref object of QObject
    communityItem*: Community
    chats*: ChannelsList
    members*: CommunityMembersView
    status*: Status
    active*: bool

  proc setup(self: CommunityItemView) =
    self.QObject.setup

  proc delete*(self: CommunityItemView) =
    if not self.chats.isNil: self.chats.delete
    self.QObject.delete

  proc newCommunityItemView*(status: Status): CommunityItemView =
    new(result, delete)
    result = CommunityItemView()
    result.status = status
    result.active = false
    result.chats = newChannelsList(status)
    result.members = newCommunityMembersView(status)
    result.setup

  proc setCommunityItem*(self: CommunityItemView, communityItem: Community) =
    self.communityItem = communityItem
    self.chats.setChats(communityItem.chats)
    self.members.setMembers(communityItem.members)

  proc activeChanged*(self: CommunityItemView) {.signal.}

  proc setActive*(self: CommunityItemView, value: bool) {.slot.} =
    self.active = value
    self.status.events.emit("communityActiveChanged", Args())
    self.activeChanged()

  proc nbMembersChanged*(self: CommunityItemView) {.signal.}

  proc removeMember*(self: CommunityItemView, pubKey: string) =
    self.members.removeMember(pubKey)
    self.nbMembersChanged()

  proc active*(self: CommunityItemView): bool {.slot.} = result = ?.self.active
  
  QtProperty[bool] active:
    read = active
    write = setActive
    notify = activeChanged

  proc id*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.id
  
  QtProperty[string] id:
    read = id

  proc name*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.name
  
  QtProperty[string] name:
    read = name

  proc description*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.description
  
  QtProperty[string] description:
    read = description

  proc access*(self: CommunityItemView): int {.slot.} = result = ?.self.communityItem.access
  
  QtProperty[int] access:
    read = access

  proc admin*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.admin
  
  QtProperty[bool] admin:
    read = admin

  proc joined*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.joined
  
  QtProperty[bool] joined:
    read = joined

  proc verified*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.verified
  
  QtProperty[bool] verified:
    read = verified

  proc nbMembers*(self: CommunityItemView): int {.slot.} = result = ?.self.communityItem.members.len
  
  QtProperty[int] nbMembers:
    read = nbMembers
    notify = nbMembersChanged

  proc getChats*(self: CommunityItemView): QVariant {.slot.} =
    result = newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChats

  proc getMembers*(self: CommunityItemView): QVariant {.slot.} =
    result = newQVariant(self.members)

  QtProperty[QVariant] members:
    read = getMembers