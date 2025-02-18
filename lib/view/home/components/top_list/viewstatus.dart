// import 'package:flutter/material.dart';
// import 'package:story_view/story_view.dart';

// class StatusView extends StatefulWidget {
//   final List<Map<String, dynamic>> videoPath;

//   StatusView(this.videoPath);

//   @override
//   State<StatusView> createState() => _StatusViewState();
// }

// class _StatusViewState extends State<StatusView> {
//   final controller = StoryController();
//   TextEditingController messageController = TextEditingController();
//   bool isTyping = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GestureDetector(
//             onTap: () {
//               if (!isTyping) {
//                 controller.pause();
//               }
//             },
//             child: StoryView(
//               storyItems: widget.videoPath.map((video) {
//                 if (video['662764beee4ca6d63ca4d2d2'].endsWith('.mp4')) {
//                   return StoryItem.pageVideo(
//                     video['662764beee4ca6d63ca4d2d2'],
//                     controller: controller,
//                   );
//                 } else {
//                   return StoryItem.pageImage(
//                     url: video['662764beee4ca6d63ca4d2d2'],
//                     controller: controller,
//                   );
//                 }
//               }).toList(),
//               controller: controller,
//               inline: true,
//               repeat: false,
//               onComplete: () {
//                 Navigator.pop(context);
//               },
//             ),

//           ),
//           Positioned.fill(
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: messageController,
//                           onChanged: (value) {
//                             setState(() {
//                               isTyping = value.isNotEmpty;
//                             });
//                           },
//                           decoration: const InputDecoration(
//                             hintText: 'Type your message...',
//                             border: InputBorder.none,
//                             contentPadding:
//                                 EdgeInsets.only(left: 15, right: 15),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.send),
//                         onPressed: () {
//                           sendMessage(messageController.text);
//                           messageController.clear();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void sendMessage(String message) {
//     print('Message sent: $message');
//   }
// }

import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StatusView extends StatefulWidget {
  final List<Map<String, dynamic>> videoPath;
//  final List<Map<String, dynamic>> storymoments;

  StatusView(this.videoPath);

  @override
  State<StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  final StoryController controller = StoryController();
  TextEditingController messageController = TextEditingController();
  bool isTyping = false;
  String? mediaUrl;
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (!isTyping) {
                controller.pause();
              }
            },
            child: StoryView(
              storyItems: widget.videoPath.map((video) {
                mediaUrl = video['momentmedia'];
                if (mediaUrl!.endsWith('.mp4')) {
                  return StoryItem.pageVideo(
                    mediaUrl!,
                    controller: controller,
                  );
                } else {
                  return StoryItem.pageImage(
                    url: mediaUrl!,
                    controller: controller,
                  );
                }
              }).toList(),
              controller: controller,
              inline: true,
              repeat: false,
              onComplete: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 60,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.videoPath[currentIndex]['friendId']['profilePhoto']
                          .toString(),
                    ), // Replace with actual user image URL
                    radius: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.videoPath.isNotEmpty
                        ? widget.videoPath[currentIndex]['friendId']['name']
                            .toString()
                        : 'Unknown User',
                    //  widget.videoPath[0]['friendId']['name'].toString(),

                    // Replace with actual user name
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          onChanged: (value) {
                            setState(() {
                              isTyping = value.isNotEmpty;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15, right: 15),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          sendMessage(messageController.text);
                          messageController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String message) {
    print('Message sent: $message');
    // Implement your message sending logic here
    // You can use APIs, socket connections, etc. to send the message
  }
}
