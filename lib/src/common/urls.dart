import 'config.dart';

class Urls {
  static var register2 = "${Config.imApiUrl()}/demo/user_register";
  static var login2 = "${Config.imApiUrl()}/demo/user_token";
  static var importFriends = "${Config.imApiUrl()}/friend/import_friend";
  static var inviteToGroup = "${Config.imApiUrl()}/group/invite_user_to_group";
  static var onlineStatus =
      "${Config.imApiUrl()}/manager/get_users_online_status";
  static var userOnlineStatus =
      "${Config.imApiUrl()}/user/get_users_online_status";
  static var queryAllUsers = "${Config.imApiUrl()}/manager/get_all_users_uid";
  static var updateUserInfo = "${Config.appAuthUrl()}/user/update_user_info";
  static var getUsersFullInfo =
      "${Config.appAuthUrl()}/user/get_users_full_info";
  static var searchUserFullInfo =
      "${Config.appAuthUrl()}/user/search_users_full_info";

  /// 登录注册 独立于im的业务
  static var getVerificationCode = "${Config.appAuthUrl()}/account/code";
  static var checkVerificationCode = "${Config.appAuthUrl()}/account/verify";
  static var setPwd = "${Config.appAuthUrl()}/account/password";
  static var resetPwd = "${Config.appAuthUrl()}/account/reset_password";
  static var changePwd = "${Config.appAuthUrl()}/account/change_password";
  static var login = "${Config.appAuthUrl()}/account/login";
  static var upgrade = "${Config.appAuthUrl()}/app/check";

  /// office
  static var getUserTags = "${Config.imApiUrl()}/office/get_user_tags";
  static var createTag = "${Config.imApiUrl()}/office/create_tag";
  static var deleteTag = "${Config.imApiUrl()}/office/delete_tag";
  static var updateTag = "${Config.imApiUrl()}/office/set_tag";
  static var sendMsgToTag = "${Config.imApiUrl()}/office/send_msg_to_tag";
  static var getSendTagLog = "${Config.imApiUrl()}/office/get_send_tag_log";

  static var getRTCInvitation =
      "${Config.imApiUrl()}/third/get_rtc_invitation_info";
  static var getRTCInvitationStart =
      "${Config.imApiUrl()}/third/get_rtc_invitation_start_app";
  static final createMoments =
      "${Config.imApiUrl()}/office/create_one_work_moment";
  static final getMomentsList =
      "${Config.imApiUrl()}/office/get_user_friend_work_moments";
  static final getUserMomentsList =
      "${Config.imApiUrl()}/office/get_user_work_moments";
  static final likeMoments = "${Config.imApiUrl()}/office/like_one_work_moment";
  static final commentMoments =
      "${Config.imApiUrl()}/office/comment_one_work_moment";
  static final deleteComment = "${Config.imApiUrl()}/office/delete_comment";
  static final getMomentsDetail =
      "${Config.imApiUrl()}/office/get_work_moment_by_id";
  static final deleteMoments =
      "${Config.imApiUrl()}/office/delete_one_work_moment";
  static final getClientConfig =
      '${Config.chatTokenUrl()}/admin/init/get_client_config';
}
