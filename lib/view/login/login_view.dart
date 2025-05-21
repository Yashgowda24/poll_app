// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:poll_chat/res/colors/app_color.dart';
// import 'package:poll_chat/res/routes/routes_name.dart';
// import 'package:poll_chat/utils/utils.dart';
// import 'package:poll_chat/view_models/controller/login_view_model.dart';

// class LoginView extends StatefulWidget {
//   const LoginView({super.key});

//   @override
//   State<StatefulWidget> createState() => _LoginViewState();
// }

// class _LoginViewState extends State<LoginView> {
//   bool showPassword = false;
//   final loginViewModel = Get.put(LoginViewModel());
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         // title: const Text('Login'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const Center(
//               child: Text(
//                 'Log in to Pollchat',
//                 textDirection: TextDirection.ltr,
//                 style: TextStyle(
//                   color: AppColor.blackColor,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//               child: Center(
//                 child: Text(
//                   'Welcome back! Sign in using your Mobile Number & Password',
//                   textDirection: TextDirection.ltr,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: AppColor.greyColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//               ),
//             ),
//             Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 100, left: 20, right: 20, bottom: 30),
//                       child: TextFormField(
//                         keyboardType: TextInputType.number,
//                         controller: loginViewModel.mobileController.value,
//                         focusNode: loginViewModel.mobileFocusNode.value,
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                            Utils.snackBar("Mobile", "Enter Mobile");
//                            return "";
//                           }
//                           return null;
//                         },
//                         onFieldSubmitted: (value) {
//                           Utils.fieldFocusChange(
//                               context,
//                               loginViewModel.mobileFocusNode.value,
//                               loginViewModel.passwordFocusNode.value);
//                         },
//                         decoration:
//                             const InputDecoration(labelText: "Mobile Number"),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 10, left: 20, right: 20, bottom: 0),
//                       child: TextFormField(
//                         obscureText: !showPassword,
//                         controller: loginViewModel.passwordController.value,
//                         focusNode: loginViewModel.passwordFocusNode.value,
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                            Utils.snackBar("Password", "Enter password");
//                            return "";
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                             labelText: "Password",
//                             suffixIcon: IconButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     showPassword = !showPassword;
//                                   });
//                                 },
//                                 icon: showPassword ? const Icon(Icons.visibility): const Icon(Icons.visibility_off))),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 10),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: TextButton(
//                             onPressed: () {
//                               Get.toNamed(RouteName.forgotPasswordScreen);
//                             },
//                             child: const Text(
//                               "Forgot Password?",
//                               style: TextStyle(color: AppColor.purpleColor),
//                             )),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 10, left: 20, right: 20, bottom: 10),
//                       child: TextButton(
//                         onPressed: () {},
//                         style: TextButton.styleFrom(
//                             foregroundColor: AppColor.purpleColor,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 10),
//                             textStyle: const TextStyle(
//                               fontSize: 16,
//                             )),
//                         child: const Text(
//                           "Agree to our Terms & Conditions",
//                           style: TextStyle(
//                               color: AppColor.purpleColor,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           top: 10, left: 20, right: 20, bottom: 10),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             loginViewModel.loginApi();
//                           }
//                         },
//                         style: TextButton.styleFrom(
//                             foregroundColor: Colors.white,
//                             backgroundColor: AppColor.purpleColor,
//                             minimumSize: const Size.fromHeight(50),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 10),
//                             textStyle: const TextStyle(
//                               fontSize: 20,
//                             )),
//                         child: const Text("Log in"),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 2),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Already have an account?"),
//                           TextButton(
//                               onPressed: () {
//                                 Get.toNamed(RouteName.signupScreen);
//                               },
//                               child: const Text("Sign up",
//                                   style:
//                                       TextStyle(color: AppColor.purpleColor)))
//                         ],
//                       ),
//                     ),
//                   ],
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // Import this to use SystemNavigator
import 'package:poll_chat/res/app_url/app_url.dart';

import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/login_view_model.dart';
import 'package:poll_chat/view_models/controller/signup_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool showPassword = false;
  final loginViewModel = Get.put(LoginViewModel());
  final _formKey = GlobalKey<FormState>();
  // final SignupViewModel appController = Get.find();
  final appController = Get.put(SignupViewModel());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Use SystemNavigator.pop() to exit the app
        SystemNavigator.pop();
        return false; // Return false to prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          // title: const Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Log in to Pollchat',
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
                    'Welcome back! Sign in using your Mobile Number & Password',
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
                          controller: loginViewModel.mobileController.value,
                          focusNode: loginViewModel.mobileFocusNode.value,
                          validator: (value) {
                            if (value!.isEmpty) {
                              Utils.snackBar("Mobile", "Enter Mobile");
                              return "";
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            Utils.fieldFocusChange(
                                context,
                                loginViewModel.mobileFocusNode.value,
                                loginViewModel.passwordFocusNode.value);
                          },
                          decoration:
                              const InputDecoration(labelText: "Mobile Number"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 20, right: 20, bottom: 0),
                        child: TextFormField(
                          obscureText: !showPassword,
                          controller: loginViewModel.passwordController.value,
                          focusNode: loginViewModel.passwordFocusNode.value,
                          validator: (value) {
                            if (value!.isEmpty) {
                              Utils.snackBar("Password", "Enter password");
                              return "";
                            }
                            return null;
                          },
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: () {
                                Get.toNamed(RouteName.forgotPasswordScreen);
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: AppColor.purpleColor),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 20, right: 20, bottom: 10),
                        child: TextButton(
                          onPressed: () {
                            appController
                                .open("${AppUrl.baseUrl}/terms-of-use/");
                            // "https://pollchat.co/terms-of-use/");
                          },
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
                                fontSize: 16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 20, right: 20, bottom: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginViewModel.loginApi();
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
                          child: const Text("Log in"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                                onPressed: () {
                                  Get.toNamed(RouteName.signupScreen);
                                },
                                child: const Text("Sign up",
                                    style:
                                        TextStyle(color: AppColor.purpleColor)))
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
