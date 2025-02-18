import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view_models/controller/otp_view_model.dart';


class OTPVerificationScreen extends StatefulWidget {
  final String number;

  const OTPVerificationScreen({super.key, required this.number});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final otpViewModel = Get.put(OTPViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Enter the OTP",
                  style: TextStyle(
                      color: AppColor.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                  child: Text(
                    "Enter the OTP that we have sent on your Mobile which you enter.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColor.greyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < 4; i++)
                      Container(
                        width: 70,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColor.pinkColor,
                        ),
                        child: TextFormField(
                          controller: i == 0
                              ? otpViewModel.otp1Controller.value
                              : i == 1
                                  ? otpViewModel.otp2Controller.value
                                  : i == 2
                                      ? otpViewModel.otp3Controller.value
                                      : otpViewModel.otp4Controller.value,
                          onChanged: (value) {
                            if (value.length == 1 && i < 3) {
                              FocusScope.of(context).nextFocus();
                            }
                            setState(() {});
                          },
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        forgotPassword();
                      },
                      child: const Text(
                        "Didn’t receive any code? ",
                        style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // if (_timerDuration == 0)
                    //   InkWell(
                    //     onTap: () {
                    //       resetTimer(); // Restart the timer
                    //       // Add logic to resend OTP
                    //     },
                    //     child: const Text(
                    //       "Resend",
                    //       style: TextStyle(
                    //         color: AppColor.purpleColor,
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w700,
                    //       ),
                    //     ),
                    //   )
                    // else
                    //   Text(
                    //     "Resend in ${formatDuration(_timerDuration)}",
                    //     style: const TextStyle(
                    //       color: AppColor.purpleColor,
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.w700,
                    //     ),
                    //   ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    String otp =
                        "${otpViewModel.otp1Controller.value.text}${otpViewModel.otp2Controller.value.text}${otpViewModel.otp3Controller.value.text}${otpViewModel.otp4Controller.value.text}";
                    Get.toNamed(
                      RouteName.createNewPasswordScreen,
                      arguments: {
                        'number': widget.number.toString(),
                        'otp': otp,
                      },
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 90,
                    decoration: BoxDecoration(
                      color: AppColor.purpleColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          color: AppColor.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> forgotPassword() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/user/forgot-password'));

    request.body = json.encode({'phone': widget.number});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        log("forgotPassword API call Success");
        Get.snackbar("Success", "We Send New OTP on Your Mobile/Email");
      } else {
        log("forgotPassword API call Not Success");
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }
}
