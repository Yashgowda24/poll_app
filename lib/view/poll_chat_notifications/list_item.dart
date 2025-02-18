import 'package:flutter/material.dart';
import 'package:poll_chat/view/poll_chat_notifications/PollNotification.dart';
import '../../res/colors/app_color.dart';

class ListItem extends StatefulWidget {
  final PollNotification notification;
  final String timeAgo;
  final void Function(String id)? onTap;

  const ListItem(
      {super.key,
      required this.notification,
      required this.timeAgo,
      this.onTap});

  @override
  State<StatefulWidget> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: () {
          widget.onTap!("Item Clicked");
        },
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: Image.asset('assets/images/logo.png'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notification.message,
                    style: const TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.timeAgo,
                    style: const TextStyle(
                        color: AppColor.blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
