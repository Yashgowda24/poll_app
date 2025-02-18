import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContentUserScreen extends StatefulWidget {
  final Map<String, dynamic> src;
  const ContentUserScreen({Key? key, required this.src}) : super(key: key);

  @override
  _ContentUserScreenState createState() => _ContentUserScreenState();
}

class _ContentUserScreenState extends State<ContentUserScreen> {
  UserPreference userPreference = UserPreference();
  TextEditingController _commentController = TextEditingController();
  bool _isIconRed = false;
  bool _isIconUnlike = false;

  bool _isBookmark = false;
  List<String> commentUsers = [
    "User 1",
    "User 2",
    "User 3",
    "User 4",
    "User 5"
  ];
  final List<bool> _commentsLikes = [false, false, false, false, false];
  final List<String> _comments = [
    'Great photo!',
    'Awesome!',
    'Love it!',
    'Beautiful!',
    'Nice shot!',
  ];

  Future<void> likeDislikeAction(String id, int value) async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken'
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/likeDislike/$id'));
    request.body = json.encode({"likeDislike": value});
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        List<int> bytes = [];
        await for (var chunk in response.stream) {
          bytes.addAll(chunk);
        }
        var responseBody = utf8.decode(bytes);
        var jsonResponse = jsonDecode(responseBody);
        var message = jsonResponse['message'];
        Get.snackbar('Success', message);
        print('Response: $responseBody');
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  String? _imageNetworkUrl;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> initialize() async {
    var action = widget.src['action'];
    print(action);

    if (action != null &&
        (action.endsWith('.png') ||
            action.endsWith('.jpg') ||
            action.endsWith('.jpeg'))) {
      setState(() {
        _imageNetworkUrl = action;
      });
    } else if (action != null) {
      _videoPlayerController = VideoPlayerController.network(action);

      try {
        await _videoPlayerController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          showControls: false,
          looping: true,
        );
        setState(() {});
      } catch (e) {
        print("Error initializing video player: $e");
      }
    } else {
      print("Action is null or unsupported format");
    }
  }

  void showShareScreen(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Share to Story'),
                onTap: () {
                  //  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.dynamic_feed),
                title: const Text('Share to Feed'),
                onTap: () async {},
              ),
              ListTile(
                leading: const Icon(Icons.people_sharp),
                title: const Text('Share to Friends'),
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentScreen(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: MediaQuery.of(context).size.height - 100,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors
                          .black, // Specify the background color of the container
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 5,
                    width: 50,
                  ),
                ),
                const Center(
                  child: Text("Comments"),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade100,
                            child:
                                Text('${commentUsers[index].substring(0, 1)}'),
                          ),
                          title: Text('${commentUsers[index]}'),
                          subtitle: Text(_comments[index]),
                          trailing: Container(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _commentsLikes[index] =
                                      !_commentsLikes[index];
                                });
                                Navigator.pop(context);
                                _showCommentScreen(context);
                              },
                              child: FaIcon(
                                _commentsLikes[index % _commentsLikes.length]
                                    ? FontAwesomeIcons.solidHeart
                                    : FontAwesomeIcons.heart,
                                color: _commentsLikes[
                                        index % _commentsLikes.length]
                                    ? Colors.red
                                    : Colors.black,
                                size: 15,
                              ),
                            ),
                          ),
                        );
                      }),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: 'Add a comment...',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            setState(() {
                              _comments.add(_commentController.text);
                              commentUsers.add("_username");
                              _commentsLikes.add(false);
                              _commentController.clear();
                              Navigator.of(context).pop();
                              _showCommentScreen(context);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _imageNetworkUrl != null
                      ? Expanded(
                          child: InkWell(
                              child: Image.network(
                          _imageNetworkUrl!.toString(),
                          fit: BoxFit.cover,
                        )))
                      : _chewieController != null
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  if (_videoPlayerController!.value.isPlaying) {
                                    _videoPlayerController!.pause();
                                  } else {
                                    _videoPlayerController!.play();
                                  }
                                });
                              },
                              child: Chewie(controller: _chewieController!))
                          : Image.asset(
                              'assets/images/logo.png',
                              height: 50,
                              width: 50,
                            )
                ],
              ),
        Positioned(
          bottom: 10,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  // height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Container(
                          //   width: 40,
                          //   height: 40,
                          //   margin: const EdgeInsets.only(bottom: 5, right: 0),
                          //   child: ClipOval(
                          //     child: Image.network(
                          //       widget.src != null &&
                          //               widget.src['profilePhoto'] != null
                          //           ? widget.src['profilePhoto'].toString()
                          //           : 'assets/images/logo.png',
                          //       width: 40,
                          //       height: 40,
                          //       fit: BoxFit.cover,
                          //       errorBuilder: (BuildContext context,
                          //           Object exception, StackTrace? stackTrace) {
                          //         return Image.asset(
                          //           'assets/images/logo.png',
                          //           width: 40,
                          //           height: 40,
                          //           fit: BoxFit.cover,
                          //         );
                          //       },
                          //     ),
                          //   ),
                          // ),
                          // Text(
                          //   widget.src['name'] ?? "N/A",
                          //   style: const TextStyle(
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white),
                          // ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: AppColor.whiteColor),
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              child: Text('Supporters',
                                  style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Text(
                          widget.src['actionCaption'] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Container(
                        height: 30,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image.asset("assets/images/music.gif"),
                            const Icon(
                              Icons.music_note_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: Text(
                                widget.src['actionType'] ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIconRed = !_isIconRed;
                            _isIconUnlike = (_isIconRed) ? false : false;
                          });
                          likeDislikeAction(widget.src['_id'], 1);
                        },
                        child: Column(
                          children: [
                            FaIcon(
                              _isIconRed
                                  ? FontAwesomeIcons.solidThumbsUp
                                  : FontAwesomeIcons.thumbsUp,
                              color: _isIconRed ? Colors.red : Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text(
                                // widget.src['likeCount'].toString(),
                                _isIconRed
                                    ? (widget.src['likeCount'] + 1).toString()
                                    : (widget.src['likeCount']).toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIconUnlike = !_isIconUnlike;
                            _isIconRed = (_isIconUnlike) ? false : false;
                          });
                          likeDislikeAction(widget.src['_id'], 0);
                        },
                        child: Column(
                          children: [
                            FaIcon(
                              _isIconUnlike
                                  ? FontAwesomeIcons.solidThumbsDown
                                  : FontAwesomeIcons.thumbsDown,
                              color: _isIconUnlike ? Colors.red : Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                //widget.src['dislikeCount'].toString(),
                                _isIconUnlike
                                    ? (widget.src['dislikeCount'] + 1)
                                        .toString()
                                    : (widget.src['dislikeCount']).toString(),
                                //"${_isIconUnlike ? ((14 + 1).toString()) : ((14).toString())}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          _showCommentScreen(context);
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                IconAssets.commentsWhiteIcon,
                              ),
                              Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  widget.src['commentCount'].toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          IconAssets.shareWhiteIcon,
                        ),
                        onPressed: () {
                          showShareScreen(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(_isBookmark
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _isBookmark = !_isBookmark;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                          height: 27,
                          width: 27,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: const Icon(
                            Icons.multitrack_audio_rounded,
                            color: Colors.white,
                            size: 15,
                          ) /*Image.asset("assets/images/music.gif")*/),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
