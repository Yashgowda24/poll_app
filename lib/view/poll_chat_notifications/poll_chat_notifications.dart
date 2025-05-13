// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/poll_chat_notifications/PollNotification.dart';
import 'package:poll_chat/view/poll_chat_notifications/list_item.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class PollChatNotificationsView extends StatefulWidget {
  const PollChatNotificationsView({super.key});

  @override
  State<StatefulWidget> createState() => _PollChatNotificationsView();
}

class _PollChatNotificationsView extends State<PollChatNotificationsView> {
  @override
  void initState() {
    super.initState();
    fetchNotification();
  }

  String? globalId;
  UserPreference userPreference = UserPreference();
  List<PollNotification> notifications = [];
  bool isLoading = true;

  void fetchNotification() async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};

    var uri = Uri.parse(
        'https://pollchat.myappsdevelopment.co.in/api/v1/notification/fetch');
    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var notificationList = jsonResponse['notifications'] as List;
      print('----notifi is as below-----');
      print(jsonResponse['notifications']);

      setState(() {
        notifications = notificationList.map((notification) {
          DateTime createdAt = DateTime.parse(notification['createdAt']);
          return PollNotification(notification['notification'], createdAt);
        }).toList();
        isLoading = false;
      });

      notifications.forEach((notification) {
        globalId = notification.message;
        print('Notification: ${notification.message}');
        print('Time: ${notification.timeStamp}');
        print('-----------------------');
      });
    } else {
      print('Failed to fetch notifications: ${response.reasonPhrase}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteNotification(String id) async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};

    var uri = Uri.parse(
        'https://pollchat.myappsdevelopment.co.in/api/v1/notification/delete/');

    HttpClientRequest request = await HttpClient().deleteUrl(uri);
    headers.forEach((header, value) {
      request.headers.set(header, value);
    });

    HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      var responseBody = await response.transform(utf8.decoder).join();

      var responseData = json.decode(responseBody);
      String message = responseData['message'];
      print(message);
      fetchNotification();
      Utils.snackBar('Delete', message);
    } else {
      print('Failed to delete notification: ${response.reasonPhrase}');
      Utils.snackBar(
          'Delete', 'Failed to delete notification: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          InkWell(
              onTap: () {
                if (globalId != null) {
                  deleteNotification(globalId!);
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.delete),
              ))
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                notifications.isEmpty ? '' : 'Today',
                style: const TextStyle(
                    color: AppColor.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            isLoading
                ? const Expanded(
                    child: ShimmerListView(
                        itemCount: 10), 
                  )
                : notifications.isEmpty 
                    ? const Center(
                        child: Text('No notifications available'),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            var notification = notifications[index];
                            String timeAgo =
                                timeago.format(notification.timeStamp);
                            return ListItem(
                              notification: PollNotification(
                                notification.message,
                                notification.timeStamp,
                              ),
                              timeAgo: timeAgo,
                              onTap: (String id) {},
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
