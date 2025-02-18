import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/repository/login_repository/login_repository.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

import '../../utils/utils.dart';

class OTPViewModel extends GetxController {
  final _api = LoginRepository();
  final otp1Controller = TextEditingController().obs;
  final otp2Controller = TextEditingController().obs;
  final otp3Controller = TextEditingController().obs;
  final otp4Controller = TextEditingController().obs;
  UserPreference userPreference = UserPreference();
  final mobileFocusNode = FocusNode().obs;
  final passwordFocusNode = FocusNode().obs;
  RxBool loading = false.obs;

  activateUserApi(String mobile, String id) {
    loading.value = true;
    final otp1 = otp1Controller.value.text;
    final otp2 = otp2Controller.value.text;
    final otp3 = otp3Controller.value.text;
    final otp4 = otp4Controller.value.text;
    final otp = "$otp1$otp2$otp3$otp4";

    // if (otp == "1234") {
    //   Utils.snackBar("Success", "OTP Verified Successfully");
    //   Get.offAllNamed(RouteName.dashboardScreen);
    //   return;
    // }

    _api.activateUserApi({'phone': mobile, 'otp': otp}, id).then((value) {
      print(value);
      bool success = value["success"].toString() == "true";
      print("success $success");
      print("otpAuth-- $value");
      if (success == true) {
        Utils.snackBar("ActivateUser", "User Activation Successful");
        Get.toNamed(RouteName.fillYourProfileScreen,
            arguments: {'phone': mobile, 'id': id});
      }
    }).onError((error, stackTrace) {
      Utils.snackBar("Error", error.toString());
    });
  }
}
