// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/components/header/header.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerpollcard.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/home/components/moments.dart';
import 'package:poll_chat/view/home/components/poll_card/poll_card.dart';
import 'package:poll_chat/view/home/components/top_list/top_list.dart';
import 'package:poll_chat/view/home/components/top_list/trandingpoll.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final homeModelController = Get.put(HomeViewModelController());
  UserPreference userPreference = UserPreference();

  @override
  void initState() {
    homeModelController.getAllPollsEveryOne();
    homeModelController.allPolls;

    homeModelController.otheruserpoll;
    allPolls();
    allPinnedPollsPinnedPolls();
    trandingPolls();
    super.initState();
  }

  Future<void> allPolls() async {
    var token = await userPreference.getAuthToken();
    const apiUrl = AppUrl.everyonepolls;
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          List<dynamic> list = jsonData["polls"];
          homeModelController.allPolls.value = list.reversed.toList();
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

  Future<void> allPinnedPollsPinnedPolls() async {
    String? authToken = await userPreference.getAuthToken();

    if (authToken == null) {
      print("Auth token is null");
      return;
    }
    const apiUrl = 'https://poll-chat.onrender.com/api/v1/poll/pin/get';
    // 'https://pollchat.myappsdevelopment.co.in/api/v1/poll/pin/get';
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    try {
      homeModelController.loading.value = true;
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        homeModelController.allPinnedPolls.clear();
        final jsonData = jsonDecode(response.body);

        log("all Pinned Polls ====> $jsonData");

        List<dynamic> list = jsonData['pinnedpolls'];
        homeModelController.allPinnedPolls.value = list.toList();

        log("all Pinned Polls length ====> ${homeModelController.allPinnedPolls.length}");
        homeModelController.loading.value = false;
      } else {
        homeModelController.loading.value = false;
        throw Exception(
            'Failed to fetch poll search results: ${response.reasonPhrase}');
      }
    } on Exception catch (e) {
      homeModelController.loading.value = false;
      // Utils.snackBar("Error", e.toString());
      log('Error: $e');
    }
  }

  Future<void> trandingPolls() async {
    String? authToken = await userPreference.getAuthToken();

    const apiUrl =
    'https://poll-chat.onrender.com/api/v1/poll/trendingpolls';
        // 'http://pollchat.myappsdevelopment.co.in/api/v1/poll/trendingpolls';
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    try {
      homeModelController.loading.value = true;
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        homeModelController.tranding.clear();
        final jsonData = jsonDecode(response.body);

        log("all Tranding Polls ====> ${jsonDecode(response.body)}");
        setState(() {
          List<dynamic> list = jsonData['polls'];
          homeModelController.tranding.value = list.toList();
        });

        log("all Pinned Polls length ====> ${homeModelController.tranding.length}");
        homeModelController.loading.value = false;
      } else {
        homeModelController.loading.value = false;
        throw Exception(
            'Failed to fetch poll search results: ${response.reasonPhrase}');
      }
    } on Exception catch (e) {
      // loading.value = false;
      Utils.snackBar("Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverPersistentHeader(
                pinned: true,
                floating: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 60.0,
                  maxHeight: 80.0,
                  child: Container(
                    color: Colors.white,
                    child: Header(),
                  ),
                ),
              ),
            ],
            body: Obx(
              () {
                if (homeModelController.loading.isTrue) {
                  return const Center(
                    child: ShimmerPollCard(
                      itemCount: 3,
                    ),
                  );
                }
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Moments(),
                      ),
                    ),
                    const TopList(),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          allPinnedPollsPinnedPolls();
                          Get.toNamed(RouteName.pinnedpolls);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Show Your Pinned Polls",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Image.asset(
                              'assets/images/pinn.png',
                              height: 24,
                              width: 24,
                              color: AppColor.purpleColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          Get.to(const TrandingPollScreen());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Show Your Trending Polls",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Image.asset(
                              'assets/images/trands.png',
                              height: 24,
                              width: 24,
                              color: AppColor.purpleColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    if (homeModelController.allPolls.isNotEmpty)
                      ...homeModelController.allPolls.map((poll) {
                        if (poll == 'advertisement') {
                          return const SizedBox.shrink();
                        }
                        return PollCard(
                          isProfile: false,
                          isPinnedPolls: false,
                          pollModel: poll,
                          user: homeModelController.singleUser,
                        );
                      }),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
