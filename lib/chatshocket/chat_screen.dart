import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'User.dart';
import 'chat_bubble.dart';
import 'chat_message_model.dart';
import 'chat_title.dart';
import 'global.dart';
import 'socket_utils.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen() : super();

  final String title = "Chat Screen";

  static const String ROUTE_ID = 'chat_screen';

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController? _chatTfController;
  List<ChatMessageModel>? _chatMessages;
  User? _chatUser;
  ScrollController? _chatLVController;
  UserOnlineStatus? _userOnlineStatus;

  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _userOnlineStatus = UserOnlineStatus.connecting;
    _chatLVController = ScrollController(initialScrollOffset: 0.0);
    _chatTfController = TextEditingController();
    _chatUser = G.toChatUser!;
    _chatMessages = [];
    _initSocketListeners();
    _checkOnline();
  }

  _initSocketListeners() async {
    G.socketUtils!.setOnUserConnectionStatusListener(onUserConnectionStatus);
    G.socketUtils!.setOnChatMessageReceivedListener(onChatMessageReceived);
    G.socketUtils!.setOnMessageBackFromServer(onMessageBackFromServer);
  }

  _checkOnline() async {
    ChatMessageModel chatMessageModel = ChatMessageModel(
      to: G.toChatUser!.id,
      from: G.loggedInUser!.id,
    );
    G.socketUtils!.checkOnline(chatMessageModel);
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
                  // _getCurrentLocation();
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

  void _selectFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
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
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _handleGalleryClick();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleCameraClick() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _handleGalleryClick() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _handleAudioCall() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CallMainPage(),
    //   ),
    // );
  }

  void _handleVideoCall() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => GetUserMediaSample(callType: CallType.video),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: ChatTitle(
      //     chatUser: G.toChatUser!,
      //     userOnlineStatus: _userOnlineStatus!,
      //   ),
      // ),
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/music2.png'),
            ),
            const SizedBox(width: 10),
            ChatTitle(
              chatUser: G.toChatUser!,
              userOnlineStatus: _userOnlineStatus!,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: _handleAudioCall,
            ),
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: _handleVideoCall,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _chatList(),
              _bottomChatArea(),
            ],
          ),
        ),
      ),
    );
  }

  _chatList() {
    return Expanded(
      child: Container(
        child: ListView.builder(
          cacheExtent: 100,
          controller: _chatLVController,
          reverse: false,
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          itemCount: null == _chatMessages ? 0 : _chatMessages!.length,
          itemBuilder: (context, index) {
            ChatMessageModel chatMessage = _chatMessages![index];
            return _chatBubble(
              chatMessage,
            );
          },
        ),
      ),
    );
  }

  _bottomChatArea() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          _chatTextArea(),
        ],
      ),
    );
  }

  _chatTextArea() {
    return Expanded(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.grey[200],
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 10.0),
            Expanded(
              child: TextField(
                controller: _chatTfController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                ),
                //onSubmitted: _sendMessage,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: _showOptions,
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: _chooseIamge,
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_chatTfController!.text.isNotEmpty ||
                    _selectedImagePath != null) {
                  _sendButtonTap();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _sendButtonTap() async {
    if (_chatTfController!.text.isEmpty && _selectedImagePath == null) {
      return;
    }

    DateTime currentTime = DateTime.now();

    ChatMessageModel chatMessageModel = ChatMessageModel(
      chatId: 0,
      to: _chatUser!.id,
      from: G.loggedInUser!.id,
      toUserOnlineStatus: true,
      message: _chatTfController!.text,
      chatType: SocketUtils.SINGLE_CHAT,
      time: currentTime,
    );

    if (_selectedImagePath != null) {
      chatMessageModel.imagePath = _selectedImagePath;
      setState(() {
        _selectedImagePath =
            null; // Clear the selected image path after sending
      });
    }

    _addMessage(0, chatMessageModel, _isFromMe(G.loggedInUser!));
    _clearMessage();
    G.socketUtils!.sendSingleChatMessage(chatMessageModel, _chatUser!);
  }

  _clearMessage() {
    _chatTfController!.text = '';
  }

  _isFromMe(User fromUser) {
    return fromUser.id == G.loggedInUser?.id;
  }

  _chatBubble(ChatMessageModel chatMessageModel) {
    bool fromMe = chatMessageModel.from == G.loggedInUser!.id;
    Alignment alignment = fromMe ? Alignment.topRight : Alignment.topLeft;
    Alignment chatArrowAlignment =
        fromMe ? Alignment.topRight : Alignment.topLeft;
    TextStyle textStyle = TextStyle(
      fontSize: 16.0,
      color: fromMe ? Colors.white : Colors.black54,
    );
    Color chatBgColor = fromMe ? Colors.blue : Colors.black12;
    EdgeInsets edgeInsets = fromMe
        ? const EdgeInsets.fromLTRB(5, 5, 15, 5)
        : const EdgeInsets.fromLTRB(15, 5, 5, 5);
    EdgeInsets margins = fromMe
        ? const EdgeInsets.fromLTRB(80, 5, 10, 5)
        : const EdgeInsets.fromLTRB(10, 5, 80, 5);
    String formattedTime = DateFormat.jm().format(chatMessageModel.time!);

    return Container(
      color: Colors.white,
      margin: margins,
      child: Align(
        alignment: alignment,
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: ChatBubble(
                color: chatBgColor,
                alignment: chatArrowAlignment,
              ),
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: edgeInsets,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (chatMessageModel.message != null)
                            Text(
                              chatMessageModel.message!,
                              style: textStyle,
                            ),
                          if (chatMessageModel.imagePath != null)
                            Image.file(File(chatMessageModel.imagePath!)),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onChatMessageReceived(data) {
    print('onChatMessageReceived $data');
    if (null == data || data.toString().isEmpty) {
      return;
    }
    ChatMessageModel chatMessageModel =
        ChatMessageModel.fromJson(jsonDecode(data));
    bool online = chatMessageModel.toUserOnlineStatus!;
    _updateToUserOnlineStatusInUI(online);
    processMessage(chatMessageModel);
  }

  onMessageBackFromServer(data) {
    ChatMessageModel chatMessageModel =
        ChatMessageModel.fromJson(jsonDecode(data));
    bool online = chatMessageModel.toUserOnlineStatus!;
    print('onMessageBackFromServer $data');
    if (!online) {
      print('User not connected');
    }
  }

  onUserConnectionStatus(data) {
    debugPrint("$data");
    ChatMessageModel chatMessageModel =
        ChatMessageModel.fromJson(jsonDecode(data));
    bool online = chatMessageModel.toUserOnlineStatus!;
    _updateToUserOnlineStatusInUI(online);
  }

  _updateToUserOnlineStatusInUI(online) {
    setState(() {
      _userOnlineStatus =
          online ? UserOnlineStatus.online : UserOnlineStatus.not_online;
    });
  }

  processMessage(ChatMessageModel chatMessageModel) {
    _addMessage(0, chatMessageModel, false);
  }

  _addMessage(id, ChatMessageModel chatMessageModel, fromMe) async {
    print('Adding Message to UI ${chatMessageModel.message}');
    setState(() {
      _chatMessages!.add(chatMessageModel);
    });
    print('Total Messages: ${_chatMessages!.length}');
    _chatListScrollToBottom();
  }

  /// Scroll the Chat List when it goes to bottom
  _chatListScrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_chatLVController!.hasClients) {
        _chatLVController!.animateTo(
          _chatLVController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
        );
      }
    });
  }
}

enum UserOnlineStatus { connecting, online, not_online }
