import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/chat_view/video.dart';
import 'package:poll_chat/view/create_poll/customcemra.dart';
import 'package:poll_chat/view/home/components/single_poll_card.dart';
import 'package:poll_chat/view/my_profile/useractions/postsuser.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  var _selectedImagePath;
  String? _selectedVideoPath;
  VideoPlayerController? _videoPlayerController;
  ScrollController? _scrollController;
  UserPreference userPreference = UserPreference();
  var chatId;
  List<Map<String, dynamic>> globalMessages = [];
  dynamic user;
  dynamic src;
  String? action;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;
  String? filePathAudio;
  String? filePath;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _initializeAudioPlayer();
    _initializeRecorder();

    processArguments();
    createChat();

    Timer.periodic(const Duration(seconds: 2), (Timer t) {
      getMessage();
    });

    _scrollController = ScrollController();
  }

  void processArguments() {
    var arguments = Get.arguments;
    if (arguments != null) {
      if (arguments.containsKey('user') && arguments['user'] != null) {
        user = arguments['user'];
        action = arguments['action'];
      } else {
        src = arguments;
      }
    }
    print('User: $user');
    print('Src: $src');
  }

  Future<void> createChat() async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json'
    };
    var id = user != null ? user['_id'] : src['_id'];
    var url = Uri.parse(
        'http://pollchat.myappsdevelopment.co.in/api/v1/chat/create/');
    var body = json.encode({"friendId": id});

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        // scrollToBottom();
        if (responseBody.containsKey('alreadyChat') &&
            responseBody['alreadyChat'] != null) {
          chatId = responseBody['alreadyChat']['_id'];
          print('Chat created successfully. Chat ID: $chatId');
          actionshare();

          getMessage();
        } else {
          print('Chat ID not found in response');
        }
      } else {
        print(response.reasonPhrase);
        var responseBody = json.decode(response.body);
        Utils.snackBar("Error", responseBody['message']);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> _toggleAudioPlayback(String audioUrl) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(audioUrl));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  Future<void> _initializeRecorder() async {
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission not granted');
        throw RecordingPermissionException('Microphone permission not granted');
      }
      print('Opening audio session...');
      await _recorder.openRecorder();
      setState(() {
        _isRecorderInitialized = true;
        print('Recorder initialized successfully');
      });
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    _recorder.closeRecorder();
    _videoPlayerController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _downloadFile(String url) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      // Get the Downloads directory path
      final directory = await getExternalStorageDirectory();
      final downloadsDirectory = Directory('${directory!.path}/Download');
      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory.createSync();
      }

      final file = File('${downloadsDirectory.path}/downloaded_file.pdf');
      final raf = file.openSync(mode: FileMode.write);

      final contentLength =
          response.headers.value(HttpHeaders.contentLengthHeader);
      final totalBytes = int.parse(contentLength ?? '0');
      int downloadedBytes = 0;

      response.data.stream.listen(
        (List<int> chunk) {
          downloadedBytes += chunk.length;
          raf.writeFromSync(chunk);
          final progress = (downloadedBytes / totalBytes) * 100;
          print('Download progress: ${progress.toStringAsFixed(2)}%');
        },
        onDone: () {
          raf.closeSync();
          print('Download completed');
          setState(() {
            filePath = file.path;
          });
          print('File saved to: ${file.path}');
        },
        onError: (e) {
          print('Download failed: $e');
        },
      );
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location'),
                onTap: _getLocation,
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('File'),
                onTap: _pickFile,
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('Audio'),
                onTap: () async {
                  await _pickAudio();
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getLocation() async {
    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    } else {
      print('Location permission denied');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        filePath = result.files.single.path!;
      });
      Get.back();

      print('Picked file: $filePath');
    } else {
      print('No file selected.');
    }
  }

  _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      filePathAudio = result.files.single.path!;
      print('Picked audio file: $filePathAudio');
    } else {
      print('No file selected.');
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    if (!_isRecorderInitialized) {
      print('Recorder is not initialized');
      return;
    }
    try {
      await _recorder.startRecorder(
        toFile: 'audio_file.aac',
      );
      print('Recording started');
    } catch (e) {
      print('Error starting recorder: $e');
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    if (!_isRecorderInitialized) {
      print('Recorder is not initialized');
      return;
    }
    try {
      String? path = await _recorder.stopRecorder();
      setState(() {
        _recordedFilePath = path;
      });
      print('Recording stopped, file saved at: $path');
    } catch (e) {
      print('Error stopping recorder: $e');
    }
  }

  void scrollToBottom() {
    _scrollController!.animateTo(
      _scrollController!.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await sendMessage(message);
      setState(() {
        getMessage();
        scrollToBottom();
        Map<String, dynamic> messageMap = {
          "message": message,
          "sent": true,
          "seen": false,
          "time": DateTime.now(),
        };

        if (_selectedImagePath != null) {
          messageMap["media"] = _selectedImagePath;
          _selectedImagePath = null;
        } else if (_selectedVideoPath != null) {
          messageMap["media"] = _selectedVideoPath;
          _selectedVideoPath = null;
        } else if (_recordedFilePath != null) {
          messageMap["media"] = _recordedFilePath;
          _recordedFilePath = null;
        } else if (filePathAudio != null) {
          messageMap["media"] = filePathAudio;
          filePathAudio = null;
        } else if (filePath != null) {
          messageMap["media"] = filePath;
          filePath = null;
        } else {
          messageMap["media"] = null;
        }
        _messages.add(messageMap);
        _controller.clear();
        _scrollController!.animateTo(
          _scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (error) {
      print("Failed to send message: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> actionshare() async {
    if (user != null) {
      sendMessage(action!);
    }
  }

  Future<void> getMessage() async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json'
    };

    try {
      http.Response response = await http.get(
        Uri.parse(
            'http://pollchat.myappsdevelopment.co.in/api/v1/message/get/$chatId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          List<Map<String, dynamic>> messages =
              List<Map<String, dynamic>>.from(jsonResponse['messages']);

          setState(() {
            globalMessages.clear();
            globalMessages.addAll(messages.map((message) {
              return {
                "message": message['message'],
                "sent": message['sender'] == user['_id'],
                "seen": true,
                "time": message['createdAt'],
                "media": message['media'],
              };
            }).toList());
          });
        } else {
          print(jsonResponse['message']);
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Future<void> sendMessage(String message) async {
  //   String? authToken = await userPreference.getAuthToken();
  //   var headers = {'Authorization': 'Bearer $authToken'};
  //   var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(
  //           'http://pollchat.myappsdevelopment.co.in/api/v1/message/create/$chatId'));
  //   request.fields.addAll({'message': message});

  //   if (_selectedImagePath != null) {
  //     request.files
  //         .add(await http.MultipartFile.fromPath('media', _selectedImagePath));
  //   } else if (_selectedVideoPath != null) {
  //     request.files
  //         .add(await http.MultipartFile.fromPath('media', _selectedVideoPath!));
  //   } else {
  //     print("Proceeding without image.");
  //   }
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 201) {
  //     print(await response.stream.bytesToString());
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  Future<void> sendMessage(String message) async {
    List<String> chatIds = [chatId];
    // List<String> friendIds = [
    //   '665ecd2f7d3e9f3b66f28e76',
    //   '665e88b87d3e9f3b66f27502'
    // ];
    String? authToken = await userPreference.getAuthToken();

    var headers = {
      'Authorization': 'Bearer $authToken',
    };

    var body = {
      'chatIds': chatIds.join(','),
      //'friendIds': friendIds.join(','),
      'message': message,
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'http://pollchat.myappsdevelopment.co.in/api/v1/message/create'),
    );

    request.headers.addAll(headers);
    request.fields.addAll(body);

    if (_selectedImagePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('media', _selectedImagePath));
    } else if (_selectedVideoPath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('media', _selectedVideoPath!));
    } else if (_recordedFilePath != null) {
      request.files
          .add(await http.MultipartFile.fromPath('media', _recordedFilePath!));
    } else if (filePathAudio != null) {
      request.files
          .add(await http.MultipartFile.fromPath('media', filePathAudio!));
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('media', filePath!));
    }

    try {
      http.StreamedResponse response = await request.send();
      var responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        var responseJson = jsonDecode(responseString);
        print('Response: $responseJson');

        if (responseJson['sendMsgs'] != null &&
            responseJson['sendMsgs'].isNotEmpty) {
          for (var msg in responseJson['sendMsgs']) {
            print('Sent message details: $msg');
          }
        } else {
          print('No messages in response.');
        }
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        print('Response body: $responseString');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  final picker = ImagePicker();
  void _handleCameraClick(String source) async {
    if (source == "camera") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomCameraScreen(onImageCaptured: (path) {
            // setState(() {
            //    _selectedImagePath = pickedFile!.path;
            //   createPollViewModel.addImage(pickedProfile);
            // });

            setState(() {
              _selectedImagePath = path;
              _selectedVideoPath = null;
              _videoPlayerController?.dispose();
              _videoPlayerController = null;
              _recordedFilePath != null;
              filePathAudio != null;
              filePath != null;
            });
          }),
        ),
      );
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _selectedImagePath = pickedFile!.path;
        // createPollViewModel.addImage(pickedProfile);
      });
    }
  }

  void _handleGalleryClick() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      backgroundColor: AppColor.whiteColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Select Media',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const Icon(
                    Icons.photo,
                    color: AppColor.purpleColor,
                    size: 30,
                  ),
                  title: const Text(
                    'Select Image',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedImagePath = pickedFile.path;
                        _selectedVideoPath = null;
                        _videoPlayerController?.dispose();
                        _videoPlayerController = null;
                        _recordedFilePath != null;
                        filePath != null;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.video_library,
                    color: AppColor.purpleColor,
                    size: 30,
                  ),
                  title: const Text(
                    'Select Video',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await picker.pickVideo(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedVideoPath = pickedFile.path;
                        _selectedImagePath = null;
                        _videoPlayerController = VideoPlayerController.file(
                            File(_selectedVideoPath!))
                          ..initialize().then((_) {
                            setState(() {});
                            _videoPlayerController!.play();
                          });
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSentMessage(Map<String, dynamic> message) {
    // Safely get 'media' and 'message' values with null checks
    final media = message['media'] as String?;
    final messageText = message['message'] as String?;
    final pollUrl = message['pollUrl'] as String?;
    final time = message["time"] as String?;

    return Container(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColor.purpleColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (filePath != null && filePath!.endsWith('.pdf'))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        filePath = null;
                      });
                    },
                    child: const Icon(
                      Icons.delete,
                      color: AppColor.purpleColor,
                    ),
                  ),
                ],
              ),
            // Handle image media type
            if (media != null &&
                (media.endsWith('.jpg') || media.endsWith('.png')))
              Image.network(
                media,
                width: 150,
                height: 150,
              ),

            // Handle audio media type
            if (media != null &&
                (media.endsWith('.aac') || media.endsWith('.mp3')))
              Container(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (media.endsWith('.aac') || media.endsWith('.mp3'))
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              _toggleAudioPlayback(media);
                            });

                            // playMusic(media);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Audio File',
                                style: TextStyle(color: Colors.white),
                              ),

                              // Text(
                              //   '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')} / ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                              //   style: const TextStyle(
                              //       color: Colors.white, fontSize: 12),
                              // ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            if (messageText != null)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SinglePollCard(
                        url: messageText,
                      ),
                    ),
                  );
                },
                child: Text(
                  messageText,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

            if (pollUrl != null &&
                !pollUrl.endsWith('+') &&
                messageText != null)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SinglePollCard(
                        url: user['userId']['_id'],
                      ),
                    ),
                  );
                },
                child: const Text(''),
              ),

            // Handle video media type
            if (media != null && media.endsWith('.mp4'))
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        url: media,
                      ),
                    ),
                  );
                },
                child: Text(
                  media,
                ),
              ),
            if (media != null && (media.endsWith('.pdf')))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _downloadFile(media.toString());
                    },
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      filePath = null;
                    },
                    child: const Icon(
                      Icons.delete,
                      color: AppColor.purpleColor,
                    ),
                  )
                ],
              ),

            const SizedBox(height: 5.0),
            Text(
              time != null ? "${timeago.format(DateTime.parse(time))}" : '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(Map<String, dynamic> message) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColor.chatuser,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['sent'] ? user['_id'] : 'Other User',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5.0),
            if (message['media'] is String && message['media'].endsWith('.mp4'))
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(url: message['message'].toString()),
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Adjust aspect ratio as needed
                  child: VideoPlayerWidget(url: message['message'].toString()),
                ),
              ),
            if (message['message'] is String)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(url: message['message'].toString()),
                    ),
                  );
                },
                child: Text(
                  message['message'],
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            const SizedBox(height: 5.0),
            Text(
              "${timeago.format(DateTime.parse(message["time"]))}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl() async {
    const url =
        'https://pollchat.videocall.myappsdevelopment.co.in/c016c724-54c7-4560-b455-8875e148b7a5';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipPath(
                    clipper: OctagonClipper(),
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteName.chatuserProfile,
                            arguments: user ?? src);
                      },
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: (user != null && user['profilePhoto'] != null)
                            ? Image.network(
                                user['profilePhoto']!,
                                fit: BoxFit.cover,
                              )
                            : (src != null && src['profilePhoto'] != null
                                ? Image.network(
                                    src['profilePhoto']!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors
                                        .grey)), // Default placeholder if no image URL is available
                      ),
                    ),
                  ),
                  Text(
                    (user != null && user['name'] != null)
                        ? user['name']!
                        : (src != null && src['name'] != null
                            ? src['name']!
                            : 'Default Name'), // Default name if no valid name is available
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center, // Ensure text alignment
                  ),
                  const SizedBox(
                    height: 2,
                  )
                ],
              ),
            ),
            const Spacer(),
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.purpleColor,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.call_outlined,
                      color: AppColor.whiteColor,
                    ),
                    onPressed: () {
                      //_handleAudioCall();
                    },
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.videocam_outlined,
                        color: AppColor.whiteColor,
                      ),
                      onPressed: () {
                        _launchUrl();
                      }),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.5),
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            height: 1.0,
            color: Colors.grey,
          ),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        backgroundColor: AppColor.whiteColor,
        onRefresh: () => getMessage(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: globalMessages.length,
                itemBuilder: (context, index) {
                  var message = globalMessages[index];
                  bool isSentByCurrentUser = message['sent'];

                  return Container(
                    alignment: isSentByCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: isSentByCurrentUser
                        ? _buildReceivedMessage(message)
                        : _buildSentMessage(message),
                  );
                },
              ),
            ),
            if (_selectedImagePath != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(_selectedImagePath!),
                  width: 150,
                  height: 150,
                ),
              ),
            if (_selectedVideoPath != null)
              _videoPlayerController != null &&
                      _videoPlayerController!.value.isInitialized
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      width: 150,
                      height: 150,
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8.0),
                      width: 150,
                      height: 150,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            const SizedBox(height: 10),
            if (_recordedFilePath != null || filePathAudio != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      _isPlaying ? Icons.pause : Icons.play_arrow;
                    },
                    child: Text(_isPlaying ? 'Pause' : 'Play'),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _recordedFilePath = null;
                        filePathAudio = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            if (filePath != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {},
                      child: const Center(
                        child: Icon(Icons.picture_as_pdf),
                      )),
                  const SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        filePath = null;
                      });
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                height: 1.0,
                color: Colors.grey,
              ),
            ),
            Center(
              child: Container(
                width: 170,
                height: 50,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColor.purpleColor),
                    borderRadius: BorderRadius.circular(22)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _handleCameraClick("camera"),

                      // onTap: () {
                      //   Get.toNamed(CustomCameraScreen());
                      // },
                      child: Image.asset(
                        'assets/images/newcamera.png',
                        height: 24,
                        width: 24,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () => _handleGalleryClick(),
                      child: Image.asset(
                        'assets/images/gallary.png',
                        height: 24,
                        width: 24,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        _showOptionsBottomSheet();
                      },
                      child: const Icon(
                        Icons.pin_invoke,
                        color: AppColor.purpleColor,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onLongPressStart: (details) async {
                        await _startRecording();
                      },
                      onLongPressEnd: (details) async {
                        await _stopRecording();
                      },
                      onTap: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding:
                                  const EdgeInsets.only(bottom: 100, left: 150),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Hold for recording",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                        await Future.delayed(const Duration(seconds: 1));
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: _isRecording
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColor.purpleColor,
                              ),
                            )
                          : Image.asset(
                              'assets/images/microphone.png',
                              height: 24,
                              width: 24,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColor.pink2Color),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Your message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                      onChanged: (newValue) {
                        setState(() {
                          _controller.text = newValue;
                        });
                        getMessage();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () {
                        if (_controller.text.isNotEmpty ||
                            _selectedImagePath != null ||
                            _selectedVideoPath != null ||
                            _recordedFilePath != null ||
                            filePath != null ||
                            filePathAudio != null) {
                          _sendMessage(_controller.text);
                        }
                      },
                      child: _isLoading
                          ? const SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: AppColor.purpleColor,
                              ),
                            )
                          : Image.asset(
                              'assets/images/cta.png',
                              height: 32,
                              width: 32,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
