import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/action_view/components/useractions.dart';
import 'package:poll_chat/view/home/components/poll_card/poll_card.dart';
import 'package:poll_chat/view/my_profile/savepolls/savetabs.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class ChateUserProfile extends StatefulWidget {
  ChateUserProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChateUserProfileState();
}

class _ChateUserProfileState extends State<ChateUserProfile>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final homeViewController = Get.put(HomeViewModelController());
  UserPreference userPreference = UserPreference();
  final dynamic src = Get.arguments;

  @override
  void initState() {
    super.initState();
    print(src);
    _tabController = TabController(length: 3, vsync: this);

    // getProfile();
  }

  Future<void> getProfile() async {
    var id = await userPreference.getUserID();
    log("ID here: $id");
    homeViewController.getSingleUser(id!);
    homeViewController.getAllPolls().then((value) {});
  }

  String? profilePhotoUrl;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _buildProfileAvatar() {
    String? profilePhotoUrl = src["profilePhoto"]?.toString().trim() ?? "";
    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      Uri profilePhotoUri = Uri.parse(profilePhotoUrl);
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              src["profilePhoto"] ?? "",
                              height: 400, // Adjusted height
                              width: 260, // Adjusted width
                              fit: BoxFit.cover, // Adjust image fit
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            src["name"] ?? "",
                            style: TextStyle(fontSize: 16), // Added text style
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: CircleAvatar(
          radius: 45,
          backgroundImage: NetworkImage(profilePhotoUri.toString()),
        ),
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('assets/images/logo.png'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double padding = screenWidth * 0.05;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text(
              src['name'] ?? "",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            pinned: true,
            expandedHeight: screenHeight * 0.41,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (src['name'] != null) ...[
                      SizedBox(height: screenHeight * 0.1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildProfileAvatar(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                src["supporters"]?.toString() ?? '',
                                style: TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Supporters',
                                style: TextStyle(
                                  color: AppColor.greyLight2Color,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                src["supporting"]?.toString() ?? '',
                                style: TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Supporting',
                                style: TextStyle(
                                  color: AppColor.greyLight2Color,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: screenWidth * 0.08,
                            height: screenWidth * 0.08,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(RouteName.friendRequestScreen);
                              },
                              child:
                                  SvgPicture.asset(IconAssets.profileAddIcon),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: padding * 0.2),
                        child: Text(
                          src["username"] ?? '',
                          style: TextStyle(
                            color: AppColor.blac2kColor,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: padding * 0.2),
                        child: Text(
                          src["bio"] ?? '',
                          style: TextStyle(
                            color: AppColor.greyLight2Color,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: padding * 0.2),
                        child: Text(
                          src["city"] ?? 'ind',
                          style: TextStyle(
                            color: AppColor.blackColor,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColor.purpleColor,
              indicatorColor: AppColor.purpleColor,
              tabs: const [
                Tab(text: "Polls"),
                Tab(text: "Actions"),
                Tab(text: "Saved"),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: homeViewController.allPollsUser.length,
              itemBuilder: (context, index) {
                var poll = homeViewController.allPollsUser[index];
                return homeViewController.allPollsUser.isNotEmpty
                    ? PollCard(
                        isProfile: true,
                        isPinnedPolls: false,
                        pollModel: poll,
                        user: homeViewController.singleUser,
                      )
                    : const Center(
                        child: Text("Not Polls Created"),
                      );
              },
            ),
            const UserActions(),
            SavedPage(),
          ],
        ),
      ),
    );
  }
}
