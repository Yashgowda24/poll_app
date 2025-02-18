import 'dart:async';
import 'package:get/get.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class SplashServices {
  UserPreference userPreference = UserPreference();

  void isLogin() {
    userPreference.getIsLoggedIn().then((value) => {
          if (value)
            {
              Timer(const Duration(seconds: 3), () {
                Get.toNamed(RouteName.dashboardScreen);
              })
            }
          else
            {
              Timer(const Duration(seconds: 3), () {
                Get.toNamed(RouteName.loginScreen);
              // Timer(const Duration(seconds: 3), () {
              //   Get.toNamed(RouteName.dashboardScreen);
              })
            }
        });
  }
}
