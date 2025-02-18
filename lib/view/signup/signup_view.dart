import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/signup_view_model.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<StatefulWidget> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  bool showPassword = false;
  bool showConfirmPassword = false;

  final signupViewModel = Get.put(SignupViewModel());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final SignupViewModel appController = Get.find();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // automaticallyImplyLeading: false,
        // title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Text(
                'Sign up with Mobile',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: AppColor.blackColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Chat with your Friends & Family by signing up with Pollchat!',
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
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 100, left: 20, right: 20, bottom: 30),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: signupViewModel.mobileController.value,
                        focusNode: signupViewModel.mobileFocusNode.value,
                        validator: (value) {
                          if (value!.isEmpty) {
                            Utils.snackBar("Mobile", "Enter mobile");
                            return "";
                          } else if (!GetUtils.isPhoneNumber(value)) {
                            Utils.snackBar(
                                "Mobile", "Enter valid mobile number");
                            return "";
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          setState(() {
                            signupViewModel.mobileController.value.text = value;
                            Utils.fieldFocusChange(
                                context,
                                signupViewModel.mobileFocusNode.value,
                                signupViewModel.passwordFocusNode.value);
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: "Mobile Number"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 20, right: 20, bottom: 30),
                      child: TextFormField(
                        controller: signupViewModel.passwordController.value,
                        focusNode: signupViewModel.passwordFocusNode.value,
                        validator: (value) {
                          if (value!.isEmpty) {
                            Utils.snackBar("Password", "Enter password");
                            return "";
                          }
                          return null;
                        },
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
                        controller:
                            signupViewModel.confirm_passwordController.value,
                        focusNode:
                            signupViewModel.confirm_passwordFocusNode.value,
                        validator: (value) {
                          if (value!.isEmpty) {
                            Utils.snackBar(
                                "Confirm Password", "Enter confirm password");
                            return "";
                          }
                          return null;
                        },
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, left: 20, right: 20, bottom: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signupViewModel.signupApi();
                          }
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColor.purpleColor,
                            minimumSize: const Size.fromHeight(50),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            textStyle: const TextStyle(
                              fontSize: 20,
                            )),
                        child: const Text("Get OTP"),
                      ),
                    )
                  ],
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        // Get.to(const SignInPage());
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 5)),
                      child: const Text("Log In",
                          style: TextStyle(
                              color: AppColor.purpleColor,
                              fontWeight: FontWeight.w600)))
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text("By creating an account, you agree to our"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 2)),
                    onPressed: () {
                      appController.open(
                          "https://pollchat.co/terms-of-use/");
                    },
                    child: const Text(
                      "Terms & Conditions",
                      style: TextStyle(color: AppColor.purpleColor),
                    )),
                const Text("and agree to"),
                TextButton(
                    style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding:
                            const EdgeInsets.symmetric(vertical: 0, horizontal: 2)),
                    onPressed: () {
                      appController.open(
                          "https://pollchat.co/privacy-policy/");
                    },
                    child: const Text("Privacy Policy",
                        style: TextStyle(color: AppColor.purpleColor)))
              ],
            )
          ],
        ),
      ),
    );
  }
}
