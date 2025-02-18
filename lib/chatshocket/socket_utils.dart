import 'dart:io';
import 'User.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'chat_message_model.dart';

class SocketUtils {
  // local host server se connect hone me problem aati hai ....
  //phle server ko deploy kiya hai then url pass ki hai connectUrl me
  static String _serverIP =
      Platform.isIOS ? 'http://localhost' : 'http://10.0.2.2';
  static const int SERVER_PORT = 5000;
  static String _connectUrl = 'https://real-chat-node.onrender.com/';

  static const String ON_MESSAGE_RECEIVED = 'receive_message';
  static const String SUB_EVENT_MESSAGE_SENT = 'message_sent_to_user';
  static const String IS_USER_CONNECTED_EVENT = 'is_user_connected';
  static const String IS_USER_ONLINE_EVENT = 'check_online';
  static const String SUB_EVENT_MESSAGE_FROM_SERVER = 'message_from_server';

  static const int STATUS_MESSAGE_NOT_SENT = 10001;
  static const int STATUS_MESSAGE_SENT = 10002;
  static const int STATUS_MESSAGE_DELIVERED = 10003;
  static const int STATUS_MESSAGE_READ = 10004;

  static const String SINGLE_CHAT = 'single_chat';

  User? _fromUser;
  IO.Socket? _socket;

  initSocket(User fromUser) async {
    print('Connecting user: ${fromUser.name}');
    this._fromUser = fromUser;
    await _init();
  }

  _init() async {
    _socket = IO.io(
      _connectUrl,
      socketOptions(),
    );
  }

  Map<String, dynamic> socketOptions() {
    final Map<String, String> userMap = {"from": _fromUser!.id.toString()};
    return {
      'transports': ['websocket'],
      'autoConnect': false,
      'query': userMap
    };
  }

  sendSingleChatMessage(ChatMessageModel chatMessageModel, User toChatUser) {
    print('Sending Message to: ${toChatUser.name}, ID: ${toChatUser.id}');
    if (_socket == null) {
      print("Socket is Null, Cannot send message");
      return;
    }
    _socket!.emit("single_chat_message", [chatMessageModel.toJson()]);
  }

  setOnMessageBackFromServer(Function onMessageBackFromServer) {
    _socket!.on(SUB_EVENT_MESSAGE_FROM_SERVER, (data) {
      onMessageBackFromServer(data);
    });
  }

  checkOnline(ChatMessageModel chatMessageModel) {
    print('Checking Online: ${chatMessageModel.to}');
    if (null == _socket) {
      print("Socket is Null, Cannot send message");
      return;
    }
    _socket!.emit(IS_USER_ONLINE_EVENT, [chatMessageModel.toJson()]);
  }

 
  connectToSocket() {
    if (null == _socket) {
      print("Socket is Null");
      return;
    }
    print("Connecting to socket...");
    _socket!.connect();
  }

  setConnectListener(Function onConnect) {
    _socket!.onConnect((data) {
      onConnect(data);
    });
  }

  setOnConnectionErrorListener(Function onConnectError) {
    _socket!.onConnectError((data) {
      onConnectError(data);
    });
  }

  setOnConnectionErrorTimeOutListener(Function onConnectTimeout) {
    _socket!.onConnectTimeout((data) {
      onConnectTimeout(data);
    });
  }

  setOnErrorListener(Function onError) {
    _socket!.onError((error) {
      onError(error);
    });
  }

  setOnDisconnectListener(Function onDisconnect) {
    _socket!.onDisconnect((data) {
      print("onDisconnect $data");
      onDisconnect(data);
    });
  }

  setOnChatMessageReceivedListener(Function onChatMessageReceived) {
    _socket!.on(ON_MESSAGE_RECEIVED, (data) {
      print("Received $data");
      onChatMessageReceived(data);
    });
  }

  setOnMessageSentToChatUserListener(Function onMessageSentListener) {
    _socket!.on(SUB_EVENT_MESSAGE_SENT, (data) {
      print("onMessageSentListener $data");
      onMessageSentListener(data);
    });
  }

  setOnUserConnectionStatusListener(Function onUserConnectionStatus) {
    _socket!.on(IS_USER_CONNECTED_EVENT, (data) {
      onUserConnectionStatus(data);
    });
  }

  closeConnection() {
    if (null != _socket) {
      print("Close Connection");
      _socket!.close();
    }
  }
}
