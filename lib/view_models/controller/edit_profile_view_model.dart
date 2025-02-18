import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:poll_chat/data/app_exception.dart';
import 'package:poll_chat/data/repository/profile_repository.dart';
import 'package:poll_chat/models/user_model/user_model.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class EditProfileViewModel extends GetxController {
  final _api = ProfileRepository();
  final usernameController = TextEditingController().obs;
  final nameController = TextEditingController().obs;
  final bioController = TextEditingController().obs;
  final cityController = TextEditingController().obs;
  final emailController = TextEditingController().obs;
  final mobileController = TextEditingController().obs;
  final dobController = TextEditingController().obs;
  final interestController = TextEditingController().obs;
  final hobbiesController = TextEditingController().obs;
  Rx<String> img = ''.obs;

  UserPreference userPreference = UserPreference();
  UserModel? userModel;

  RxBool loading = false.obs;

  void addImage(String val) {
    String _img = val;
    img.value = _img;
  }

  @override
  void onInit() {
    super.onInit();
    // getUserProfileApi();
  }

  void updateProfileApi() {
    Map<String, dynamic> data = {
      'username': usernameController.value.text,
      'name': nameController.value.text,
      'bio': bioController.value.text,
      'email': emailController.value.text,
      'city': cityController.value.text,
      'country': 'India',
      'profilePhoto': img.value,
      'phone': mobileController.value.text,
      'dateOfBirth': dobController.value.text,
      'interest': interestController.value.text,
      'hobbies': hobbiesController.value.text,
    };
    loading.value = true;
    _api.updateProfileApi(data).then((value) {
      Utils.snackBar("Profile", "Profile has been updated successfully!");
      loading.value = false;
    }).onError((error, stackTrace) {
      Utils.snackBar("Error", error.toString());
      loading.value = false;
    });

    print(img);
    // _api.updateProfilePhoto({"profilePhoto": img.value}).then((value) {
    //   print(value);
    // }).onError((error, stackTrace) {
    //   Utils.snackBar("Error", error.toString());
    //   loading.value = false;
    // });
  }

  Future<void> switchBusiness() async {
    var headers = {
      'Authorization': 'Bearer ${await userPreference.getAuthToken()}'
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/user/switch/business'));

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        String message = decodedResponse['message'];
        Utils.snackBar("Success", message);
      } else {
        print('Error: ${response.reasonPhrase}');
        Utils.snackBar("Error", response.reasonPhrase ?? 'Unknown error');
      }
    } catch (e) {
      print('Exception: $e');
      Utils.snackBar("Exception", e.toString());
    }
  }

  Future<void> put_profileOnly(String imagePath) async {
    var headers = {
      'Authorization': 'Bearer ${await userPreference.getAuthToken()}'
    };
    var request = http.MultipartRequest(
        'PUT',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/user/editProfilePhoto/'));

    if (imagePath.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath('profilePhoto', imagePath));
    }
    request.headers.addAll(headers);
    try {
      final response = await request.send();

      if (response.statusCode == 201) {
        print(await response.stream.bytesToString());
      } else {
        print('Failed: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }
  }

//  Future <void> getUserProfileApi()async {
//     _api.getUserProfileApi().then((value) {
//       // print(value);
//       usernameController.value.text = value['userName'];
//       nameController.value.text = value['firstName'];
//       bioController.value.text = value['aboutme'];
//       cityController.value.text = value['city'];
//       interestController.value.text = value['interest'];
//       emailController.value.text = value['email'];
//       mobileController.value.text = value['mobile'].toString();
//       hobbiesController.value.text = value['hobbies'];
//       DateTime date = DateTime.parse(value['dateOfBirth']);
//       String dateOfBirth = DateFormat('dd/MM/yyyy').format(date);
//       dobController.value.text = dateOfBirth;
//     }).onError((error, stackTrace)  {
//       Utils.snackBar("Error", error.toString());
//       loading.value = false;
//     });
//   }
}
