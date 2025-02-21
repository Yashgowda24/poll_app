import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view_models/controller/otp_view_model.dart';

class OTPView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OTPViewState();
}

class _OTPViewState extends State<OTPView> {
  final otpViewModel = Get.put(OTPViewModel());
  final _formKey = GlobalKey<FormState>();
  int _timerDuration = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (_timerDuration == 0) {
            timer.cancel();
          } else {
            _timerDuration--;
          }
        });
      },
    );
  }

  String formatDuration(int duration) {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void resetTimer() {
    setState(() {
      _timerDuration = 60;
    });
    startTimer();
  }

  bool isOtpFilled() {
    return otpViewModel.otp1Controller.value.text.isNotEmpty &&
        otpViewModel.otp2Controller.value.text.isNotEmpty &&
        otpViewModel.otp3Controller.value.text.isNotEmpty &&
        otpViewModel.otp4Controller.value.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Flexible(
                flex: 8,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                        child: Text(
                          "Enter the OTP that we have sent on your Mobile to create PollChat account",
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
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          const Text(
                            "Didn’t receive any code? ",
                            style: TextStyle(
                              color: AppColor.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_timerDuration == 0)
                            InkWell(
                              onTap: () {
                                resetTimer(); // Restart the timer
                                // Add logic to resend OTP
                              },
                              child: const Text(
                                "Resend",
                                style: TextStyle(
                                  color: AppColor.purpleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            Text(
                              "Resend in ${formatDuration(_timerDuration)}",
                              style: const TextStyle(
                                color: AppColor.purpleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IgnorePointer(
                    ignoring: !isOtpFilled(),
                    child: InkWell(
                      onTap: () {
                        // Debugging output
                        print("Get.arguments: ${Get.arguments}");
                        print("Phone: ${Get.arguments['phone']}");
                        print("ID: ${Get.arguments['id']}");
                        otpViewModel.activateUserApi(
                            Get.arguments['phone'], Get.arguments['id']);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 90,
                        decoration: BoxDecoration(
                          color: isOtpFilled()
                              ? AppColor.purpleColor
                              : AppColor.greyColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
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
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
