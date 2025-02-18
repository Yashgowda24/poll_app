import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/simmer/simmerpollcard.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/privacy_setting/privacy_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PrivacySettingView extends StatefulWidget {
  const PrivacySettingView({super.key});

  @override
  State<StatefulWidget> createState() => _PrivacySettingView();
}

class _PrivacySettingView extends State<PrivacySettingView> {
  String profileViewGroupValue = "Everyone";
  String commentonPollGroupValue = "Everyone";
  String sendMessageGroupValue = "Everyone";
  String viewMomentGroupValue = "Everyone";
  PrivacyModelPrivacySetting auctions = PrivacyModelPrivacySetting();

  bool isLoading = true; // Add a loading flag

  @override
  void initState() {
    super.initState();
    fetchSavedAuction();
    blockUser();
  }

  List<Map<String, dynamic>> userList = [];

  void blockUser() async {
    log("message ====> deletePoll API Call");
    SharedPreferences sp = await SharedPreferences.getInstance();
    final authToken = sp.getString('authToken');
    var headers = {'Authorization': 'Bearer $authToken'};
    var request = http.Request('GET',
        Uri.parse('http://pollchat.myappsdevelopment.co.in/api/v1/block/'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> decodedResponse = json.decode(responseBody);

        // Access the list within the map using the appropriate key
        List<dynamic> users = decodedResponse['blocked'];

        // Convert the dynamic list to a list of maps with the expected types
        setState(() {
          userList = users.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        log('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> fetchSavedAuction() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final authToken = sp.getString('authToken');
    var headers = {'Authorization': 'Bearer $authToken'};
    final response = await http.get(
      Uri.parse('https://pollchat.myappsdevelopment.co.in/api/v1/user/privacy'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      log("json.decode ====> ${json.decode(response.body)}");
      setState(() {
        auctions = PrivacyModelPrivacySetting.fromJson(
            json.decode(response.body)['privacySetting']);
        profileViewGroupValue =
            auctions.profileType == "everyone" ? "Everyone" : "My friends";
        commentonPollGroupValue =
            auctions.commentType == "everyone" ? "Everyone" : "My friends";
        sendMessageGroupValue =
            auctions.messageType == "everyone" ? "Everyone" : "My friends";
        viewMomentGroupValue =
            auctions.storyType == "everyone" ? "Everyone" : "My friends";
        isLoading = false; // Set loading to false after fetching data
      });
    } else {
      print('Failed to load polls: ${response.body}');
      setState(() {
        isLoading = false; // Set loading to false even if fetching fails
      });
    }
  }

  Future<void> updatePrivacy() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final authToken = sp.getString('authToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken'
    };

    var response = await http.put(
      Uri.parse('https://pollchat.myappsdevelopment.co.in/api/v1/user/privacy'),
      headers: headers,
      body: json.encode({
        "profileType":
            profileViewGroupValue == "Everyone" ? "everyone" : "friends",
        "commentType":
            commentonPollGroupValue == "Everyone" ? "everyone" : "friends",
        "messageType":
            sendMessageGroupValue == "Everyone" ? "everyone" : "friends",
        "storyType":
            viewMomentGroupValue == "Everyone" ? "everyone" : "friends",
      }),
    );

    if (response.statusCode == 201) {
      print(await response.body);
      Get.snackbar('Success', 'Privacy Settings Changed Successfully');
      Navigator.pop(context);
    } else {
      Get.snackbar('Error', 'Failed to change Privacy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Settings"),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          updatePrivacy();
        },
        child: Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 18).copyWith(bottom: 12),
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColor.purpleColor,
          ),
          child: const Center(
            child: Text(
              "Done",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: ShimmerListView(
                itemCount: 10,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Who can view my profile',
                        style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Radio(
                                  value: 'Everyone',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: profileViewGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      profileViewGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'Everyone',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                  value: 'My friends',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: profileViewGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      profileViewGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'My friends',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: Container(
                        height: 1,
                        color: AppColor.greyLight5Color,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Who can comment on my posts/polls',
                        style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Radio(
                                  value: 'Everyone',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: commentonPollGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      commentonPollGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'Everyone',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                  value: 'My friends',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: commentonPollGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      commentonPollGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'My friends',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: Container(
                        height: 1,
                        color: AppColor.greyLight5Color,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Who can send me message',
                        style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Radio(
                                  value: 'Everyone',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: sendMessageGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      sendMessageGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'Everyone',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                  value: 'My friends',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: sendMessageGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      sendMessageGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'My friends',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: Container(
                        height: 1,
                        color: AppColor.greyLight5Color,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Who can view my comment',
                        style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Radio(
                                  value: 'Everyone',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: viewMomentGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      viewMomentGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'Everyone',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                  value: 'My friends',
                                  activeColor: AppColor.purpleColor,
                                  groupValue: viewMomentGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      viewMomentGroupValue = value!;
                                    });
                                  }),
                              const Text(
                                'My friends',
                                style: TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: Container(
                        height: 1,
                        color: AppColor.greyLight5Color,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Blocked People",
                            style: TextStyle(
                                color: AppColor.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          Text('${userList.length}',
                              style: TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
