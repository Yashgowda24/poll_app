import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class MessageChip extends StatelessWidget {
  const MessageChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 28,
      decoration: const BoxDecoration(
          color: AppColor.purpleColor,
          borderRadius: BorderRadius.all(Radius.circular(25))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          children: [
            SvgPicture.asset(
              IconAssets.messageIcon,
              width: 30,
              height: 24,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Message',
              style: TextStyle(
                  color: AppColor.whiteColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
