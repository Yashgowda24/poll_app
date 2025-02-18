// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/repository/login_repository/login_repository.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class LoginViewModel extends GetxController {
  final _api = LoginRepository();
  final mobileController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  UserPreference userPreference = UserPreference();

  final mobileFocusNode = FocusNode().obs;
  final passwordFocusNode = FocusNode().obs;

  RxBool loading = false.obs;

  void loginApi() async {
    loading.value = true;
    print("1");
    _api.postloginApi({
      'phone': mobileController.value.text,
      'password': passwordController.value.text
    }).then((value) {
      print(value["message"]);

      if (!value['success']) {
        Utils.snackBar("error", value['message']);
        return;
      }
      userPreference.setAuthToken(value['token']);
      userPreference.setUserID(value["user"]['id'].toString());
      print("id: ${value["user"]["id"].toString()}");
      userPreference.setUsername(mobileController.value.text);
      print("2");
      userPreference.setLoggedIn(true);
      print("3");
      Utils.snackBar("Login", "WelCome Back");
      print("4");
      loading.value = false;
      Get.offAndToNamed(RouteName.dashboardScreen);
    }).onError((error, stackTrace) {
      Utils.snackBar("Error", error.toString());
      print(error);
      print(stackTrace);
      // loading.value = false;
    });
  }
}
