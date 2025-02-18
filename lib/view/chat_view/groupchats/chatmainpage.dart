import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/chat_view/video.dart';
import 'package:poll_chat/view/home/components/single_poll_card.dart';
import 'package:poll_chat/view/my_profile/useractions/postsuser.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class GroupChatPage extends StatefulWidget {
  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
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
  //dynamic user = Get.arguments;
  // Map<String, dynamic> src = Get.arguments;
  dynamic user;
  String? src;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;

  AudioPlayer _audioPlayer = AudioPlayer();

  void _playRecordedFile() async {
    if (_recordedFilePath != null) {
      await _audioPlayer.play(
        _recordedFilePath as Source,
      );
    }
  }

  @override
  void initState() {
    _initializeRecorder();

    user = Get.arguments['user'];
    src = Get.arguments['action'];
    createChat();
    print(src);
    super.initState();
    _scrollController = ScrollController();

    Timer.periodic(const Duration(seconds: 2), (Timer t) {
      getMessage();
    });
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

    super.dispose();
  }

  Future<void> _startRecording() async {
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
    if (!_isRecorderInitialized) {
      print('Recorder is not initialized');
      return;
    }
    try {
      String? path = await _recorder.stopRecorder();
      setState(() {
        _selectedImagePath = path;
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
    sendMessage(message).then((_) {
      setState(() {
        getMessage();
        scrollToBottom();

        if (_selectedImagePath != null || _selectedVideoPath != null) {
          _messages.add({
            "message": message,
            "sent": true,
            "seen": false,
            "time": DateTime.now(),
            "media": _selectedImagePath ?? _selectedVideoPath,
          });
          _selectedImagePath = null;
          _selectedVideoPath = null;
        } else {
          _messages.add({
            "message": message,
            "sent": true,
            "seen": false,
            "time": DateTime.now(),
            "media": null,
          });
        }
      });

      _controller.clear();
      _scrollController!.animateTo(
        _scrollController!.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }).catchError((error) {
      print("Failed to send message: $error");
    });
  }

  Future<void> createChat() async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json'
    };
    var url = Uri.parse(
        'http://pollchat.myappsdevelopment.co.in/api/v1/chat/create/');
    var body = json.encode({"friendId": '${user['_id']}'});

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        scrollToBottom();
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

  Future<void> actionshare() async {
    if (user != null && src != null) {
      await sendMessage(src.toString());
    }
  }

  Future<void> getMessage() async {
    String? authToken = await userPreference
        .getAuthToken(); // Assuming this method retrieves the auth token
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
              // tz.TZDateTime createdAt = message['createdAt'] != null
              //     ? tz.TZDateTime.from(
              //         DateTime.parse(message['createdAt']).toUtc(),
              //         gmtLocation,
              //       )
              //     : tz.TZDateTime.now(gmtLocation);

              //formattedTime = _formatDateTime(createdAt);

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

  Future<void> sendMessage(String message) async {
    List<String> chatIds = [chatId];
    List<String> friendIds = [
      '665ecd2f7d3e9f3b66f28e76',
      '665e88b87d3e9f3b66f27502'
    ];
    String? authToken = await userPreference.getAuthToken();

    var headers = {
      'Authorization': 'Bearer $authToken',
    };

    var body = {
      'chatIds': chatIds.join(','),
      'friendIds': friendIds.join(','),
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

  // void _handleCameraClick() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImagePath = pickedFile.path;
  //     });
  //   }
  // }
  void _handleCameraClick() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
        _selectedVideoPath = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      });
    }
  }

  // void _handleGalleryClick() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImagePath = pickedFile.path;
  //     });
  //   }
  // }

  void _handleGalleryClick() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Pick Image'),
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
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Pick Video'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await picker.pickVideo(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedVideoPath = pickedFile.path;
                      _selectedImagePath = null;
                      _videoPlayerController =
                          VideoPlayerController.file(File(_selectedVideoPath!))
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
        );
      },
    );
  }

  void _chooseIamge() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  _handleCameraClick();
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Get.back();
                  _handleGalleryClick();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Get Location'),
                onTap: () {
                  _getCurrentLocation();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Share File'),
                onTap: () {
                  _selectFile();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _messages.add({
          "message":
              "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
          "sent": true,
          "seen": false,
          "time": DateTime.now(),
        });
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _selectFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  Widget _buildSentMessage(Map<String, dynamic> message) {
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
            if (message['media'] is String &&
                !message['media'].endsWith('.mp4'))
              Image.network(
                message['media'],
                width: 150,
                height: 150,
              ),
            if (message['message'] is String)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SinglePollCard(url: message['message'].toString()),
                    ),
                  );
                },
                child: Text(
                  message['message'],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            if (message['pollUrl'] is String &&
                !message['pollUrl'].endsWith('+'))
              if (message['message'] is String)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SinglePollCard(url: message['message'].toString()),
                      ),
                    );
                  },
                  child: const Text(
                    '',
                  ),
                ),
            if (message['media'] is String && message['media'].endsWith('.mp4'))
              if (message['media'] is String)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(url: message['media'].toString()),
                      ),
                    );
                  },
                  child: Text(
                    message['media'].toString(),
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

  void _handleAudioCall() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CallMainPage(),
    //   ),
    // );
  }

  void _handleVideoCall() {}

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
              padding:
                  const EdgeInsets.only(left: 40, top: 12), // Adjusted padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipPath(
                    clipper: OctagonClipper(),
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteName.chatuserProfile, arguments: user);
                      },
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Image.network(
                          user['profilePhoto'] ?? "",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    user['name'] ?? "",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center, // Ensure text alignment
                  ),
                  SizedBox(
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
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.videocam_outlined,
                      color: AppColor.whiteColor,
                    ),
                    onPressed: _handleVideoCall,
                  ),
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
                  // tz.TZDateTime messageTime = globalMessages[index]['time'];
                  // String formattedTime = _formatDateTime(messageTime);
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
                      child: Center(child: CircularProgressIndicator()),
                    ),
            if (_recordedFilePath != null)
              Text('Recorded file: ${_recordedFilePath}'),
            SizedBox(height: 10),
            if (_recordedFilePath != null)
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => AudioPlayerWidget(
                  //             recordedFilePath: _recordedFilePath.toString(),
                  //           )),
                  // );
                },
                child: Text('Play Recorded File'),
              ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text('Recorded file: $_recordedFilePath'),
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
                    // GestureDetector(
                    //   onTap: () => _showOptions(),
                    //   child: Image.asset(
                    //     'assets/images/newcamera.png',
                    //     height: 24,
                    //     width: 24,
                    //   ),
                    // ),
                    const SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () => _chooseIamge(),
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
                      onLongPressStart: (details) async {
                        await _startRecording();
                      },
                      onLongPressEnd: (details) async {
                        await _stopRecording();
                      },
                      child: Image.asset(
                        'assets/images/microphone.png',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       ElevatedButton(
            //         onPressed: _startRecording,
            //         child: Text('Start Recording'),
            //       ),
            //       ElevatedButton(
            //         onPressed: _stopRecording,
            //         child: Text('Stop Recording'),
            //       ),
            //       if (!_isRecorderInitialized)
            //         Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: Text(
            //             'Recorder is not initialized',
            //             style: TextStyle(color: Colors.red),
            //           ),
            //         ),
            //     ],
            //   ),
            // ),
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
                        setState(() async {
                          _controller.text = newValue;

                          await getMessage();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () {
                        if (_controller.text.isNotEmpty ||
                            _selectedImagePath != null ||
                            _selectedVideoPath != null) {
                          _sendMessage(_controller.text);
                        }
                      },
                      child: Image.asset(
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
