import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  UserPreference userPreference = UserPreference();

  Future<void> changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? authToken = await userPreference.getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      };

      var response = await http.put(
        Uri.parse(
          '${AppUrl.baseUrl}/api/v1/user/changePassword/'),
            // 'https://pollchat.myappsdevelopment.co.in/api/v1/user/changePassword/'),
        headers: headers,
        body: json.encode({
          "oldPassword": _currentPasswordController.text,
          "password": _newPasswordController.text,
          "confirmPassword": _confirmPasswordController.text
        }),
      );
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        print(await response.body);
        Get.snackbar('Success', 'Password Changed Successfully');
        Navigator.pop(context);
      } else {
        Get.snackbar('Error', 'Failed to change password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 8,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Your password must be at least six characters',
                        style: TextStyle(
                          color: AppColor.greyColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFormField(
                        controller: _currentPasswordController,
                        decoration: const InputDecoration(
                          labelText: "Current Password",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFormField(
                        controller: _newPasswordController,
                        decoration: const InputDecoration(
                          labelText: "New Password",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          } else if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator()) // Show loader if isLoading is true
                    : InkWell(
                        onTap: () {
                          changePassword();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: AppColor.purpleColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            child: Text(
                              "Change Password",
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
            )
          ],
        ),
      ),
    );
  }
}
