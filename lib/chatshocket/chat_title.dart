import 'package:flutter/material.dart';
import 'User.dart';
import 'chat_screen.dart';

class ChatTitle extends StatelessWidget {
  //
  const ChatTitle({
    Key? key,
    required this.chatUser,
    required this.userOnlineStatus,
  }) : super(key: key);

  final User chatUser;
  final UserOnlineStatus userOnlineStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            chatUser.name,
            style: const TextStyle(
              fontSize: 15.0,
              color: Colors.green,
            ),
          ),
          Text(
            _getStatusText(),
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  _getStatusText() {
    if (userOnlineStatus == UserOnlineStatus.connecting) {
      return 'connecting...';
    }
    if (userOnlineStatus == UserOnlineStatus.online) {
      return 'online';
    }
    if (userOnlineStatus == UserOnlineStatus.not_online) {
      return 'not online';
    }
  }
}
