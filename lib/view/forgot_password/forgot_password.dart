import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/res/routes/routes_name.dart';
import 'dart:convert';

import 'otp_verification_screen.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  @override
  TextEditingController _controller = TextEditingController();
  var phone;
  Future<void> forgotPassword() async {
    var headers = {'Content-Type': 'application/json'};
    var url =
        'https://pollchat.myappsdevelopment.co.in/api/v1/user/forgot-password';

    var body = json.encode({'phone': phone});

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        var responseBody = json.decode(response.body);
        print(responseBody);

        log("forgotPassword API call Success");
        Get.to(() => OTPVerificationScreen(number: _controller.text));
      } else {
        log("forgotPassword API call Not Success: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

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
                    'Forgot Password',
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
                      'Please enter your email address or mobile number to reset your password',
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
                      top: 100, left: 20, right: 20, bottom: 30),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Email / Mobile Number"),
                    onChanged: (String value) {
                      setState(() {
                        phone = value;
                        _controller.text = phone;
                      });
                    },
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
                      if (_controller.text.isNotEmpty) {
                        forgotPassword();
                      } else {
                        Get.snackbar(
                            "Failed", "Please Enter Email / Mobile Number");
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
                    child: const Text("Send link"),
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
                          onPressed: () {
                            Get.toNamed(RouteName.signupScreen);
                          },
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
