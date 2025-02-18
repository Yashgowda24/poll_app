import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class Moments extends StatelessWidget {
  const Moments({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 36,
      decoration: const BoxDecoration(
          color: AppColor.purpleColor,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Moments',
              style: TextStyle(
                  color: AppColor.whiteColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              width: 10,
            ),
            SvgPicture.asset(
              IconAssets.glareIcon,
              width: 38,
              height: 24,
            )
          ],
        ),
      ),
    );
  }
}
