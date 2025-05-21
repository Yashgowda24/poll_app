// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/view/action_view/components/reels/content.dart';
import 'package:poll_chat/view_models/controller/music_view_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class Posts extends StatefulWidget {
  final String type;

  Posts({Key? key, required this.type}) : super(key: key);

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  VideoPlayerController? _videoPlayerController;

  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  bool _isLoading = true;
  bool _hasError = false;
  UserPreference userPreference = UserPreference();
  @override
  void initState() {
    fetchActionData();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    super.dispose();
  }

  final player = AudioPlayer();
  final musicModelController = Get.put(MusicViewModel());
  List<dynamic>? actionUrls;
  Future<void> fetchActionData() async {
    try {
      String? authToken = await userPreference.getAuthToken();
      var headers = {'Authorization': 'Bearer $authToken'};
      setState(() {
        _isLoading = true;
      });
      var request = http.Request(
        'GET',
        Uri.parse(
          '${AppUrl.baseUrl}/api/v1/action/all'
          // 'https://poll-chat.onrender.com/api/v1/action/all',
          // 'https://pollchat.myappsdevelopment.co.in/api/v1/action/all',
        ),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> responseData = jsonDecode(responseBody);
        if (responseData.containsKey('actions')) {
          List<dynamic> friendActions = responseData['actions'];
          if (friendActions.isNotEmpty) {
            actionUrls = friendActions;
            print("Fetched URLs from the poll are: $actionUrls");
          } else {
            print('No friend actions found');
          }
        } else {
          print('friendactions key not found in API response');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_hasError) {
      return const Center(
        child: Text('Actions Not Found'),
      );
    } else if (actionUrls!.isNotEmpty) {
      return Swiper(
        itemBuilder: (BuildContext context, int index) {
          // musicModelController
          //     .playMusic(actionUrls![index]['musicId']?['music'] ?? "no music");
          return ContentScreen(
            src: actionUrls![index],
          );
        },
        itemCount: actionUrls!.length,
        scrollDirection: Axis.vertical,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            _buildBody(),
          ],
        ),
      ),
    );
  }
}
