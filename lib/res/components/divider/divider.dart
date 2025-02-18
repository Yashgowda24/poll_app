import 'package:flutter/material.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class Divider extends StatelessWidget {
  const Divider({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: AppColor.greyLightColor, height: 1,);
  }
}