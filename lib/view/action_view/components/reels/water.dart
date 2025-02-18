import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoDownloadAndPlayScreen extends StatefulWidget {
  @override
  _VideoDownloadAndPlayScreenState createState() =>
      _VideoDownloadAndPlayScreenState();
}

class _VideoDownloadAndPlayScreenState
    extends State<VideoDownloadAndPlayScreen> {
  VideoPlayerController? _videoPlayerController;
  bool downloading = false;
  String progress = '';
  List<String> downloadedFiles = [];
  late String _watermarkPath;
  // final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  @override
  void initState() {
    super.initState();
    _loadWatermarkImage();
  }

  Future<void> _loadWatermarkImage() async {
    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List list = data.buffer.asUint8List();
    final file = File('${(await getTemporaryDirectory()).path}/watermark.png');
    await file.writeAsBytes(list);
    setState(() {
      _watermarkPath = file.path;
    });
  }

  Future<void> _downloadVideo(String url) async {
    setState(() {
      downloading = true;
      progress = "Downloading...";
    });

    try {
      final dio = Dio();
      var status = await Permission.storage.status;

      if (status.isDenied) {
        status = await Permission.storage.request();
        if (!status.isDenied) {
          setState(() {
            progress = "Storage permission not granted";
            downloading = false;
          });
          return;
        }
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

      final watermarkedPath =
          '${directory.path}/watermarked_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final finalPath =
          '${directory.path}/final_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Add watermark and text to video
      await _addWatermarkAndTextToVideo(path, watermarkedPath, finalPath);

      setState(() {
        progress =
            "Video downloaded, watermarked, and text added successfully!";
        downloadedFiles.add(finalPath);
      });

      print('Final video saved at: $finalPath');

      // Check if the file exists
      final file = File(finalPath);

      print('File exists and is saved correctly.');
      _videoPlayerController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
        });
    } catch (e) {
      setState(() {
        progress = "Failed to download, watermark, or add text to video.";
      });
      print(e);
    }

    setState(() {
      downloading = false;
    });
  }

  Future<void> _addWatermarkAndTextToVideo(
      String videoPath, String watermarkedPath, String finalPath) async {
    try {
      final command =
          '-i $videoPath -i $_watermarkPath -filter_complex "overlay=10:10,drawtext=text=\'PollApp\':x=10:y=10:fontsize=24:fontcolor=white" -codec:a copy $watermarkedPath';
      //final result = await _flutterFFmpeg.execute(command);
      //print("FFmpeg Command Result: $result");

      final moveCommand = 'mv $watermarkedPath $finalPath';
      //await _flutterFFmpeg.execute(moveCommand);

      setState(() {
        progress = "Watermark and text added successfully!";
      });
    } catch (e) {
      setState(() {
        progress = "Failed to add watermark and text to video.";
      });
      print("Failed to add watermark and text to video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download and Play Video'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _downloadVideo(
                    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4'); // Replace with your video URL
              },
              child: Text('Download and Play Video'),
            ),
            SizedBox(height: 20),
            Text(progress),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }
}





// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';

// class VideoTrimmerScreen extends StatefulWidget {
//   @override
//   _VideoTrimmerScreenState createState() => _VideoTrimmerScreenState();
// }

// class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
//   final _picker = ImagePicker();
//   XFile? _videoFile;
//   VideoPlayerController? _videoPlayerController;
//   double _startTime = 0.0;
//   double _duration = 5.0; // Default duration of 5 seconds
//   double _videoLength = 0.0;

//   final _startTimeController = TextEditingController();
//   final _durationController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _videoPlayerController?.dispose();
//     _startTimeController.dispose();
//     _durationController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickVideo() async {
//     final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _videoFile = pickedFile;
//         _videoPlayerController =
//             VideoPlayerController.file(File(_videoFile!.path))
//               ..initialize().then((_) {
//                 _videoLength =
//                     _videoPlayerController!.value.duration.inSeconds.toDouble();
//                 _startTime = 0.0;
//                 _duration = _videoLength >= 5.0
//                     ? 5.0
//                     : _videoLength; // Set a default duration
//                 _startTimeController.text = _formatTime(_startTime);
//                 _durationController.text = _formatTime(_duration);
//                 setState(() {}); // Update the UI to show the video player
//                 _videoPlayerController!.play();
//               });
//       });
//     }
//   }

//   Future<void> _trimVideo() async {
//     if (_videoFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a video first')),
//       );
//       return;
//     }

//     final inputPath = _videoFile!.path;
//     final outputPath = '${inputPath}_trimmed.mp4';
//     final startTime = _formatTime(_startTime);
//     final duration = _formatTime(_duration);

//     final command =
//         '-i $inputPath -ss $startTime -t $duration -c copy $outputPath';

//     final session = await FFmpegKit.execute(command);
//     final returnCode = await session.getReturnCode();

//     if (returnCode!.isValueSuccess()) {
//       setState(() {
//         _videoFile =
//             XFile(outputPath); // Update the video file to the trimmed version
//         _videoPlayerController = VideoPlayerController.file(File(outputPath))
//           ..initialize().then((_) {
//             setState(() {}); // Update the UI to show the trimmed video
//           });
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Video trimmed successfully')),
//       );
//     } else if (returnCode.isValueError()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error while trimming video')),
//       );
//     }
//   }

//   String _formatTime(double seconds) {
//     final minutes = (seconds / 60).floor();
//     final secs = (seconds % 60).toInt();
//     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Trimmer'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal:
//                 screenWidth * 0.05, // 5% padding from the left and right
//             vertical: 16.0,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (_videoPlayerController != null &&
//                   _videoPlayerController!.value.isInitialized) ...[
//                 AspectRatio(
//                   aspectRatio: _videoPlayerController!.value.aspectRatio,
//                   child: VideoPlayer(_videoPlayerController!),
//                 ),
//                 SizedBox(height: 16),
//               ],
//               ElevatedButton(
//                 onPressed: _pickVideo,
//                 child: Text('Pick Video'),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Start Time: ${_formatTime(_startTime)}',
//                 style: TextStyle(fontSize: 16),
//               ),
//               Slider(
//                 min: 0.0,
//                 max: _videoLength > 0 ? _videoLength : 1.0,
//                 value: _startTime,
//                 onChanged: (value) {
//                   setState(() {
//                     _startTime = value;
//                     if (_startTime + _duration > _videoLength) {
//                       _duration = _videoLength - _startTime;
//                       _durationController.text = _formatTime(_duration);
//                     }
//                     _startTimeController.text = _formatTime(_startTime);
//                   });
//                 },
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Duration: ${_formatTime(_duration)}',
//                 style: TextStyle(fontSize: 16),
//               ),
//               Slider(
//                 min: 0.0,
//                 max: _videoLength - _startTime,
//                 value: _duration,
//                 onChanged: (value) {
//                   setState(() {
//                     _duration = value;
//                     _durationController.text = _formatTime(_duration);
//                   });
//                 },
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _trimVideo,
//                 child: Text('Trim Video'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
