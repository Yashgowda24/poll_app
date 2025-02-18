import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/repository/login_repository/login_repository.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';

class FillYourProfileViewModel extends GetxController {
  final _api = LoginRepository();
  final yourNameController = TextEditingController().obs;
  final usernameController = TextEditingController().obs;
  final yourBioController = TextEditingController().obs;
  final genderController = TextEditingController(text: "Male").obs; // Default value
  final cityController = TextEditingController().obs;
  final mobileFocusNode = FocusNode().obs;
  final passwordFocusNode = FocusNode().obs;

  Rx<String> img = ''.obs;
  RxBool loading = false.obs;
  
  void addImage(String val) {
    String _img = val;
    img.value = _img;
  }

  Future<void> createProfileApi(String mobile, String id) async {
    loading.value = true;

    Map<String, dynamic> data = {
      'name': yourNameController.value.text,
      'username': usernameController.value.text,
      'city': cityController.value.text,
      'bio': yourBioController.value.text,
      'profilePhoto': img.value,
      'gender': genderController.value.text.toLowerCase(), // Convert to lowercase
    };

    _api.createProfileApi(data, id).then((value) {
      print("value-- $value");
      if (true) {
        Utils.snackBar("Profile", "Profile Created Successfully");
        loading.value = false;
        Get.toNamed(RouteName.congratulationsScreen);
      }
    }).onError((error, stackTrace) {
      Utils.snackBar("Error", error.toString());
      loading.value = false;
    });
  }
}
