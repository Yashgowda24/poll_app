import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/image_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class CongratulationsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CongratulationsViewState();
}

class _CongratulationsViewState extends State<CongratulationsView> {
  UserPreference userPreference = UserPreference();
  @override
  initState() {
    Future.delayed(const Duration(seconds: 3), () {
      // print("ID-- ");

      userPreference.setLoggedIn(true);
      Get.offAllNamed(RouteName.dashboardScreen);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.whiteColor,
      child: Center(
        child: Image.asset(
          ImageAssets.congratulationsImage,
          width: 328,
          height: 381,
        ),
      ),
    );
  }
}
