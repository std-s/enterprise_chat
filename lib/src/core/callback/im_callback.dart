import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:get/get.dart';
import 'package:openim_enterprise_chat/src/core/controller/app_controller.dart';
import 'package:rxdart/rxdart.dart';

class IMCallback {
  /// 收到消息撤回
  Function(String msgId)? onRecvMessageRevoked;

  /// 收到消息撤回
  Function(RevokedInfo info)? onRecvMessageRevokedV2;

  /// 收到C2C消息已读回执
  Function(List<ReadReceiptInfo> list)? onRecvC2CReadReceipt;

  /// 收到群消息已读回执
  Function(List<ReadReceiptInfo> list)? onRecvGroupReadReceipt;

  /// 收到新消息
  Function(Message msg)? onRecvNewMessage;

  /// 消息发送进度回执
  Function(String msgId, int progress)? onMsgSendProgress;

  /// 已加入黑名单
  Function(BlacklistInfo u)? onBlacklistAdd;

  /// 已从黑名单移除
  Function(BlacklistInfo u)? onBlacklistDeleted;

  /// 新增会话
  var conversationAddedSubject = BehaviorSubject<List<ConversationInfo>>();

  /// 旧会话更新
  var conversationChangedSubject = BehaviorSubject<List<ConversationInfo>>();

  /// 未读消息数
  var unreadMsgCountEventSubject = PublishSubject<int>();

  /// 好友申请列表变化（包含自己发出的以及收到的）
  var friendApplicationChangedSubject = BehaviorSubject<FriendApplicationInfo>();

  /// 新增好友
  var friendAddSubject = BehaviorSubject<FriendInfo>();

  /// 删除好友
  var friendDelSubject = BehaviorSubject<FriendInfo>();

  /// 好友信息改变
  var friendInfoChangedSubject = BehaviorSubject<FriendInfo>();

  /// 自己信息更新
  var selfInfoUpdatedSubject = BehaviorSubject<UserInfo>();

  /// 组信息更新
  var groupInfoUpdatedSubject = BehaviorSubject<GroupInfo>();

  /// 组申请列表变化（包含自己发出的以及收到的）
  var groupApplicationChangedSubject = BehaviorSubject<GroupApplicationInfo>();

  var initializedSubject = PublishSubject<bool>();

  /// 群成员收到：群成员已进入
  var memberAddedSubject = BehaviorSubject<GroupMembersInfo>();

  /// 群成员收到：群成员已退出
  var memberDeletedSubject = BehaviorSubject<GroupMembersInfo>();

  /// 群成员信息变化
  var memberInfoChangedSubject = BehaviorSubject<GroupMembersInfo>();

  /// 被踢
  final joinedGroupDeletedSubject = BehaviorSubject<GroupInfo>();

  /// 拉人
  final joinedGroupAddedSubject = BehaviorSubject<GroupInfo>();

  var onKickedOfflineSubject = PublishSubject();

  // -1 链接失败 0 链接中 1 链接成功 2 同步开始 3 同步结束 4 同步错误
  var connectionSubject = BehaviorSubject<int>();

  final roomParticipantDisconnectedSubject = PublishSubject<RoomCallingInfo>();
  final roomParticipantConnectedSubject = PublishSubject<RoomCallingInfo>();

  var momentsSubject = PublishSubject();

  final meetingSteamChangedSubject = PublishSubject<dynamic>();

  void connectionStatus(int status) {
    connectionSubject.addSafely(status);
  }

  void kickedOffline() {
    onKickedOfflineSubject.add("");
  }

  void selfInfoUpdated(UserInfo u) {
    selfInfoUpdatedSubject.addSafely(u);
  }

  void recvMessageRevoked(String id) {
    onRecvMessageRevoked?.call(id);
  }

  void recvC2CMessageReadReceipt(List<ReadReceiptInfo> list) {
    onRecvC2CReadReceipt?.call(list);
  }

  void recvGroupMessageReadReceipt(List<ReadReceiptInfo> list) {
    print('--------------recvGroupMessageReadReceipt-----');
    onRecvGroupReadReceipt?.call(list);
  }

  void recvNewMessage(Message msg) {
    // initLogic.showNotification(msg);
    onRecvNewMessage?.call(msg);
  }

  void recvMessageRevokedV2(RevokedInfo info) {
    onRecvMessageRevokedV2?.call(info);
  }

  void progressCallback(String msgId, int progress) {
    onMsgSendProgress?.call(msgId, progress);
  }

  void blacklistAdded(BlacklistInfo u) {
    onBlacklistAdd?.call(u);
  }

  void blacklistDeleted(BlacklistInfo u) {
    onBlacklistDeleted?.call(u);
  }

  void friendApplicationAccepted(FriendApplicationInfo u) {
    friendApplicationChangedSubject.addSafely(u);
  }

  void friendApplicationAdded(FriendApplicationInfo u) {
    friendApplicationChangedSubject.addSafely(u);
  }

  void friendApplicationDeleted(FriendApplicationInfo u) {
    friendApplicationChangedSubject.addSafely(u);
  }

  void friendApplicationRejected(FriendApplicationInfo u) {
    friendApplicationChangedSubject.addSafely(u);
  }

  void friendInfoChanged(FriendInfo u) {
    friendInfoChangedSubject.addSafely(u);
  }

  void friendAdded(FriendInfo u) {
    friendAddSubject.addSafely(u);
  }

  void friendDeleted(FriendInfo u) {
    friendDelSubject.addSafely(u);
  }

  void conversationChanged(List<ConversationInfo> list) {
    conversationChangedSubject.addSafely(list);
  }

  void newConversation(List<ConversationInfo> list) {
    conversationAddedSubject.addSafely(list);
  }

  void groupApplicationAccepted(GroupApplicationInfo info) {
    groupApplicationChangedSubject.add(info);
  }

  void groupApplicationAdded(GroupApplicationInfo info) {
    groupApplicationChangedSubject.add(info);
  }

  void groupApplicationDeleted(GroupApplicationInfo info) {
    groupApplicationChangedSubject.add(info);
  }

  void groupApplicationRejected(GroupApplicationInfo info) {
    groupApplicationChangedSubject.add(info);
  }

  void groupInfoChanged(GroupInfo info) {
    groupInfoUpdatedSubject.addSafely(info);
  }

  void groupMemberAdded(GroupMembersInfo info) {
    memberAddedSubject.add(info);
  }

  void groupMemberDeleted(GroupMembersInfo info) {
    memberDeletedSubject.add(info);
  }

  void groupMemberInfoChanged(GroupMembersInfo info) {
    memberInfoChangedSubject.add(info);
  }

  /// 创建群： 初始成员收到；邀请进群：被邀请者收到
  void joinedGroupAdded(GroupInfo info) {
    joinedGroupAddedSubject.add(info);
  }

  /// 退出群：退出者收到；踢出群：被踢者收到
  void joinedGroupDeleted(GroupInfo info) {
    joinedGroupDeletedSubject.add(info);
  }

  void totalUnreadMsgCountChanged(int count) {
    initLogic.showBadge(count);
    unreadMsgCountEventSubject.addSafely(count);
  }

  /// 群通话信息变更
  void roomParticipantConnected(RoomCallingInfo info) {
    roomParticipantConnectedSubject.add(info);
  }

  /// 群通话信息变更
  void roomParticipantDisconnected(RoomCallingInfo info) {
    roomParticipantDisconnectedSubject.add(info);
  }

  void meetingSteamChanged(MeetingStreamEvent event) {
    meetingSteamChangedSubject.add(event.toJson());
  }

  void recvNewNotification() {
    momentsSubject.addSafely('');
  }

  void close() {
    initializedSubject.close();
    friendApplicationChangedSubject.close();
    friendAddSubject.close();
    friendDelSubject.close();
    friendInfoChangedSubject.close();
    selfInfoUpdatedSubject.close();
    groupInfoUpdatedSubject.close();
    conversationAddedSubject.close();
    conversationChangedSubject.close();
    memberAddedSubject.close();
    memberDeletedSubject.close();
    memberInfoChangedSubject.close();
    onKickedOfflineSubject.close();
    groupApplicationChangedSubject.close();
    momentsSubject.close();
    connectionSubject.close();
    roomParticipantConnectedSubject.close();
    roomParticipantDisconnectedSubject.close();
    joinedGroupDeletedSubject.close();
    joinedGroupAddedSubject.close();
    meetingSteamChangedSubject.close();
  }

  final initLogic = Get.find<AppController>();
}
