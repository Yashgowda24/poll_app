import 'dart:io';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoFilterScreen extends StatefulWidget {
  @override
  _VideoFilterScreenState createState() => _VideoFilterScreenState();
}

class _VideoFilterScreenState extends State<VideoFilterScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _inputVideoPath;
  String? _outputVideoPath;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    // requestPermissions(); // Request permissions at the start
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply Filter to Video'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _recordVideo,
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue,
                child: Text(
                  'Long Press to Record Video',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_inputVideoPath != null)
              ElevatedButton(
                onPressed: () async {
                  _outputVideoPath =
                      '${(await getApplicationDocumentsDirectory()).path}/output_video.mp4';
                  await applyFilterToVideo(_inputVideoPath!, _outputVideoPath!);
                },
                child: Text('Apply Filter'),
              ),
            SizedBox(height: 20),
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized)
              ElevatedButton(
                onPressed: () {
                  _videoPlayerController!.play();
                },
                child: Text('Play Filtered Video'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermissions() async {
    final status = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();

    if (status[Permission.camera]!.isDenied ||
        status[Permission.microphone]!.isDenied ||
        status[Permission.storage]!.isDenied) {
      _showPermissionDeniedDialog();
    } else if (status[Permission.camera]!.isPermanentlyDenied ||
        status[Permission.microphone]!.isPermanentlyDenied ||
        status[Permission.storage]!.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            'Camera, Microphone, and Storage permissions are required to record and save video files. Please grant the permissions in the app settings.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _recordVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _inputVideoPath = pickedFile.path;
      });

      _initializeVideoPlayer(
          _inputVideoPath!); // Initialize video player to show the recorded video
    } else {
      print('No video recorded.');
    }
  }

  Future<void> applyFilterToVideo(String inputPath, String outputPath) async {
    final file = File(outputPath);
    if (file.existsSync()) {
      file.deleteSync();
    }

    String filterCommand =
        "-i $inputPath -vf 'colorchannelmixer=0.393:0.769:0.189:0.349:0.686:0.168:0.272:0.534:0.131' $outputPath";

    try {
      await FFmpegKit.executeAsync(filterCommand, (session) async {
        final returnCode = await session.getReturnCode();
        final allLogs = await session.getAllLogsAsString();
        final failStackTrace = await session.getFailStackTrace();

        print(
            "FFmpeg Command: $filterCommand"); // Print the filter command for debugging
        print("Logs: $allLogs"); // Print all logs for better debugging
        print(
            "Error Logs: $failStackTrace"); // Print error logs for better debugging

        if (ReturnCode.isSuccess(returnCode)) {
          print("Filter applied successfully!");
          setState(() {
            _inputVideoPath = outputPath;
          });
          _initializeVideoPlayer(
              outputPath); // Initialize the video player to show the filtered video
        } else if (ReturnCode.isCancel(returnCode)) {
          print("Filter application cancelled.");
        } else {
          print("Filter application failed.");
        }
      });
    } catch (e) {
      print("Exception while running FFmpeg: $e");
    }
  }

  Future<void> _initializeVideoPlayer(String videoPath) async {
    _videoPlayerController = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {}); // Refresh the UI to display the video
      });
  }
}
