// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/repository/login_repository/login_repository.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupViewModel extends GetxController {
  final _api = LoginRepository();
  final mobileController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final confirm_passwordController = TextEditingController().obs;

  final mobileFocusNode = FocusNode().obs;
  final passwordFocusNode = FocusNode().obs;
  final confirm_passwordFocusNode = FocusNode().obs;
  UserPreference userPreference = UserPreference();
  RxBool loading = false.obs;
  Future<bool> open(String url) async {
    try {
      await launch(
        url,
        enableJavaScript: true,
      );
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  toast() {
    Fluttertoast.showToast(
        msg: "Password Doesn't Match. Please Enter Password Correctly.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void signupApi() {
    loading.value = true;
    Map<String, dynamic> data = {
      'phone': mobileController.value.text,
      'password': passwordController.value.text,
      'confirmPassword': confirm_passwordController.value.text,
    };
    if (kDebugMode) {
      print(data);
      print(data.values);
    }
    _api.signupApi({
      'phone': int.parse(mobileController.value.text.trim()),
      'password': passwordController.value.text,
      'confirmPassword': confirm_passwordController.value.text,
    }).then((value) {
      print("Debugging in signupp view model starts:");
      print("Full API Response: $value");
      print("User Data: ${value["user"]}");
      print("User ID (_id): ${value["user"]["_id"]}");
      print("Message: ${value["message"]}");
      print("hello--$value");
      print("${value["user"]}");
      print(value["message"]);

      if (!value['success']) {
        Utils.snackBar("error", value['message']);
        return;
      }
      // loading.value = false;
      userPreference.setUsername(mobileController.value.text);
      if (passwordController.value.text ==
          confirm_passwordController.value.text) {
        Get.toNamed(RouteName.otpScreen, arguments: {
          'phone': mobileController.value.text.toString(),
          'id': value['user']['_id'],
        });
      } else {
        toast();
      }
    }).onError((error, stackTrace) {
      Utils.snackBar("Error", error.toString());
      loading.value = false;
    });
  }
}
