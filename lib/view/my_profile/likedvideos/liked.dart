import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<String> videoUrls = [];
  List<String> imageUrls = [];
  bool isLoading = true;
  UserPreference userPreference = UserPreference();

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $authToken'};
    print(authToken);

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/saved/action'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 201) {
      // Changed from 201 to 200 for successful response
      var responseData = json.decode(await response.stream.bytesToString());

      // Print the response data for debugging
      print('Response Data: $responseData');

      List<dynamic> savedActions = responseData['saved'];
      setState(() {
        videoUrls = savedActions
            .where((action) {
              if (action['actionId'] != null &&
                  action['actionId']['action'] != null) {
                String actionUrl = action['actionId']['action'];
                return actionUrl.endsWith('.mp4');
              }
              return false;
            })
            .map<String>((action) => action['actionId']['action'])
            .toList();

        imageUrls = savedActions
            .where((action) {
              if (action['actionId'] != null &&
                  action['actionId']['action'] != null) {
                String actionUrl = action['actionId']['action'];
                return actionUrl.endsWith('.jpg') || actionUrl.endsWith('.png');
              }
              return false;
            })
            .map<String>((action) => action['actionId']['action'])
            .toList();
        print('Video URLs: $videoUrls');
        print('Image URLs: $imageUrls');
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 50,
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videoUrls.length + imageUrls.length,
              itemBuilder: (context, index) {
                String url;
                bool isVideo;

                if (index < videoUrls.length) {
                  url = videoUrls[index];
                  isVideo = true;
                } else {
                  url = imageUrls[index - videoUrls.length];
                  isVideo = false;
                }

                return MediaItem(url: url, isVideo: isVideo);
              },
            ),
    );
  }
}

class MediaItem extends StatefulWidget {
  final String url;
  final bool isVideo;

  MediaItem({required this.url, required this.isVideo});

  @override
  _MediaItemState createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _controller = VideoPlayerController.network(widget.url);
      _initializeVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
      _controller.play();
    } else {
      _isLoading = false; // No need to initialize VideoPlayer for images
    }
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            } else {
              return Center(
                  child: CircularProgressIndicator()); // Show loading spinner
            }
          },
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(widget.url, fit: BoxFit.cover),
      );
    }
  }
}
