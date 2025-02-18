import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/assets/image_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class BusinessToolsSettingView extends StatefulWidget {
  const BusinessToolsSettingView({super.key});

  @override
  State<StatefulWidget> createState() => _BusinessToolsSettingView();
}

class _BusinessToolsSettingView extends State<BusinessToolsSettingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Tools"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Insights',
                style: TextStyle(
                    color: AppColor.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: AppColor.purpleColor),
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Row(
                        children: [
                          const Text(
                            'Last 7 days',
                            style: TextStyle(
                                color: AppColor.purpleColor, fontSize: 12),
                          ),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child:
                                SvgPicture.asset(IconAssets.chevronRightIcon),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    '22 Jun - 29 Jun',
                    style: TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 1,
                color: AppColor.greyLight3Color,
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text('Insights Overview',
                  style: TextStyle(
                      fontSize: 20,
                      color: AppColor.blackColor,
                      fontWeight: FontWeight.w500)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                    'View Insights regularly to understand and optimize your content’s performance',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.greyLight2Color,
                    )),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accounts reached',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Text(
                        '48',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColor.blackColor,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '(16%)',
                        style:
                            TextStyle(fontSize: 12, color: AppColor.blackColor),
                      )
                    ],
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accounts engaged',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Text(
                        '34',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColor.blackColor,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '(14%)',
                        style:
                            TextStyle(fontSize: 12, color: AppColor.blackColor),
                      )
                    ],
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Audience',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Text(
                        '81',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColor.blackColor,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '(42%)',
                        style:
                            TextStyle(fontSize: 12, color: AppColor.blackColor),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 1,
                color: AppColor.greyLight3Color,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Shared Content',
                style: TextStyle(
                    color: AppColor.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                height: 108,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Card(
                      surfaceTintColor: AppColor.whiteColor,
                      elevation: 2,
                      child: Image.asset(
                        ImageAssets.sharedContentPlaceholder,
                        // width: 108,
                        height: 110,
                      ),
                    ),
                    Card(
                      elevation: 2,
                      surfaceTintColor: AppColor.whiteColor,
                      child: Image.asset(
                        ImageAssets.sharedContentPlaceholder,
                        // width: 108,
                        height: 104,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
