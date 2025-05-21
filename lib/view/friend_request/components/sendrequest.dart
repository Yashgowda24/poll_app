import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class SendRequestScreen extends StatefulWidget {
  const SendRequestScreen({Key? key}) : super(key: key);

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  final homeViewController = Get.put(HomeViewModelController());
  UserPreference userPreference = UserPreference();

  @override
  void initState() {
    super.initState();
    homeViewController.sentRequests;
    sendRequest();
  }

  Future<void> sendRequest() async {
    print("Loading started");
    try {
      var token = await userPreference.getAuthToken();
      var headers = {'Authorization': 'Bearer $token'};
      var request = http.Request(
          'GET', Uri.parse('${AppUrl.baseUrl}/api/v1/friend/sent/'));
      // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/sent/'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonData = jsonDecode(responseBody);

        if (jsonData['status'] == true) {
          if (jsonData['sentRequests'] is List) {
            homeViewController.sentRequests.value = jsonData['sentRequests'];
          } else {
            homeViewController.sentRequests.value = [jsonData['sentRequests']];
          }
          print("Requests fetched successfully");
        } else {
          print(jsonData['message']);
          homeViewController.sentRequests.value =
              []; // Clear the list if there's no data
        }
      } else {
        print(response.reasonPhrase);
        homeViewController.sentRequests.value =
            []; // Clear the list if the request fails
      }
    } catch (e) {
      print("Error: $e");
      homeViewController.sentRequests.value =
          []; // Clear the list if there's an error
    } finally {
      //loading.value = false;
      print("Loading ended");
    }
  }

  String formatDateTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal();
    String formattedDateTime = DateFormat('dd/MM/yy hh:mm a').format(dateTime);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Friends Requests",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (homeViewController.loading.value) {
                return Center(child: ShimmerListView(itemCount: 8));
              } else if (homeViewController.sentRequests.isEmpty) {
                return Center(
                    child: Text(
                  'No friend requests found',
                  style: TextStyle(color: Colors.black),
                ));
              } else {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: homeViewController.sentRequests.length,
                  itemBuilder: (context, index) {
                    var request = homeViewController.sentRequests[index];
                    var friend1 = request['friend1'];

                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteName.usersearchprofileview,
                                  arguments: friend1);
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: CircleAvatar(
                                radius: 30,
                                child: Image.network(
                                  friend1['profilePhoto'] ?? '',
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/logo.png',
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 140,
                                child: Text(
                                  friend1['name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                  width: 150,
                                  child: Text(friend1['username'] ?? '')),
                              Text(
                                formatDateTime(request['createdAt'] ?? ''),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    25,
                                  ),
                                  color: AppColor.whiteColor,
                                  border:
                                      Border.all(color: AppColor.purpleColor),
                                ),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Request Sent',
                                      style: TextStyle(
                                          color: AppColor.purpleColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: InkWell(
                              onTap: () {
                                homeViewController.unfriend(friend1['_id']);
                              },
                              child: Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
