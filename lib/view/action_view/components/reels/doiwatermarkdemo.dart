// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
class DownloadButton extends StatefulWidget {
  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  final String videoUrl = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"; // Replace with your video URL
  bool isDownloading = false;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<void> downloadAndDisplayVideo() async {
    setState(() {
      isDownloading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'), // Replace with your backend URL
        body: {
          'videoFile': videoUrl, // Pass video URL to backend for processing
        },
      );

      if (response.statusCode == 200) {
        final videoUrl = response.body[0];
        setState(() {
          _controller = VideoPlayerController.network(videoUrl)
            ..initialize().then((_) {
              setState(() {});
            });
        });
      } else {
        throw Exception('Failed to apply watermark');
      }
    } catch (e) {
      print("Error downloading and displaying video: $e");
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_controller != null && _controller!.value.isInitialized) ...[
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ] else if (isDownloading) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text("Downloading and processing video..."),
        ] else ...[
          ElevatedButton(
            onPressed: () async {
              await downloadAndDisplayVideo();
            },
            child: const Text('Download and Display Video'),
          ),
        ],
      ],
    );
  }
}