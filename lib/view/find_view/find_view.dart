import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:http/http.dart' as http;
import '../../view_models/controller/home_model.dart';
import '../home/components/poll_card/poll_card.dart';

class FindView extends StatefulWidget {
  const FindView({super.key});

  @override
  State<StatefulWidget> createState() => _FindViewState();
}

class _FindViewState extends State<FindView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _pollSearchResults = [];
  UserPreference userPreference = UserPreference();
  List<Map<String, dynamic>> userList = [];
  List<String> userIds = [];
  bool isLoading = false;
  var id;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> sendFriendRequest(String id) async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};
    var url = Uri.parse(
        'https://pollchat.myappsdevelopment.co.in/api/v1/friend/add/$id');
    try {
      var response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        print(id);
        print('Friend request sent successfully');
        Get.snackbar("Request", "Friend request sent successfully");
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

  Future<void> performSearch(String query) async {
    var token = await userPreference.getAuthToken();
    final apiUrl =
        'https://pollchat.myappsdevelopment.co.in/api/v1/search/user/$query';
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
        log("datas :: : => ${jsonDecode(response.body)}");
      } else {
        throw Exception(
            'Failed to fetch search results: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> performPollSearch(String query) async {
    log("performPollSearch API call");
    var token = await userPreference.getAuthToken();
    final apiUrl =
        'https://pollchat.myappsdevelopment.co.in/api/v1/search/poll/$query';
    // 'https://pollchat.myappsdevelopment.co.in/api/v1/search/poll/question/$query';
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        log("performPollSearch API success");

        final jsonData = jsonDecode(response.body);
        setState(() {
          _pollSearchResults = jsonData['polls'];
        });
        log("datas :: : => ${jsonDecode(response.body)}");
      } else {
        log("performPollSearch API fail");

        throw Exception(
            'Failed to fetch poll search results: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Search"),
        ),
        body: SafeArea(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.pink2Color,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    prefixIcon: UnconstrainedBox(
                      child: SvgPicture.asset(
                        IconAssets.inputSearchIcon,
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchResults.clear();
                          _pollSearchResults.clear();
                        });
                      },
                      child: UnconstrainedBox(
                        child: SvgPicture.asset(
                          IconAssets.inputCloseIcon,
                        ),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (_tabController.index == 0) {
                      performSearch(value);
                      if (_searchController.text.isEmpty) {
                        setState(() {
                          _searchResults.clear();
                        });
                      }
                    } else {
                      performPollSearch(value);
                      if (_searchController.text.isEmpty) {
                        setState(() {
                          _pollSearchResults.clear();
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColor.purpleColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColor.purpleColor,
                  labelStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  unselectedLabelColor: AppColor.greyColor,
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 16),
                  tabs: const [
                    Tab(
                      text: "Accounts",
                    ),
                    Tab(
                      text: "Polls",
                    ),
                  ]),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAccountsTab(),
                  _buildPollsTab(),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildAccountsTab() {
    return _searchResults.isEmpty
        ? const Center(
            child: Text(
              "No account found",
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ListView.builder(
            itemCount: _searchResults.length,
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
                              width: 1, color: AppColor.greyLight3Color))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () async {
                                Get.toNamed(RouteName.usersearchprofileview,
                                    arguments: _searchResults[index]);
                              },
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: ClipPath(
                                  clipper: OctagonClipper(),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    child: Image.network(
                                      _searchResults[index]['profilePhoto'],
                                      fit: BoxFit.cover,
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
                                ),
                              ),
                            )),
                        Expanded(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _searchResults[index]['name'] ?? "",
                                  style: const TextStyle(
                                      color: AppColor.blackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _searchResults[index]['username'] ?? "",
                                  style: const TextStyle(
                                      color: AppColor.blackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: InkWell(
                              onTap: () async {
                                sendFriendRequest(
                                    _searchResults[index]['_id'] ?? "");
                                Get.toNamed(RouteName.usersearchprofileview,
                                    arguments: _searchResults[index]);
                              },
                              child: const Icon(
                                Icons.add,
                                color: AppColor.purpleColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  final homeModelController = Get.put(HomeViewModelController());

  Widget _buildPollsTab() {
    return _pollSearchResults.isEmpty
        ? const Center(
            child: Text("No Poll Found"),
          )
        : ListView.builder(
            itemCount: _pollSearchResults.length,
            itemBuilder: (context, index) {
              return PollCard(
                isProfile: true,
                isPinnedPolls: false,
                pollModel: _pollSearchResults[index],
                user: homeModelController.singleUser,
              );
            },
          );
  }
}
