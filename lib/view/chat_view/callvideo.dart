import 'package:flutter/material.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCallWebView extends StatelessWidget {
  void _launchUrl() async {
    const url = '${AppUrl.baseUrl}/c016c724-54c7-4560-b455-8875e148b7a5';
    // 'https://poll-chat.onrender.com/c016c724-54c7-4560-b455-8875e148b7a5';
    // 'https://pollchat.videocall.myappsdevelopment.co.in/c016c724-54c7-4560-b455-8875e148b7a5';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle case when the URL cannot be launched
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebRTC Call'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchUrl,
          child: Text('Join Meeting'),
        ),
      ),
    );
  }
}
