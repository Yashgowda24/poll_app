import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/res/app_url/app_url.dart';
import 'dart:convert';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class AccountsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  UserPreference userPreference = UserPreference();
  List<Map<String, dynamic>> userList = [];
  List<String> userIds = [];
  bool isLoading = false;
  var id;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String? authToken = await userPreference.getAuthToken();
      var url = Uri.parse(
        '${AppUrl.baseUrl}/api/v1/user/',
        // 'https://poll-chat.onrender.com/api/v1/user/',
        // 'http://pollchat.myappsdevelopment.co.in/api/v1/user/',
      );
      var headers = {'Authorization': 'Bearer $authToken'};
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          userList = List<Map<String, dynamic>>.from(jsonData['user']);
        });
        for (var user in jsonData['user']) {
          id = user['_id'];
          userIds.add(id);
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // bool? issent;
  Future<void> sendFriendRequest(String id) async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};
    var url = Uri.parse('${AppUrl.baseUrl}/api/v1/friend/add/$id');
    // 'https://poll-chat.onrender.com/api/v1/friend/add/$id');
    // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/add/$id');
    try {
      var response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        print(id);
        print('Friend request sent successfully');
        Get.snackbar("Request", "Friend request sent successfully");
        // issent = true;
      } else {
        var responseData = json.decode(response.body);
        var message = responseData['message'];

        if (message == "Cant Request,Already friends or Request Already sent") {
          Get.snackbar("Request Already sent", "$message");
        } else {
          print('Failed to send friend request: $message');
        }
      }
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Peoples",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ),
        Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : userList.isNotEmpty
                    ? ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Get.toNamed(RouteName.chatpage,
                              //     arguments: userList[index]);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1,
                                          color: AppColor.greyLight3Color))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: CircleAvatar(
                                            radius: 24,
                                            child: Image.network(
                                              userList[index]['profilePhoto'],
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 8,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userList[index]['name'] ?? "",
                                              style: const TextStyle(
                                                  color: AppColor.blackColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                userList[index]
                                                        ['messageType'] ??
                                                    "",
                                                style: const TextStyle(
                                                    color: AppColor.blackColor,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ],
                                        )),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                          alignment: Alignment.topCenter,
                                          child: InkWell(
                                              onTap: () async {
                                                sendFriendRequest(
                                                    userList[index]['_id'] ??
                                                        "");
                                              },
                                              child: const Icon(
                                                Icons.add,
                                                color: AppColor.purpleColor,
                                              ))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                    : SizedBox(
                        child: Center(
                            child: Image.asset(
                        'assets/images/logo.png',
                        height: 50,
                        width: 50,
                      )))),
      ],
    );
  }
}
