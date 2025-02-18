import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/res/routes/routes_name.dart';

class CreateNewPasswordView extends StatefulWidget {
  CreateNewPasswordView({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _CreateNewPasswordViewState();
}

class _CreateNewPasswordViewState extends State<CreateNewPasswordView> {
  bool showPassword = false;
  bool showConfirmPassword = false;
  TextEditingController createPassContro = TextEditingController();
  TextEditingController confirmPassContro = TextEditingController();

  Future<void> resetPassword() async {
    final arguments = Get.arguments as Map<String, dynamic>;
    final number = arguments['number'] as String;
    final otp = arguments['otp'] as String;

    log("messagemessagemessagemessagemessage inside of reset password");
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/user/reset-password'));

    request.body = json.encode({
      'phone': number,
      "otp": otp,
      "newPassword": createPassContro.text,
      "confirmPassword": confirmPassContro.text,
    });
    request.headers.addAll(headers);

    try {
      log("messagemessagemessagemessagemessage try");

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        log("messagemessagemessagemessagemessage inside of success");
        print(await response.stream.bytesToString());
        Get.snackbar("Success", "New Password Is Created");
        Get.toNamed(RouteName.loginScreen);
      } else {
        Get.snackbar("Failed", "Some Thing Went To Wrong Please Try Again");
        log("messagemessagemessagemessagemessage inside of error");
        print(await response.stream.bytesToString());
      }
    } catch (e) {
      log("messagemessagemessagemessagemessage inside of catch");
      print('An error occurred: $e');
    }
  }

  // Future<void> forgotPassword() async {
  //   var headers = {'Content-Type': 'application/json'};
  //   var request = http.Request(
  //       'POST',
  //       Uri.parse(
  //           'https://pollchat.myappsdevelopment.co.in/api/v1/user/forgot-password'));
  //
  //   request.body = json.encode({'phone': phone});
  //   request.headers.addAll(headers);
  //
  //   try {
  //     http.StreamedResponse response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //
  //       print(await response.stream.bytesToString());
  //
  //       log("forgotPassword API call Success");
  //       Get.to(() => OTPVerificationScreen(
  //         number: _controller.text,
  //       ));
  //
  //     } else {
  //       log("forgotPassword API call Not Success");
  //       print(response.reasonPhrase);
  //     }
  //   } catch (e) {
  //     print('An error occurred: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Center(
                  child: Text(
                    'Create New Password',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: AppColor.blackColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Center(
                    child: Text(
                      'Create new password, Your password must be at least six characters',
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.greyColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 100, left: 20, right: 20, bottom: 20),
                  child: TextFormField(
                    controller: createPassContro,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            icon: showPassword
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 30),
                  child: TextFormField(
                    controller: confirmPassContro,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                            icon: showConfirmPassword
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off))),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 10),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: AppColor.purpleColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 16,
                        )),
                    child: const Text(
                      "Agree to our Terms & Conditions",
                      style: TextStyle(
                          color: AppColor.purpleColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (createPassContro.text.isNotEmpty &&
                          confirmPassContro.text.isNotEmpty) {
                        if (createPassContro.text == confirmPassContro.text) {
                          resetPassword();
                        } else {
                          Get.snackbar(
                              "Failed", "Please Enter Both Password Same");
                        }
                      } else {
                        Get.snackbar("Failed", "Please Enter Password");
                      }
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColor.purpleColor,
                        minimumSize: const Size.fromHeight(50),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(
                          fontSize: 20,
                        )),
                    child: const Text("Login"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                            color: AppColor.blac2kColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: const Text("Sign up",
                              style: TextStyle(color: AppColor.purpleColor)))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
