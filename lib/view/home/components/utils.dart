import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';

showHomeModal() {
  return Get.bottomSheet(
    Container(
        height: 150,
        decoration: const BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 60,
              height: 4,
              decoration: const BoxDecoration(
                  color: AppColor.blackColor,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: SvgPicture.asset(IconAssets.pinPollIcon),
                      ),
                      const Text(
                        "Pin Poll",
                        style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: SvgPicture.asset(IconAssets.supportIcon),
                      ),
                      const Text(
                        "Support",
                        style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: SvgPicture.asset(IconAssets.hideIcon),
                      ),
                      const Text(
                        "Hide",
                        style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        )),
    barrierColor: AppColor.modalBackdropColor,
    isDismissible: true,
    enableDrag: false,
  );
}

