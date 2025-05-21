import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class GroupfriendScreen extends StatefulWidget {
  const GroupfriendScreen({super.key});

  @override
  _GroupfriendScreenState createState() => _GroupfriendScreenState();
}

class _GroupfriendScreenState extends State<GroupfriendScreen> {
  List<Friend> friends = [];
  Set<Friend> selectedFriends = {};
  final Friend everyone = Friend(name: 'Everyone');
  UserPreference userPreference = UserPreference();
  bool? _isLoading = true; // Add a loading state
  List<String> friendIds = []; // Add a list to store friend IDs
  var message = Get.arguments;
  var imagevideopath = Get.arguments;
  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    var token = await userPreference.getAuthToken();
    var response = await http.get(
      Uri.parse(
        '${AppUrl.baseUrl}/api/v1/friend/friendList/',
        // 'https://poll-chat.onrender.com/api/v1/friend/friendList/',
        // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/friendList/',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var filterList = jsonData['filterList'] as List<dynamic>;

      List<Friend> fetchedFriends = filterList.map<Friend>((item) {
        var friendData = item['friend'];
        friendIds.add(friendData['_id']);
        return Friend(
          name: friendData['name'],
          avatar: friendData['profilePhoto'],
          id: friendData['_id'],
        );
      }).toList();

      setState(() {
        friends = fetchedFriends;
        _isLoading = false;
      });
    } else {
      throw Exception(
        'Failed to load friend requests: ${response.reasonPhrase}',
      );
    }
  }

  // Future<void> sendMessageToMultipleUsers() async {
  //   var token = await userPreference.getAuthToken();
  //   var headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };
  //   var request = http.Request(
  //     'POST',
  //     Uri.parse(
  //         'https://pollchat.myappsdevelopment.co.in/api/v1/message/create/'),
  //   );

  //   var selectedFriendIds = selectedFriends.map((friend) => friend.id).toList();

  //   request.body = json.encode({
  //     "message": message,
  //     "friendIds": selectedFriendIds.isEmpty ? friendIds : selectedFriendIds,
  //   });
  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 201) {
  //     print(await response.stream.bytesToString());
  //     Utils.snackBar("Success", 'Message sent successfully');
  //     Get.toNamed(
  //       RouteName.dashboardScreen,
  //     );
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  Future<void> sendMessage(String message, String imagevideopath) async {
    List<String> chatIds = [];
    String? authToken = await userPreference.getAuthToken();
    var headers = {
      'Authorization': 'Bearer $authToken',
    };

    var body = {
      'friendIds': friendIds.join(','),
      'message': message,
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppUrl.baseUrl}/api/v1/message/create'),
      // 'https://poll-chat.onrender.com/api/v1/message/create'),
      // 'http://pollchat.myappsdevelopment.co.in/api/v1/message/create'),
    );

    request.headers.addAll(headers);
    request.fields.addAll(body);

    if (imagevideopath.isNotEmpty) {
      if (await File(imagevideopath).exists()) {
        request.files
            .add(await http.MultipartFile.fromPath('media', imagevideopath));
      } else {
        print('File does not exist at path: $imagevideopath');
      }
    }

    try {
      http.StreamedResponse response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        var responseJson = jsonDecode(responseString);
        print('Response: $responseJson');

        if (responseJson['sendMsgs'] != null &&
            responseJson['sendMsgs'].isNotEmpty) {
          for (var msg in responseJson['sendMsgs']) {
            print('Sent message details: $msg');
          }
          Get.toNamed(RouteName.dashboardScreen);
          Utils.snackBar('Message', responseJson['message']);
        } else {
          print('No messages in response.');
        }
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        print('Response body: $responseString');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Friends'),
      ),
      body: _isLoading!
          ? const ShimmerListView(itemCount: 10)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'To',
                      fillColor: AppColor.pink2Color,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (friends.isNotEmpty)
                  ListTile(
                    title: const Text(
                      'Everyone',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: Checkbox(
                      value: selectedFriends.length == friends.length,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedFriends.addAll(friends);
                            print(friends);
                          } else {
                            selectedFriends.clear();
                          }
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return AppColor.purpleColor;
                        }
                        return Colors.transparent;
                      }),
                      activeColor: AppColor.whiteColor,
                    ),
                  ),
                Expanded(
                  child: friends.isEmpty
                      ? Center(child: Text('No friends'))
                      : ListView.builder(
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  leading: SizedBox(
                                    height: 40,
                                    child: SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ClipPath(
                                        clipper: OctagonClipper(),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: friends[index].avatar!,
                                          placeholder: (context, url) => Center(
                                            child: friends[index].avatar == null
                                                ? Text(friends[index].name![0])
                                                : null,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    friends[index].name!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: selectedFriends
                                        .contains(friends[index]),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedFriends.add(friends[index]);
                                        } else {
                                          selectedFriends
                                              .remove(friends[index]);
                                        }
                                      });
                                    },
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) {
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return AppColor.purpleColor;
                                      }
                                      return Colors.transparent;
                                    }),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (selectedFriends
                                          .contains(friends[index])) {
                                        selectedFriends.remove(friends[index]);
                                      } else {
                                        selectedFriends.add(friends[index]);
                                      }
                                    });
                                  },
                                ),
                                Divider(
                                  color: AppColor.purpleColor.withOpacity(0.2),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: friends.isNotEmpty,
                  child: GestureDetector(
                    onTap: () async {
                      // sendMessageToMultipleUsers();
                      sendMessage(message, imagevideopath);
                    },
                    child: Container(
                      height: 45,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppColor.purpleColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: AppColor.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

class Friend {
  final String? name;
  final String? avatar;
  final String? id;
  Friend({required this.name, this.avatar, this.id});
}
