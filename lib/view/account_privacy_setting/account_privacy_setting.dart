import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';

class AccountPrivacySettingView extends StatefulWidget {
  const AccountPrivacySettingView({super.key});

  @override
  State<StatefulWidget> createState() => _AccountPrivacySettingView();
}

class _AccountPrivacySettingView extends State<AccountPrivacySettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColor.greyLight5Color, width: 1))),
                child: InkWell(onTap: () {
                  Get.toNamed(RouteName.changePasswordScreen);
                }, child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child:
                          SvgPicture.asset(IconAssets.businessToolsSettingIcon),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: TextStyle(
                                color: AppColor.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  ],
                ),),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColor.greyLight5Color, width: 1))),
                child: InkWell(onTap: () {
                  Get.toNamed(RouteName.privacySettingScreen);
                }, child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child:
                          SvgPicture.asset(IconAssets.shieldIcon),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Settings',
                            style: TextStyle(
                                color: AppColor.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  ],
                ),),
              ),
            )
          ],
        ),
      )),
    );
  }
}
