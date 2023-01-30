import 'package:get/get.dart';

import '../pages/add_friend/accept_friend_request/accept_friend_request_binding.dart';
import '../pages/add_friend/accept_friend_request/accept_friend_request_view.dart';
import '../pages/add_friend/add_friend_binding.dart';
import '../pages/add_friend/add_friend_view.dart';
import '../pages/add_friend/search/search_binding.dart';
import '../pages/add_friend/search/search_view.dart';
import '../pages/add_friend/send_friend_request/send_friend_request_binding.dart';
import '../pages/add_friend/send_friend_request/send_friend_request_view.dart';
import '../pages/chat/chat_binding.dart';
import '../pages/chat/chat_setup/background_image/background_image_binding.dart';
import '../pages/chat/chat_setup/background_image/background_image_view.dart';
import '../pages/chat/chat_setup/chat_setup_binding.dart';
import '../pages/chat/chat_setup/chat_setup_view.dart';
import '../pages/chat/chat_setup/create_group/create_group_binding.dart';
import '../pages/chat/chat_setup/create_group/create_group_view.dart';
import '../pages/chat/chat_setup/emoji_manage/emoji_manage_binding.dart';
import '../pages/chat/chat_setup/emoji_manage/emoji_manage_view.dart';
import '../pages/chat/chat_setup/font_size/font_size_binding.dart';
import '../pages/chat/chat_setup/font_size/font_size_view.dart';
import '../pages/chat/chat_setup/search_history_message/file/file_binding.dart';
import '../pages/chat/chat_setup/search_history_message/file/file_view.dart';
import '../pages/chat/chat_setup/search_history_message/picture/picture_binding.dart';
import '../pages/chat/chat_setup/search_history_message/picture/picture_view.dart';
import '../pages/chat/chat_setup/search_history_message/preview_message/preview_message_binding.dart';
import '../pages/chat/chat_setup/search_history_message/preview_message/preview_message_view.dart';
import '../pages/chat/chat_setup/search_history_message/search_history_message_binding.dart';
import '../pages/chat/chat_setup/search_history_message/search_history_message_view.dart';
import '../pages/chat/chat_view.dart';
import '../pages/chat/group_setup/announcement_setup/announcement_setup_binding.dart';
import '../pages/chat/group_setup/announcement_setup/announcement_setup_view.dart';
import '../pages/chat/group_setup/group_member_manager/group_member_manager_binding.dart';
import '../pages/chat/group_setup/group_member_manager/group_member_manager_view.dart';
import '../pages/chat/group_setup/group_member_manager/member_list/member_list_binding.dart';
import '../pages/chat/group_setup/group_member_manager/member_list/member_list_view.dart';
import '../pages/chat/group_setup/group_member_manager/search_member/search_member_binding.dart';
import '../pages/chat/group_setup/group_member_manager/search_member/search_member_view.dart';
import '../pages/chat/group_setup/group_member_permission/group_member_permission_binding.dart';
import '../pages/chat/group_setup/group_member_permission/group_member_permission_view.dart';
import '../pages/chat/group_setup/group_setup_binding.dart';
import '../pages/chat/group_setup/group_setup_view.dart';
import '../pages/chat/group_setup/id/id_binding.dart';
import '../pages/chat/group_setup/id/id_view.dart';
import '../pages/chat/group_setup/message_read_list/message_read_binding.dart';
import '../pages/chat/group_setup/message_read_list/message_read_view.dart';
import '../pages/chat/group_setup/my_group_nickname/my_group_nickname_binding.dart';
import '../pages/chat/group_setup/my_group_nickname/my_group_nickname_view.dart';
import '../pages/chat/group_setup/name_setup/name_setup_binding.dart';
import '../pages/chat/group_setup/name_setup/name_setup_view.dart';
import '../pages/chat/group_setup/qrcode/qrcode_binding.dart';
import '../pages/chat/group_setup/qrcode/qrcode_view.dart';
import '../pages/chat/group_setup/set_member_mute/set_member_mute_binding.dart';
import '../pages/chat/group_setup/set_member_mute/set_member_mute_view.dart';
import '../pages/contacts/add/add_binding.dart';
import '../pages/contacts/add/add_view.dart';
import '../pages/contacts/all_users/all_user_binding.dart';
import '../pages/contacts/all_users/all_user_view.dart';
import '../pages/contacts/apply_enter_group/apply_enter_group_binding.dart';
import '../pages/contacts/apply_enter_group/apply_enter_group_view.dart';
import '../pages/contacts/friend_info/friend_info_binding.dart';
import '../pages/contacts/friend_info/friend_info_view.dart';
import '../pages/contacts/friend_info/id_code/id_code_binding.dart';
import '../pages/contacts/friend_info/id_code/id_code_view.dart';
import '../pages/contacts/friend_info/remark/remark_binding.dart';
import '../pages/contacts/friend_info/remark/remark_view.dart';
import '../pages/contacts/friend_list/friend_list_binding.dart';
import '../pages/contacts/friend_list/friend_list_view.dart';
import '../pages/contacts/friend_list/search_friend/search_friend_binding.dart';
import '../pages/contacts/friend_list/search_friend/search_friend_view.dart';
import '../pages/contacts/group_application/group_application_binding.dart';
import '../pages/contacts/group_application/group_application_view.dart';
import '../pages/contacts/group_application/handle_application/handle_application_binding.dart';
import '../pages/contacts/group_application/handle_application/handle_application_view.dart';
import '../pages/contacts/group_list/group_list_binding.dart';
import '../pages/contacts/group_list/group_list_view.dart';
import '../pages/contacts/group_list/search_group/search_group_binding.dart';
import '../pages/contacts/group_list/search_group/search_group_view.dart';
import '../pages/contacts/join_group/join_group_binding.dart';
import '../pages/contacts/join_group/join_group_view.dart';
import '../pages/contacts/new_friend/new_friend_binding.dart';
import '../pages/contacts/new_friend/new_friend_view.dart';
import '../pages/contacts/search_add_group/search_add_group_binding.dart';
import '../pages/contacts/search_add_group/search_add_group_view.dart';
import '../pages/contacts/tag_group/new/new_tag_group_binding.dart';
import '../pages/contacts/tag_group/new/new_tag_group_view.dart';
import '../pages/contacts/tag_group/tag_group_binding.dart';
import '../pages/contacts/tag_group/tag_group_view.dart';
import '../pages/forget_password/forget_password_binding.dart';
import '../pages/forget_password/forget_password_view.dart';
import '../pages/global_search/chat_history/chat_history_binding.dart';
import '../pages/global_search/chat_history/chat_history_view.dart';
import '../pages/global_search/global_search_binding.dart';
import '../pages/global_search/global_search_view.dart';
import '../pages/home/home_binding.dart';
import '../pages/home/home_view.dart';
import '../pages/login/login_binding.dart';
import '../pages/login/login_view.dart';
import '../pages/login_pc/login_pc_binding.dart';
import '../pages/login_pc/login_pc_view.dart';
import '../pages/mine/about_us/about_us_binding.dart';
import '../pages/mine/about_us/about_us_view.dart';
import '../pages/mine/account_setup/account_setup_binding.dart';
import '../pages/mine/account_setup/account_setup_view.dart';
import '../pages/mine/account_setup/unlock_verification/unlock_verification_binding.dart';
import '../pages/mine/account_setup/unlock_verification/unlock_verification_view.dart';
import '../pages/mine/add_my_method/add_my_method_binding.dart';
import '../pages/mine/add_my_method/add_my_method_view.dart';
import '../pages/mine/blacklist/blacklist_binding.dart';
import '../pages/mine/blacklist/blacklist_view.dart';
import '../pages/mine/my_id/my_id_binding.dart';
import '../pages/mine/my_id/my_id_view.dart';
import '../pages/mine/my_info/my_info_binding.dart';
import '../pages/mine/my_info/my_info_view.dart';
import '../pages/mine/my_qrcode/my_qrcode_binding.dart';
import '../pages/mine/my_qrcode/my_qrcode_view.dart';
import '../pages/mine/setup_language/setup_language_binding.dart';
import '../pages/mine/setup_language/setup_language_view.dart';
import '../pages/mine/setup_username/setup_name_binding.dart';
import '../pages/mine/setup_username/setup_name_view.dart';
import '../pages/notification/oa_notification/oa_notification_binding.dart';
import '../pages/notification/oa_notification/oa_notification_view.dart';
import '../pages/organization/organization_binding.dart';
import '../pages/organization/organization_view.dart';
import '../pages/organization/search/search_binding.dart';
import '../pages/organization/search/search_view.dart';
import '../pages/register/register_binding.dart';
import '../pages/register/register_view.dart';
import '../pages/register/setupinfo/setupinfo_binding.dart';
import '../pages/register/setupinfo/setupinfo_view.dart';
import '../pages/register/setuppwd/setuppwd_binding.dart';
import '../pages/register/setuppwd/setuppwd_view.dart';
import '../pages/register/verifyphone/verifyphone_binding.dart';
import '../pages/register/verifyphone/verifyphone_view.dart';
import '../pages/select_contacts/search/search_binding.dart';
import '../pages/select_contacts/search/search_view.dart';
import '../pages/select_contacts/select_contacts_binding.dart';
import '../pages/select_contacts/select_contacts_view.dart';
import '../pages/splash/splash_binding.dart';
import '../pages/splash/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  /// 左滑关闭页面用于android
  static _pageBuilder({
    required String name,
    required GetPageBuilder page,
    Bindings? binding,
  }) =>
      GetPage(
        name: name,
        page: page,
        binding: binding,
        transition: Transition.cupertino,
        popGesture: true,
      );

  static final routes = <GetPage>[
    _pageBuilder(
      name: AppRoutes.SPLASH,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.REGISTER,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.REGISTER_VERIFY_PHONE,
      page: () => VerifyPhonePage(),
      binding: VerifyPhoneBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SETUP_PWD,
      page: () => SetupPwdPage(),
      binding: SetupPwdBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.REGISTER_SETUP_SELF_INFO,
      page: () => SetupSelfInfoPage(),
      binding: SetupSelfInfoBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    // _pageBuilder(
    //   name: AppRoutes.CONVERSATION,
    //   page: () => ConversationPage(),
    //   binding: ConversationBinding(),
    // ),
    _pageBuilder(
      name: AppRoutes.CHAT,
      page: () => ChatPage(),
      binding: ChatBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.CHAT_SETUP,
      page: () => ChatSetupPage(),
      binding: ChatSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SELECT_CONTACTS,
      page: () => SelectContactsPage(),
      binding: SelectContactsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ADD_CONTACTS,
      page: () => AddContactsPage(),
      binding: AddContactsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.NEW_FRIEND_APPLICATION,
      page: () => NewFriendPage(),
      binding: NewFriendBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.FRIEND_LIST,
      page: () => MyFriendListPage(),
      binding: MyFriendListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.FRIEND_INFO,
      page: () => FriendInfoPage(),
      binding: FriendInfoBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.FRIEND_ID_CODE,
      page: () => FriendIdCodePage(),
      binding: FriendIdCodeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.FRIEND_REMARK,
      page: () => FriendRemarkPage(),
      binding: FriendRemarkBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ADD_FRIEND,
      page: () => AddFriendPage(),
      binding: AddFriendBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ADD_FRIEND_BY_SEARCH,
      page: () => AddFriendBySearchPage(),
      binding: AddFriendBySearchBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEND_FRIEND_REQUEST,
      page: () => SendFriendRequestPage(),
      binding: SendFriendRequestBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ACCEPT_FRIEND_REQUEST,
      page: () => AcceptFriendRequestPage(),
      binding: AcceptFriendRequestBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.MY_QRCODE,
      page: () => MyQrcodePage(),
      binding: MyQrcodeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.MY_INFO,
      page: () => MyInfoPage(),
      binding: MyInfoBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SETUP_USER_NAME,
      page: () => SetupUserNamePage(),
      binding: SetupUserNameBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.MY_ID,
      page: () => MyIDPage(),
      binding: MyIDBinding(),
    ),
    // _pageBuilder(
    //   name: AppRoutes.CALL,
    //   page: () => CallPage(),
    //   binding: CallBinding(),
    // ),
    _pageBuilder(
      name: AppRoutes.CREATE_GROUP_IN_CHAT_SETUP,
      page: () => CreateGroupInChatSetupPage(),
      binding: CreateGroupInChatSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_SETUP,
      page: () => GroupSetupPage(),
      binding: GroupSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_NAME_SETUP,
      page: () => GroupNameSetupPage(),
      binding: GroupNameSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_ANNOUNCEMENT_SETUP,
      page: () => GroupAnnouncementSetupPage(),
      binding: GroupAnnouncementSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_QRCODE,
      page: () => GroupQrcodePage(),
      binding: GroupQrcodeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_ID,
      page: () => GroupIDPage(),
      binding: GroupIDBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.MY_GROUP_NICKNAME,
      page: () => MyGroupNicknamePage(),
      binding: MyGroupNicknameBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_MEMBER_MANAGER,
      page: () => GroupMemberManagerPage(),
      binding: GroupMemberManagerBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_MEMBER_LIST,
      page: () => GroupMemberListPage(),
      binding: GroupMemberListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_LIST,
      page: () => GroupListPage(),
      binding: GroupListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.JOIN_GROUP,
      page: () => JoinGroupPage(),
      binding: JoinGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ACCOUNT_SETUP,
      page: () => AccountSetupPage(),
      binding: AccountSetupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ADD_MY_METHOD,
      page: () => AddMyMethodPage(),
      binding: AddMyMethodBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.BLACKLIST,
      page: () => BlacklistPage(),
      binding: BlacklistBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ABOUT_US,
      page: () => AboutUsPage(),
      binding: AboutUsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_FRIEND,
      page: () => SearchFriendPage(),
      binding: SearchFriendBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_GROUP,
      page: () => SearchGroupPage(),
      binding: SearchGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_MEMBER,
      page: () => SearchMemberPage(),
      binding: SearchMemberBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.LANGUAGE_SETUP,
      page: () => SetupLanguagePage(),
      binding: SetupLanguageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_ADD_GROUP,
      page: () => SearchAddGroupPage(),
      binding: SearchAddGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.APPLY_ENTER_GROUP,
      page: () => ApplyEnterGroupPage(),
      binding: ApplyEnterGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_APPLICATION,
      page: () => GroupApplicationPage(),
      binding: GroupApplicationBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.HANDLE_GROUP_APPLICATION,
      page: () => HandleGroupApplicationPage(),
      binding: HandleGroupApplicationBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ORGANIZATION,
      page: () => OrganizationPage(),
      binding: OrganizationBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.FORGET_PASSWORD,
      page: () => ForgetPasswordPage(),
      binding: ForgetPasswordBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.EMOJI_MANAGE,
      page: () => EmojiManagePage(),
      binding: EmojiManageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.FONT_SIZE,
      page: () => FontSizePage(),
      binding: FontSizeBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.TAG,
      page: () => TagGroupPage(),
      binding: TagGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.TAG_NEW,
      page: () => NewTagGroupPage(),
      binding: NewTagGroupBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.ALL_USERS,
      page: () => AllUsersPage(),
      binding: AllUsersBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_HAVE_READ,
      page: () => GroupMessageReadListPage(),
      binding: GroupMessageReadListBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_HISTORY_MESSAGE,
      page: () => SearchHistoryMessagePage(),
      binding: SearchHistoryMessageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_FILE,
      page: () => SearchFilePage(),
      binding: SearchFileBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_PICTURE,
      page: () => SearchPicturePage(),
      binding: SearchPictureBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SET_MEMBER_MUTE,
      page: () => SetMemberMutePage(),
      binding: SetMemberMuteBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.OA_NOTIFICATION_LIST,
      page: () => OANotificationPage(),
      binding: OANotificationBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SET_BACKGROUND_IMAGE,
      page: () => BackgroundImagePage(),
      binding: BackgroundImageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.LOGIN_PC,
      page: () => LoginPcPage(),
      binding: LoginPcBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GLOBAL_SEARCH,
      page: () => GlobalSearchPage(),
      binding: GlobalSearchBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GLOBAL_SEARCH_CHAT_HISTORY,
      page: () => ChatHistoryPage(),
      binding: ChatHistoryBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.PREVIEW_CHAT_HISTORY,
      page: () => PreviewMessagePage(),
      binding: PreviewMessageBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_ORGANIZATION,
      page: () => SearchOrganizationPage(),
      binding: SearchOrganizationBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.SEARCH_SELECT_CONTACTS,
      page: () => SearchSelectContactsPage(),
      binding: SearchSelectContactsBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.GROUP_MEMBER_PERMISSION,
      page: () => GroupMemberPermissionPage(),
      binding: GroupMemberPermissionBinding(),
    ),
    _pageBuilder(
      name: AppRoutes.UNLOCK_VERIFICATION,
      page: () => UnlockVerificationPage(),
      binding: UnlockVerificationBinding(),
    ),
  ];
}
