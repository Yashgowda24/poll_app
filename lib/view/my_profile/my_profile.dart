import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/simmer/simmerpollcard.dart';
import 'package:poll_chat/view/home/components/poll_card/poll_card.dart';
import 'package:poll_chat/view/my_profile/savepolls/savetabs.dart';
import 'package:poll_chat/view/my_profile/supporter.dart';
import 'package:poll_chat/view/my_profile/supporting.dart';
import 'package:poll_chat/view/my_profile/useractions/postsuser.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:http/http.dart' as http;

class MyProfileView extends StatefulWidget {
  const MyProfileView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final homeViewController = Get.put(HomeViewModelController());
  UserPreference userPreference = UserPreference();
  bool _showListView = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getProfile();
    suggetionsApiRequest();
  }

  Future<void> getProfile() async {
    String? id = await userPreference.getUserID();
    log("ID here: $id");
    await homeViewController.getSingleUser(id!);
    homeViewController.getAllPolls();
    homeViewController.allPollsUser;
    setState(() {
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> suggestRequests = [];

  Future<void> suggetionsApiRequest() async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/friend/suggestion'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> jsonData = jsonDecode(responseBody);

      if (jsonData['status'] == true) {
        setState(() {
          suggestRequests =
              List<Map<String, dynamic>>.from(jsonData['suggestedFriends']);
        });

        log(suggestRequests.toString());
      } else {
        log(jsonData['message']);
      }
    } else {
      log("Error: ${response.reasonPhrase}");
    }
  }

  Widget _buildProfileAvatar() {
    String? profilePhotoUrl =
        homeViewController.singleUser["profilePhoto"]?.toString().trim() ?? "";

    if (profilePhotoUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CachedNetworkImage(
                          imageUrl: profilePhotoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        homeViewController.singleUser["name"] ?? "",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: ClipPath(
          clipper: OctagonClipper(),
          child: CachedNetworkImage(
            imageUrl: profilePhotoUrl,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('assets/images/logo.png'),
      );
    }
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
        // issent = true;
        suggetionsApiRequest();
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

  Future<void> unfriend(String id) async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/friend/delete/$id'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Get.snackbar('UnFriend', 'Request UnFriend Successfully');
      suggetionsApiRequest();
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              InkWell(
                onTap: () {
                  Get.toNamed(RouteName.settingsScreen);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SvgPicture.asset(IconAssets.settingsIcon),
                ),
              )
            ],
            pinned: true,
            expandedHeight: 280.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (homeViewController.singleUser.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.center,
                      child: _buildProfileAvatar(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          homeViewController.singleUser["name"]?.toString() ??
                              '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          homeViewController.singleUser["city"] ?? '',
                          style: const TextStyle(
                            color: AppColor.greyLight2Color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          homeViewController.singleUser["bio"] ?? '',
                          style: const TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(SupportersScreen());
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  homeViewController.singleUser["supporters"]
                                          ?.toString() ??
                                      '',
                                  style: const TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Supporters',
                                  style: TextStyle(
                                    color: AppColor.greyLight2Color,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(SupportingScreen());
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  homeViewController.singleUser["supporting"]
                                          ?.toString() ??
                                      '',
                                  style: const TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Supporting',
                                  style: TextStyle(
                                    color: AppColor.greyLight2Color,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_showListView)
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _showListView = true;
                                  });
                                },
                                child:
                                    SvgPicture.asset(IconAssets.profileAddIcon),
                              ),
                            ),
                          UnconstrainedBox(
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(RouteName.editProfileScreen);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.purpleColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 6),
                                  child: Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 40,
                  )
                ],
              ),
            ),
            bottom: !_showListView
                ? TabBar(
                    controller: _tabController,
                    labelColor: AppColor.purpleColor,
                    indicatorColor: AppColor.purpleColor,
                    tabs: const [
                      Tab(text: "My Polls"),
                      Tab(text: "My Actions"),
                      Tab(text: "Saved"),
                    ],
                  )
                : null,
          ),
        ],
        body: _showListView
            ? isLoading
                ? const Center(
                    child: ShimmerListView(
                      itemCount: 10,
                    ),
                  )
                : suggestRequests.isEmpty
                    ? Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 100,
                          width: 100,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Suggested for you',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showListView = false;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: suggestRequests.length,
                              itemBuilder: (context, index) {
                                var friend = suggestRequests[index];

                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: ClipPath(
                                          clipper: OctagonClipper(),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                friend['profilePhoto'] ?? '',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'assets/images/logo.png',
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 140,
                                            child: Text(
                                              friend['name'] ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(
                                              width: 150,
                                              child: Text(
                                                  friend['username'] ?? '')),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            sendFriendRequest(friend['_id']);

                                            //  confirmrequest(account['frnd_id']);
                                          },
                                          child: Container(
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.purple),
                                            ),
                                            child: const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Add',
                                                  style: TextStyle(
                                                      color: Colors.purple),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: InkWell(
                                            onTap: () {
                                              unfriend(friend['_id']);
                                            },
                                            child: const Icon(Icons.close)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
            : TabBarView(
                controller: _tabController,
                children: [
                  // homeViewController.loading.value
                  //     ? const Center(
                  //         child: ShimmerListView(
                  //         itemCount: 10,
                  //       ))
                  //     : ListView.builder(
                  //         shrinkWrap: true,
                  //         itemCount: homeViewController.allPollsUser.length,
                  //         itemBuilder: (context, index) {
                  //           var poll = homeViewController.allPollsUser[index];

                  //           if (homeViewController.allPollsUser.isEmpty) {
                  //             return const Center(
                  //               child:
                  //                   CircularProgressIndicator(), // Loader while fetching data
                  //             );
                  //           } else {
                  //             return PollCard(
                  //               isProfile: true,
                  //               isPinnedPolls: false,
                  //               pollModel: poll,
                  //               user: homeViewController.singleUser,
                  //             );
                  //           }
                  //         },
                  //       ),

                  Obx(
                    () {
                      if (homeViewController.loading.isTrue) {
                        return const Center(
                          child: ShimmerPollCard(
                            itemCount: 3,
                          ),
                        );
                      }
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (homeViewController.allPollsUser.isNotEmpty)
                            ...homeViewController.allPollsUser.map((poll) {
                              if (poll == 'advertisement') {
                                return const SizedBox.shrink();
                              }
                              return PollCard(
                                isProfile: true,
                                isPinnedPolls: false,
                                pollModel: poll,
                                user: homeViewController.singleUser,
                              );
                            }),
                          const Divider(),
                        ],
                      );
                    },
                  ),

                  const PostsUser(),
                  SavedPage(),
                ],
              ),
      ),
    );
  }
}
