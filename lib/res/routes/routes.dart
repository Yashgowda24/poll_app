import 'package:get/get.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/account_privacy_setting/account_privacy_setting.dart';
import 'package:poll_chat/view/action_view/components/useractions.dart';
import 'package:poll_chat/view/action_view/components/userprofile.dart';
import 'package:poll_chat/view/action_view/storycreate/createstory.dart';
import 'package:poll_chat/view/add_video/music.dart';
import 'package:poll_chat/view/business_tools_setting/business_tools_setting.dart';
import 'package:poll_chat/view/change_password/change_password.dart';
import 'package:poll_chat/view/chat_view/chat_view.dart';
import 'package:poll_chat/view/chat_view/chateuserprofile.dart';
import 'package:poll_chat/view/chat_view/chatpage.dart';
import 'package:poll_chat/view/chat_view/groupchats/chatmainpage.dart';
import 'package:poll_chat/view/chat_view/groupchats/groupchat.dart';
import 'package:poll_chat/view/chat_view/newfriends.dart';
import 'package:poll_chat/view/congratulations/congratulations.dart';
import 'package:poll_chat/view/create_new_password/create_new_password.dart';
import 'package:poll_chat/view/create_poll/create_poll.dart';
import 'package:poll_chat/view/dashboard/dashboard.dart';
import 'package:poll_chat/view/edit_caption/edit_caption.dart';
import 'package:poll_chat/view/edit_profile/edit_profile.dart';
import 'package:poll_chat/view/fill_your_profile/fill_your_profile.dart';
import 'package:poll_chat/view/find_view/usersview.dart';
import 'package:poll_chat/view/forgot_password/forgot_password.dart';
import 'package:poll_chat/view/friend_request/friend_request_view.dart';
import 'package:poll_chat/view/home/components/pinned_poll_screen.dart';
import 'package:poll_chat/view/login/login_view.dart';
import 'package:poll_chat/view/my_profile/my_profile.dart';
import 'package:poll_chat/view/notification_setting/notification_setting.dart';
import 'package:poll_chat/view/otp/otp_view.dart';
import 'package:poll_chat/view/poll_chat_notifications/poll_chat_notifications.dart';
import 'package:poll_chat/view/privacy_setting/privacy_setting.dart';
import 'package:poll_chat/view/settings/settings.dart';
import 'package:poll_chat/view/signup/signup_view.dart';
import 'package:poll_chat/view/splash_screen.dart';

import '../../view/action_view/components/createPost.dart';

class AppRoutes {
  static appRoutes() => [
        GetPage(
            name: RouteName.splashScreen,
            page: () => SplashScreen(),
            // transitionDuration: const Duration(seconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.loginScreen,
            page: () => const LoginView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.signupScreen,
            page: () => const SignupView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.forgotPasswordScreen,
            page: () => const ForgotPasswordView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.dashboardScreen,
            page: () => DashboardView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.chatview,
            page: () => ChatView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.createPollScreen,
            page: () => const CreatePollView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.gpage,
            page: () => GroupChatPage(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.myProfileScreen,
            page: () => const MyProfileView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.settingsScreen,
            page: () => const SettingsView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.choosepage,
            page: () => const GroupfriendScreen(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.gropchatscreen,
            page: () => GroupChatScreen(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.accountAndPrivacyScreen,
            page: () => const AccountPrivacySettingView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.pinnedpolls,
            page: () => const PinnedPollScreen(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.changePasswordScreen,
            page: () => const ChangePasswordView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.businessToolsSettingScreen,
            page: () => const BusinessToolsSettingView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.privacySettingScreen,
            page: () => const PrivacySettingView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.notificationsScreen,
            page: () => const NotificationSetting(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.pollChatNotificationsScreen,
            page: () => const PollChatNotificationsView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.editProfileScreen,
            page: () => const EditProfileView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.editCaptionScreen,
            page: () => EditCaptionView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.otpScreen,
            page: () => OTPView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.fillYourProfileScreen,
            page: () => FillYourProfileView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.congratulationsScreen,
            page: () => CongratulationsView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.createNewPasswordScreen,
            page: () => CreateNewPasswordView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.friendRequestScreen,
            page: () => const FriendRequestView(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.musicScreen,
            page: () => MusicScreen(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.camera,
            page: () => CameraPreviewWidget(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.createstory,
            page: () => CreateStoryScreen(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.chatpage,
            page: () => ChatPage(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.userprofileview,
            page: () => UserProfile(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.chatuserProfile,
            page: () => ChateUserProfile(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.usersearchprofileview,
            page: () => UserSearchProfile(),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RouteName.useraction,
            page: () => UserActions(),
            transition: Transition.leftToRightWithFade),
      ];
}
