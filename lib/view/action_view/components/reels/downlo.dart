// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:video_player/video_player.dart';

// class VideoDownloader extends StatefulWidget {
//   @override
//   _VideoDownloaderState createState() => _VideoDownloaderState();
// }

// class _VideoDownloaderState extends State<VideoDownloader> {
//   bool downloading = false;
//   String progress = "";
//   String filePath = "";
//   VideoPlayerController? _controller;

//   Future<void> downloadVideo() async {
//     setState(() {
//       downloading = true;
//       progress = "Downloading...";
//     });

//     try {
//       final dio = Dio();
//       // Replace with your API URL
//       final url =
//           "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4";

//       var status = await Permission.storage.request();
//       if (status.isGranted) {
//         setState(() {
//           progress = "Storage permission not granted";
//           downloading = false;
//         });
//         return;
//       }

//       final directory = await getExternalStorageDirectory();
//       final path = '${directory!.path}/downloaded_video.mp4';

//       await dio.download(
//         url,
//         path,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             setState(() {
//               progress =
//                   "Downloading: ${(received / total * 100).toStringAsFixed(0)}%";
//             });
//           }
//         },
//       );

//       setState(() {
//         progress = "Video downloaded successfully!";
//         filePath = path;
//       });

//       print('Video saved at: $path');

//       // Check if the file exists
//       final file = File(path);
//       if (await file.exists()) {
//         print('File exists and is saved correctly.');
//         _controller = VideoPlayerController.file(file)
//           ..initialize().then((_) {
//             setState(() {});
//             _controller!.play();
//           });
//       } else {
//         print('File does not exist.');
//       }
//     } catch (e) {
//       setState(() {
//         progress = "Failed to download video.";
//       });
//       print(e);
//     }

//     setState(() {
//       downloading = false;
//     });
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Downloader'),
//       ),
//       body: Center(
//         child: downloading
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 20),
//                   Text(progress),
//                 ],
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: downloadVideo,
//                     child: Text('Download Video'),
//                   ),
//                   SizedBox(height: 20),
//                   Text(progress),
//                   if (filePath.isNotEmpty) Text('File path: $filePath'),
//                   if (_controller != null && _controller!.value.isInitialized)
//                     AspectRatio(
//                       aspectRatio: _controller!.value.aspectRatio,
//                       child: VideoPlayer(_controller!),
//                     ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class VideoDownloader extends StatefulWidget {
  @override
  _VideoDownloaderState createState() => _VideoDownloaderState();
}

class _VideoDownloaderState extends State<VideoDownloader> {
  List<String> videoUrls = [
    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",

    // Add more video URLs as needed
  ];

  List<String> downloadedFiles = [];
  bool downloading = false;
  String progress = "";
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _downloadVideos();
  }

  Future<void> _downloadVideos() async {
    for (var url in videoUrls) {
      await _downloadVideo(url);
    }
  }

  Future<void> _downloadVideo(String url) async {
    setState(() {
      downloading = true;
      progress = "Downloading...";
    });

    try {
      final dio = Dio();
      var status = await Permission.storage.request();
      if (status.isGranted) {
        setState(() {
          progress = "Storage permission not granted";
          downloading = false;
        });
        return;
      }

      final directory = await getExternalStorageDirectory();
      final path =
          '${directory!.path}/downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress =
                  "Downloading: ${(received / total * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      setState(() {
        progress = "Video downloaded successfully!";
        downloadedFiles.add(path);
      });

      print('Video saved at: $path');

      // Check if the file exists
      final file = File(path);
      if (await file.exists()) {
        print('File exists and is saved correctly.');
        _controller = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {});
            _controller!.play();
          });
      } else {
        print('File does not exist.');
      }
    } catch (e) {
      setState(() {
        progress = "Failed to download video.";
      });
      print(e);
    }

    setState(() {
      downloading = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Downloader'),
      ),
      body: Center(
        child: downloading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(progress),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _downloadVideos,
                    child: const Text('Download Videos'),
                  ),
                  const SizedBox(height: 20),
                  Text(progress),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: downloadedFiles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Video ${index + 1}'),
                          subtitle: Text(downloadedFiles[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
