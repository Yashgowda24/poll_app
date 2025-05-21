import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:http/http.dart' as http;

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> userList = [];
  List<dynamic> _friendRequests = [];
  UserPreference userPreference = UserPreference();
  final TextEditingController _searchController = TextEditingController();
  var friendRequest;
  @override
  void initState() {
    fetchData();
    _fetchFriendRequests();
    // fetchCloseFriends();
    super.initState();
  }

  List<dynamic> _searchResults = [];

  Future<void> performSearch(String query) async {
    var token = await userPreference.getAuthToken();
    var apiUrl = 'https://poll-chat.onrender.com/api/v1/search/user/$query';
    // 'http://pollchat.myappsdevelopment.co.in/api/v1/search/user/$query';
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _searchResults = jsonData['users'];
        });
      } else {
        throw Exception(
            'Failed to fetch search results: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  List<dynamic> closeFriendsList = [];

  Future<void> fetchCloseFriends() async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $authToken'};
    var request = http.Request(
        'GET', Uri.parse('${AppUrl.baseUrl}/api/v1/friend/closefriend/list'));
    // 'https://poll-chat.onrender.com/api/v1/friend/closefriend/list'));
    // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/closefriend/list'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var responseData = jsonDecode(responseBody);
      if (responseData['success']) {
        setState(() {
          closeFriendsList = responseData['closeFriends'];
        });
        print('Close friends list updated successfully');
      } else {
        print(
            'Failed to retrieve close friends list: ${responseData['message']}');
      }
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  Future<void> fetchData() async {
    try {
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
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchFriendRequests() async {
    var token = await userPreference.getAuthToken();
    var response = await http.get(
      Uri.parse('${AppUrl.baseUrl}/api/v1/friend/friendList/'),
      // 'https://poll-chat.onrender.com/api/v1/friend/friendList/'),
      // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/friendList/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('*****');
      print('json data is:');
      print(jsonData);
      print('*******');
      var filterList = jsonData['filterList'] as List<dynamic>;

      // var filterList = jsonData['list'] as List<dynamic>;

      setState(() {
        _friendRequests = filterList;
      });
    } else {
      throw Exception(
          'Failed to load friend requests: ${response.reasonPhrase}');
    }
  }

  Future<void> unfriend(String id) async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
      'GET',
      Uri.parse('${AppUrl.baseUrl}/api/v1/friend/remove/$id'),
    );
    // 'https://poll-chat.onrender.com/api/v1/friend/remove/$id'));
    // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/remove/$id'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Get.snackbar('UnFriend', 'Request UnFriend Successfully');
      _fetchFriendRequests();
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> mutenotifications() async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
      'GET',
      Uri.parse(
        '${AppUrl.baseUrl}/api/v1/notification/mute',
      ),
    );
    // 'https://poll-chat.onrender.com/api/v1/notification/mute'));
    // 'http://pollchat.myappsdevelopment.co.in/api/v1/notification/mute'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = json.decode(await response.stream.bytesToString());
      String message = responseData['message'] ?? 'No message available';
      Get.snackbar('Mute', message);
      _fetchFriendRequests();
      print(responseData);
    } else {
      print(response.reasonPhrase);
    }
  }

  // var _selectedImagePath;
  // String? _selectedVideoPath;
  // VideoPlayerController? _videoPlayerController;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBottomSheetOption(
                    context,
                    imagePath: 'assets/images/pinchat.png',
                    label: 'Pin chat',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  _buildBottomSheetOption(
                    context,
                    imagePath: 'assets/images/unfriend.png',
                    label: 'Unfriend',
                    onTap: () {
                      Navigator.pop(context);
                      unfriend(friendRequest['_id']);
                    },
                  ),
                  _buildBottomSheetOption(
                    context,
                    imagePath: 'assets/images/mutenoti.png',
                    label:
                        _isMuted ? 'Notifications Muted' : 'Mute notification',
                    onTap: () {
                      mutenotifications();
                      // Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(6.0), // Add padding to center the image
            child: Image.asset(
              imagePath,
              height: 50,
              color: AppColor.purpleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  bool _isMuted = false;

  void _showBottomSheetgroupchat(BuildContext context) {
    _controller.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Send message to multiple friends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.pink2Color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Your message...',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_controller.text.isNotEmpty) {
                                Get.toNamed(RouteName.choosepage,
                                    arguments: _controller.text);
                              } else {
                                Utils.snackBar('Error',
                                    'Please enter some text before proceeding.');
                              }
                            },
                            child: Image.asset(
                              'assets/images/cta.png',
                              height: 32,
                              width: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(child: Text("Messages")),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.pink2Color,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Who do you want to chat with?",
                      border: InputBorder.none,
                      prefix: const SizedBox(width: 15),
                      suffixIcon: UnconstrainedBox(
                        child: SvgPicture.asset(
                          IconAssets.inputSearchIcon,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      performSearch(value);
                      setState(() {
                        if (_searchController.text.isEmpty) {
                          _searchResults.clear();
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: AppColor.greyLight3Color,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "MY CLOSEST ONES",
                    style: TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              _isLoading
                  ? const Center(
                      child: const ShimmerListView(itemCount: 10),
                    )
                  : _searchController.text.isEmpty
                      ? Expanded(
                          child: _friendRequests.isEmpty
                              ? const Center(
                                  child: Text('Friends Not Found '),
                                )
                              : ListView.builder(
                                  itemCount: _friendRequests.length,
                                  itemBuilder: (context, index) {
                                    friendRequest =
                                        _friendRequests[index]['friend'] ?? {};
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: InkWell(
                                        onTap: () {
                                          // Get.toNamed(RouteName.chatpage,
                                          //     arguments: _friendRequests[index]
                                          //         ['friend']);
                                          Get.toNamed(
                                            '/chatpage',
                                            arguments: {
                                              'user': _friendRequests[index]
                                                      ['friend'] ??
                                                  0,
                                            },
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: ClipPath(
                                                clipper: OctagonClipper(),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: friendRequest[
                                                          'profilePhoto'] ??
                                                      "",
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  friendRequest['name'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  friendRequest['username'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              onTap: () {},
                                              child: const Align(
                                                alignment: Alignment.topCenter,
                                                child: Text('Last message',
                                                    style: TextStyle(
                                                        color:
                                                            AppColor.greyColor,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              child: const Icon(
                                                Icons.more_vert,
                                              ),
                                              onTap: () {
                                                _showBottomSheet(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        )
                      : _searchResults.isEmpty
                          ? Container()
                          : Expanded(
                              child: ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Get.toNamed(RouteName.chatpage,
                                          arguments: _searchResults[index]);
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 1,
                                            color: AppColor.greyLight3Color,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 48,
                                              width: 48,
                                              child: ClipPath(
                                                clipper: OctagonClipper(),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: _searchResults[
                                                              index]
                                                          ['profilePhoto'] ??
                                                      "",
                                                  height: 48,
                                                  width: 48,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _searchResults[index]
                                                          ['name'] ??
                                                      "",
                                                  style: const TextStyle(
                                                    color: AppColor.blackColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  _searchResults[index]
                                                          ['username'] ??
                                                      "",
                                                  style: const TextStyle(
                                                    color: AppColor.blackColor,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
              Center(
                child: Container(
                  width: 100,
                  height: 50,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColor.purpleColor),
                      borderRadius: BorderRadius.circular(22)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(RouteName.gropchatscreen);
                        },
                        child: Image.asset(
                          'assets/images/newcamera.png',
                          height: 24,
                          width: 24,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: () async {
                          _showBottomSheetgroupchat(context);
                        },
                        child: Image.asset(
                          'assets/images/messages.png',
                          height: 24,
                          width: 24,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
