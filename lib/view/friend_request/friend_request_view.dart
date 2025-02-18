import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view/friend_request/components/friendslist.dart';
import 'package:poll_chat/view/friend_request/components/sendrequest.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:http/http.dart' as http;

class FriendRequestView extends StatefulWidget {
  const FriendRequestView({super.key});

  @override
  State<StatefulWidget> createState() => _FriendRequestViewState();
}

class _FriendRequestViewState extends State<FriendRequestView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  UserPreference userPreference = UserPreference();
  final homeViewController = Get.put(HomeViewModelController());
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> cencalfriendreq() async {
    var token = await userPreference.getAuthToken();
    var userid = await userPreference.getUserID();
    print('Token: $token'); // Check token
    var headers = {'Authorization': 'Bearer $token'};
    var url = Uri.parse(
        'https://pollchat.myappsdevelopment.co.in/api/v1/friend/delete/');
    var request = http.Request('DELETE', url);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);
        setState(() {
          //await _fetchAccounts();
        });
      } else {
        print('Failed to delete friend: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> recevedfriendreqDelete() async {
    var token = await userPreference.getAuthToken();
    //var userid = await userPreference.getUserID();
    print('Token: $token'); // Check token
    var headers = {'Authorization': 'Bearer $token'};
    var url = Uri.parse(
        'https://pollchat.myappsdevelopment.co.in/api/v1/friend/received/delete');
    var request = http.Request('DELETE', url);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);
        setState(() {
          //await _fetchAccounts();
        });
      } else {
        print('Failed to delete friend: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Center(
            child: Text(
              "Friend Requests",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () async {
                  recevedfriendreqDelete();
                  homeViewController.sendRequest();
                  homeViewController.update();

                  //cencalfriendreq();
                },
                child: Image.asset(
                  'assets/images/deleten.png',
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ]),
      body: SafeArea(
          child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
                controller: _tabController,
                indicatorColor: AppColor.purpleColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColor.purpleColor,
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                unselectedLabelColor: AppColor.greyColor,
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 16),
                tabs: const [
                  Tab(
                    text: "Received",
                  ),
                  Tab(
                    text: "Sent",
                  ),
                ]),
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: const [
              FriendsListScreen(),
              SendRequestScreen(),
            ],
          ))
        ],
      )),
    );
  }
}
