import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<StatefulWidget> createState() => _MyProfileState();
}

class _MyProfileState extends State<SettingsView> {
  UserPreference userPreference = UserPreference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColor.greyLight5Color, width: 1))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteName.accountAndPrivacyScreen);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: SvgPicture.asset(
                              IconAssets.businessToolsSettingIcon),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Privacy, Security, Change password',
                                  style: TextStyle(
                                      color: AppColor.greyColor, fontSize: 12))
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColor.greyLight5Color, width: 1))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: InkWell(
                  onTap: () {
                    Get.toNamed(RouteName.businessToolsSettingScreen);
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: SvgPicture.asset(
                            IconAssets.businessToolsSettingIcon),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Tools',
                              style: TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text('Insights, Impressions, Engagement',
                                style: TextStyle(
                                    color: AppColor.greyColor, fontSize: 12))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColor.greyLight5Color, width: 1))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: InkWell(
                  onTap: () {
                    Get.toNamed(RouteName.notificationsScreen);
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: SvgPicture.asset(IconAssets.notificationsIcon),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text('Push Notifications',
                                style: TextStyle(
                                    color: AppColor.greyColor, fontSize: 12))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColor.greyLight5Color, width: 1))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: InkWell(
                  onTap: () async {
                    await userPreference.resetLoggedIn().then((value) {
                      if (value) {
                        Get.offAllNamed(RouteName.loginScreen);
                      } else {
                        print('Logout failed');
                      }
                    }).catchError((error) {
                      print('Error during logout: $error');
                    });
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: SvgPicture.asset(IconAssets.logoutIcon),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log out',
                              style: TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            // Text('Log out john kevin',
                            //     style: TextStyle(
                            //         color: AppColor.greyColor, fontSize: 12))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
