import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class Utils {

  static void fieldFocusChange(BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: AppColor.blackColor, gravity: ToastGravity.BOTTOM);
  }

  static snackBar(String title, String message) {
    Get.snackbar(title, message);
  }
}