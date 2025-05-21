import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/view/my_profile/useractions/contentuser.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class PostsUserById extends StatefulWidget {
  var id;
  PostsUserById(this.id);

  @override
  State<PostsUserById> createState() => _PostsUserByIdState();
}

class _PostsUserByIdState extends State<PostsUserById> {
  VideoPlayerController? _videoPlayerController;
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  bool _isLoading = false;
  bool _hasError = false;
  UserPreference userPreference = UserPreference();
  List<dynamic> actions = [];

  @override
  void initState() {
    super.initState();
    fetchUserActions();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> fetchUserActions() async {
    try {
      String? authToken = await userPreference.getAuthToken();
      String? userid = await userPreference.getUserID();
      var headers = {'Authorization': 'Bearer $authToken'};

      setState(() {
        _isLoading = true;
      });

      var request = http.Request(
        'GET',
        Uri.parse(
            '${AppUrl.baseUrl}/api/v1/action/user/${widget.id}'),
      );
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        print('Response: $decodedResponse');

        if (decodedResponse['status']) {
          print(decodedResponse['message']);
          setState(() {
            actions = decodedResponse['actions'];
          });
        } else {
          setState(() {
            _hasError = true;
          });
        }
      } else {
        setState(() {
          _hasError = true;
        });
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      print('Error: $e');
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
        child: Text('Data Not Found'),
      );
    } else if (actions.isNotEmpty) {
      return Swiper(
        itemBuilder: (BuildContext context, int index) {
          var action = actions[index];
          return ContentUserScreen(
            src: action,
          );
        },
        itemCount: actions.length,
        scrollDirection: Axis.vertical,
      );
    }
    return Container();
  }

  // Widget _buildBody() {
  //   if (_isLoading) {
  //     return const Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   } else if (_hasError) {
  //     return const Center(
  //       child: Text('Data Not Found'),
  //     );
  //   } else if (actions.isNotEmpty) {
  //     return ListView.builder(
  //       itemCount: actions.length,
  //       itemBuilder: (context, index) {
  //         var action = actions[index];
  //         print('Action at index $index: $action');

  //         if (action != null) {
  //           return ContentUser(
  //             src: action,
  //           );
  //         } else {
  //           print('Action format is invalid at index $index: $action');
  //           return const Center(child: Text('Invalid action format'));
  //         }
  //       },
  //     );
  //   } else {
  //     return const Center(
  //       child: Text(
  //         'No actions available',
  //         style: TextStyle(color: AppColor.whiteColor),
  //       ),
  //     );
  //   }
  // }

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

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller!.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
        : Center(child: Container());
  }
}
