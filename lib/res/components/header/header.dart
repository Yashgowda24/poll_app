import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/routes/routes_name.dart';

class Header extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.toNamed(RouteName.friendRequestScreen);
                },
                child: SvgPicture.asset(
                  IconAssets.friendRequestsIcon,
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SvgPicture.asset(
                IconAssets.pollChatTextIcon,
                width: 38,
                height: 24,
              )
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.toNamed(RouteName.pollChatNotificationsScreen);
                },
                child: SvgPicture.asset(
                  IconAssets.notificationIcon,
                  width: 34,
                  height: 34,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(RouteName.myProfileScreen);
                },
                child: SvgPicture.asset(
                  IconAssets.userIcon,
                  width: 34,
                  height: 34,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
