import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/home/components/message_chip.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class PollCard extends StatefulWidget {
  final bool? isProfile;
  final bool? isPinnedPolls;
  final dynamic pollModel;
  final dynamic user;

  const PollCard({
    Key? key,
    required this.isProfile,
    required this.isPinnedPolls,
    required this.pollModel,
    required this.user,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  final pollviewModel = Get.put(PollModel());
  final homeViewModelController = Get.put(HomeViewModelController());
  final TextEditingController _commentController = TextEditingController();
  var click = false;
  bool? _isClicked = false;
  UserPreference userPreference = UserPreference();
  List<Map<String, dynamic>> userList = [];
  var chatId;
  int? selectedIndex;
  bool? islike = false;
  bool? isDislike = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        fetchData();
        _fetchFriendRequests();
        likeupdate();
      }
    });
    pollviewModel.getAllCommentsPoll(widget.pollModel['_id']);
  }

  void likeupdate() async {
    if (widget.isProfile! == false) {
      setState(() {
        islike = widget.pollModel['liked'];
        isDislike = widget.pollModel['unLiked'];
      });
    }
  }

  void showProfileModal(String pollId, String token) {
    final pollView = Get.find<PollModel>();
    Get.bottomSheet(
      Container(
        height: 150,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 60,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColor.blackColor,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          try {
                            pollView.updatesinglepoll(pollId);
                            Get.back();
                          } catch (e) {
                            print('Error updating poll: $e');
                          }
                        },
                        child: SvgPicture.asset(IconAssets.editCaptionIcon),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Edit Caption",
                        style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // GetBuilder<PollModel>(
                  //   init: PollModel(),
                  //   builder: (controller) {
                  //     return Column(
                  //       children: [
                  //         InkWell(
                  //           onTap: () async {
                  //             controller.resetVote(pollId);
                  //             homeViewModelController.getAllPolls();
                  //             Get.back();
                  //           },
                  //           child: SvgPicture.asset(IconAssets.deletePollIcon),
                  //         ),
                  //         const SizedBox(height: 10),
                  //         const Text(
                  //           "Reset Poll",
                  //           style: TextStyle(
                  //             color: AppColor.blackColor,
                  //             fontSize: 14,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          final homeViewModelController =
                              Get.find<HomeViewModelController>();
                          UserPreference userPreference = UserPreference();
                          final pollView = Get.find<PollModel>();
                          String? token = await userPreference.getAuthToken();
                          pollView.deletePoll(pollId, token);
                          homeViewModelController
                              .getAllPolls(); // Update list if needed
                          Get.back();
                        },
                        child: SvgPicture.asset(IconAssets.deletePollIcon),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Delete Poll",
                        style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierColor: AppColor.modalBackdropColor,
      isDismissible: true,
      enableDrag: false,
    );
  }

  double calculateItemHeight(String optionText, int vote) {
    const double paddingHeight = 35.0;
    final double textHeight =
        calculateTextHeight(optionText, 12.0, FontWeight.w500, 5);
    final double voteTextHeight = calculateTextHeight(
        "$vote Vote${vote != 1 ? 's' : ''}", 14.0, FontWeight.w500, 1);
    return paddingHeight + textHeight + voteTextHeight;
  }

  double calculateTextHeight(
      String text, double fontSize, FontWeight fontWeight, int maxLines) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.height;
  }

  List<dynamic> _friendRequests = [];
  Future<void> _fetchFriendRequests() async {
    var token = await userPreference.getAuthToken();
    var response = await http.get(
      Uri.parse(
          'https://pollchat.myappsdevelopment.co.in/api/v1/friend/friendList/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var filterList = jsonData['filterList'] as List<dynamic>;

      setState(() {
        _friendRequests = filterList;
      });
    } else {
      throw Exception(
          'Failed to load friend requests: ${response.reasonPhrase}');
    }
  }

  void showShareScreen(BuildContext context, String pollUrl) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.history,
                      color: AppColor.purpleColor,
                    ),
                    title: const Text(
                      'Share to Moments',
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // shareContent();
                      // Get.back();
                      // print(_imageNetworkUrl);
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //       builder: (context) => DisplayImageStory(
                      //         imagePath: _imageNetworkUrl,
                      //       ),
                      //     ),
                      //   );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.dynamic_feed,
                      color: AppColor.purpleColor,
                    ),
                    title: const Text(
                      'Share to Feed',
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      shareContent();
                      //    _downloadAndAddWatermarkToVideo(widget.src['action']);
                      Get.back();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 600,
                      child: GridView.builder(
                        controller: scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: _friendRequests.length,
                        itemBuilder: (context, index) {
                          final user = _friendRequests[index]['friend'];
                          return InkWell(
                            onTap: () {
                              // Get.toNamed(
                              //   RouteName.chatpage,
                              //   arguments: {
                              //     'user': user,
                              //     'action': pollUrl ?? '',
                              //   },
                              // );
                              Get.toNamed(
                                '/chatpage',
                                arguments: {
                                  'user': user,
                                  'action': pollUrl ?? '',
                                },
                              );
                              // _videoPlayerController!.dispose();
                            },
                            child: Column(
                              children: [
                                // ClipPath(
                                //   clipper: OctagonClipper(),
                                //   child: Container(
                                //     height: 40,
                                //     width: 40,
                                //     child: CachedNetworkImage(
                                //       fit: BoxFit.cover,
                                //       imageUrl: (user['profilePhoto'] != null &&
                                //               user['profilePhoto']
                                //                   .toString()
                                //                   .isNotEmpty)
                                //           ? user['profilePhoto'].toString()
                                //           : 'https://via.placeholder.com/60x60.png?text=No+Image', // Placeholder image URL
                                //       placeholder: (context, url) => Image.asset(
                                //           'assets/images/logo.png'), // Local asset placeholder
                                //       errorWidget: (context, url, error) =>
                                //           const Center(
                                //               child: Icon(Icons.error,
                                //                   color: Colors.red)),
                                //     ),
                                //   ),
                                // ),
                                Container(
                                  height: 50,
                                  child: ClipPath(
                                    clipper: OctagonClipper(),
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Image.network(
                                        fit: BoxFit.cover,
                                        (user['profilePhoto']
                                                    ?.toString()
                                                    .trim()
                                                    .isNotEmpty ??
                                                false)
                                            ? user['profilePhoto']
                                                .toString()
                                                .trim()
                                            : 'https://via.placeholder.com/32',
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        },
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Expanded(
                                  child: Text(
                                    user?['name'] ?? "N/A",
                                    style: const TextStyle(
                                      color: AppColor.blackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> handleLikeDislike(String pollId, int likeDislikeVal) async {
    try {
      pollviewModel.likeDislike(pollId, likeDislikeVal);
      setState(() {
        if (likeDislikeVal == 1) {
          if (widget.pollModel['liked'] == null || !widget.pollModel['liked']) {
            widget.pollModel['liked'] = true;
            widget.pollModel['unLiked'] = false;
            widget.pollModel['likeCount'] =
                (widget.pollModel['likeCount'] ?? 0) + 1;
            if (widget.pollModel['dislikeCount'] != null &&
                widget.pollModel['dislikeCount'] > 0) {
              widget.pollModel['dislikeCount'] =
                  (widget.pollModel['dislikeCount'] ?? 0) - 1;
            }
          }
        } else {
          if (widget.pollModel['unLiked'] == null ||
              !widget.pollModel['unLiked']) {
            widget.pollModel['liked'] = false;
            widget.pollModel['unLiked'] = true;
            widget.pollModel['dislikeCount'] =
                (widget.pollModel['dislikeCount'] ?? 0) + 1;
            if (widget.pollModel['likeCount'] != null &&
                widget.pollModel['likeCount'] > 0) {
              widget.pollModel['likeCount'] =
                  (widget.pollModel['likeCount'] ?? 0) - 1;
            }
          }
        }
      });
    } catch (e) {
      // Handle error
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> createPollChat() async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json'
    };
    var url = Uri.parse(
        'http://pollchat.myappsdevelopment.co.in/api/v1/chat/create/');
    var body = json.encode({"friendId": '${widget.pollModel['_id']}'});

    try {
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print(widget.pollModel);

        var responseBody = json.decode(response.body);
        print(responseBody);
        // Get.toNamed(RouteName.chatpage,
        //     arguments: widget.pollModel['userId'] ?? "");
        // Get.toNamed(RouteName.chatpage, arguments: widget.pollModel['userId']);
        Get.toNamed(
          '/chatpage',
          arguments: {
            'user': widget.pollModel['userId'],
          },
        );

        // Get.toNamed(
        //   '/chatpage',
        //   arguments: {
        //     'user': widget.pollModel,
        //   },
        // );
        if (responseBody.containsKey('alreadyChat') &&
            responseBody['alreadyChat'] != null) {
          chatId = responseBody['alreadyChat']['_id'] ?? "";
          print('Chat created successfully. Chat ID: $chatId');
        } else {
          print('Chat ID not found in response');
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchData() async {
    try {
      String? authToken = await userPreference.getAuthToken();
      var url =
          Uri.parse('http://pollchat.myappsdevelopment.co.in/api/v1/user/');
      var headers = {'Authorization': 'Bearer $authToken'};
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          userList = List<Map<String, dynamic>>.from(jsonData['user']);
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  showHomeModal1() {
    return Get.bottomSheet(
      Container(
        height: 150,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 60,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColor.blackColor,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          String? token = await userPreference.getAuthToken();
                          setState(() {
                            homeViewModelController.pinPoll(
                                widget.pollModel['_id'] ?? "", token!);
                            homeViewModelController.getAllPollsEveryOne();
                            Get.back();
                          });
                        },
                        child: SvgPicture.asset(IconAssets.pinPollIcon),
                      ),
                      const Text(
                        "Pin Poll",
                        style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                          if (widget.pollModel['userId'] != null &&
                              widget.pollModel['userId']['_id'] != null) {
                            supportPostRequest(
                                widget.pollModel['userId']['_id']);
                          } else {
                            Utils.snackBar('Error', 'User ID is not available');
                          }
                        },
                        child: SvgPicture.asset(
                          IconAssets.supportIcon,
                          color: AppColor.purpleColor,
                        ),
                      ),
                      const Text(
                        "Support",
                        style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          Get.back();
                          try {
                            String? token = await userPreference.getAuthToken();
                            await pollviewModel.hidePoll(
                                widget.pollModel['_id'] ?? "", token!);

                            // Get.snackbar("Success", "Poll hidden successfully");
                            homeViewModelController.getAllPollsEveryOne();
                          } catch (e) {
                            Get.snackbar("Error", "Failed to hide poll: $e");
                          }
                        },
                        child: SvgPicture.asset(IconAssets.hideIcon,
                            color: AppColor.purpleColor),
                      ),
                      const Text(
                        "Hide",
                        style: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierColor: AppColor.modalBackdropColor,
      isDismissible: true,
      enableDrag: false,
    );
  }

  Future<void> supportPostRequest(var id) async {
    String? token = await userPreference.getAuthToken();
    var headers = {'Authorization': '$token'};

    var url =
        Uri.parse('http://pollchat.myappsdevelopment.co.in/api/v1/support/$id');

    try {
      var request = http.Request('POST', url);
      request.headers.addAll(headers);
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseJson = jsonDecode(responseBody);
        var message = responseJson['message'];
        Utils.snackBar('Success', message);

        print(responseBody);
      } else {
        var responseBody = await response.stream.bytesToString();
        var responseJson = jsonDecode(responseBody);
        var message = responseJson['message'];
        Utils.snackBar('Already', message);
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> shareContent() async {
    await FlutterShare.share(
        title: 'Check out this Poll',
        text: 'Check out this poll on PollChat!',
        linkUrl: 'pollurl will sending',
        chooserTitle: 'Share Poll');
  }

  DecorationImage? _getDecorationImage(String? url) {
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (uri.isAbsolute) {
          return DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          );
        }
      } catch (e) {
        print('Error parsing URL: $e');
      }
    }
    return null;
  }

  void _showCommentScreen(BuildContext context, String pollId) async {
    final pollviewModel = Get.find<PollModel>();
    await pollviewModel.getAllCommentsPoll(pollId);
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0), // Set radius to 0 for full-screen
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GetBuilder<PollModel>(
          builder: (pollviewModel) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9, // Full screen size
            minChildSize: 0.9, // Full screen size
            maxChildSize: 0.9, // Full screen size
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          height: 5,
                          width: 50,
                        ),
                      ),
                      const Center(child: Text("Comments")),
                      Expanded(
                        child: pollviewModel.allComments.isEmpty
                            ? pollviewModel.loading.value
                                ? const Center(
                                    child: ShimmerListView(itemCount: 10))
                                : const Center(child: Text('No comments yet'))
                            : ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount: pollviewModel.allComments.length,
                                itemBuilder: (context, index) {
                                  var comment =
                                      pollviewModel.allComments[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        '${comment["userId"]["profilePhoto"]}',
                                      ),
                                    ),
                                    title: Text('${comment["userId"]["name"]}'),
                                    subtitle: Text('${comment["comment"]}'),
                                    trailing: Text(
                                      "${timeago.format(DateTime.parse(comment["createdAt"]))}",
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: AppColor.purpleLightColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  hintText: 'Add a comment...',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () async {
                                if (_commentController.text.isNotEmpty) {
                                  await pollviewModel.addComment(
                                      pollId, _commentController.text);
                                  _commentController.clear();
                                  // pollviewModel.update();
                                  // await homeViewModelController
                                  //     .getAllPollsEveryOne();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ]),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> pollModel = widget.pollModel;
    List<String> hashtags = List<String>.from(pollModel['hashtags']);
    final options = [
      {'option': 'optionA', 'count': 'countA'},
      {'option': 'optionB', 'count': 'countB'},
      {'option': 'optionC', 'count': 'countC'},
      {'option': 'optionD', 'count': 'countD'}
    ].where((opt) => pollModel.containsKey(opt['option'])).toList();

    DateTime timestamp = DateTime.parse(pollModel["createdAt"] ?? "");
    return Padding(
        padding: const EdgeInsets.all(5),
        child: pollModel['postType'] == 'poll'
            ? Card(
                elevation: 7,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      image: _getDecorationImage(
                        pollModel["pollPhoto"]?.toString().trim() ?? '',
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      Get.toNamed(RouteName.userprofileview,
                                          arguments: widget.pollModel);
                                    },
                                    child: ClipPath(
                                      clipper: OctagonClipper(),
                                      child: SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: Image.network(
                                          fit: BoxFit.cover,
                                          (pollModel["pollPhoto"]
                                                      ?.toString()
                                                      .trim()
                                                      .isNotEmpty ??
                                                  false)
                                              ? pollModel["pollPhoto"]
                                                  .toString()
                                                  .trim()
                                              : 'https://via.placeholder.com/32',
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return const CircularProgressIndicator();
                                            }
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              //pollModel['userId']['name'] ?? "",
                                              pollModel['userId']?['name'] ??
                                                  "",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            timeago.format(timestamp),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  pollModel["pollPhoto"] != null
                                      ? GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Check if `pollPhoto` is available and valid
                                                        pollModel["pollPhoto"] !=
                                                                    null &&
                                                                pollModel[
                                                                        "pollPhoto"]
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty
                                                            ? Image.network(
                                                                pollModel[
                                                                        "pollPhoto"]!
                                                                    .toString()
                                                                    .trim(),
                                                                // height:
                                                                //     200, // Adjust as needed
                                                                // width:
                                                                //     200, // Adjust as needed
                                                                errorBuilder: (context,
                                                                        error,
                                                                        stackTrace) =>
                                                                    const Icon(
                                                                        Icons
                                                                            .error,
                                                                        color: Colors
                                                                            .red), // Handle errors
                                                              )
                                                            : Image.asset(
                                                                "assets/images/logo.png",
                                                                // height: 50,
                                                                // width: 50,
                                                              ),
                                                        const SizedBox(
                                                            height: 20),
                                                        // Safely get the user's name from `userId`
                                                        Text(
                                                          pollModel['userId']
                                                                  ?['name'] ??
                                                              "Unknown User", // Safely access nested properties
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: AppColor.purpleColor,
                                              ),
                                              color: AppColor.whiteColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                            ),
                                            child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Text(
                                                  'View',
                                                  style: TextStyle(
                                                    color: AppColor.purpleColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )),
                                          ))
                                      : Container(),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await createPollChat();
                                    },
                                    child: const MessageChip(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: SizedBox(
                                      width: 22,
                                      height: 24,
                                      child: InkWell(
                                        onTap: () {
                                          log("pollModel[_id] =====> ${pollModel["_id"]}");
                                          if (widget.isProfile!) {
                                            showProfileModal(
                                                pollModel["_id"] ?? "",
                                                userPreference
                                                    .getAuthToken()
                                                    .toString());
                                          } else {
                                            showHomeModal1();
                                          }
                                        },
                                        child: SvgPicture.asset(
                                          IconAssets.dotsVerticalIcon,
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                pollModel["question"] ?? "",
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  color: AppColor.blackColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final optionData = options[index];
                              final optionKey = optionData['option'];
                              final countKey = optionData['count'].toString();
                              final optionText = pollModel[optionKey];
                              final int vote = pollModel[countKey] ?? 0;
                              final int totalVotes = options.fold<int>(
                                0,
                                (sum, opt) =>
                                    sum +
                                    (pollModel[opt['count'].toString()] as int),
                              );
                              final double percent = totalVotes > 0
                                  ? (vote / totalVotes) * 100.0
                                  : 0.0;
                              final Color percentColor = percent > 0
                                  ? AppColor.purpleColor.withOpacity(0.5)
                                  : Colors.transparent;
                              final bool isSelected = selectedIndex == index;
                              final double containerHeight =
                                  calculateItemHeight(optionText, vote);
                              return GestureDetector(
                                onTap: () {
                                  if (!isSelected) {
                                    print("Vote $optionText: $vote");
                                    setState(() {
                                      pollviewModel.sendVote(pollModel["_id"],
                                          optionKey.toString());
                                      pollModel[countKey] =
                                          (pollModel[countKey] ?? 0) + 1;
                                      if (selectedIndex != null) {
                                        final String previousCountKey =
                                            options[selectedIndex!]['count']
                                                .toString();
                                        pollModel[previousCountKey] =
                                            (pollModel[previousCountKey] ?? 0) -
                                                1;
                                      }
                                      selectedIndex = index;
                                      homeViewModelController.update();
                                    });
                                  }
                                },
                                child: Container(
                                  height: containerHeight,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? Colors.transparent
                                        : AppColor.lightpp,
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 5,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      optionText,
                                                      maxLines: 5,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    if (isSelected) ...[
                                                      const SizedBox(width: 5),
                                                      const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "$vote Vote${vote != 1 ? 's' : ''}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (percent > 0)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            height:
                                                containerHeight, // Match the main container height
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: percent / 100.0,
                                              heightFactor: 1.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: percentColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (hashtags.isNotEmpty)
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                itemCount: hashtags.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                      title: Text(
                                    hashtags[index],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ));
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ButtonWithIcon(
                                      //   label: "${pollModel["likeCount"]}",
                                      //   icon: IconAssets.likeIcon,
                                      //   pollId: pollModel["_id"],
                                      //   callback: (String id) async {
                                      //     setState(() {
                                      //       pollviewModel.likeDislike(
                                      //           pollModel["_id"], 1);
                                      //       homeViewModelController.refresh();
                                      //       pollviewModel.refresh();
                                      //       // homeViewModelController
                                      //       //     .getAllPollsEveryOne();
                                      //     });
                                      //   },
                                      // ),
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: GestureDetector(
                                          onTap: () {
                                            handleLikeDislike(
                                                widget.pollModel['_id'], 1);
                                            islike = true;
                                            isDislike = false;
                                          },
                                          child: Icon(
                                            Icons.thumb_up,
                                            color: islike!
                                                ? AppColor.purpleColor
                                                : Colors.grey,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${pollModel['likeCount'] ?? '0'}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: GestureDetector(
                                          onTap: () {
                                            handleLikeDislike(
                                                widget.pollModel['_id'], -1);
                                            islike = false;
                                            isDislike = true;
                                          },
                                          child: Icon(
                                            Icons.thumb_down,
                                            color: isDislike!
                                                ? AppColor.purpleColor
                                                : Colors.grey,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${pollModel['dislikeCount'] ?? '0'}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      // ButtonWithIcon(
                                      //   label: "${pollModel["commentCount"]}",
                                      //   icon: IconAssets.commentsIcon,
                                      //   pollId: pollModel["_id"],
                                      //   isLiked: false,
                                      //   callback: (String id) async {
                                      //     await pollviewModel
                                      //         .getAllCommentsPoll(id);
                                      //     setState(() {
                                      //       _showCommentScreen(context, id);
                                      //     });
                                      //   },
                                      // ),

                                      GestureDetector(
                                        onTap: () {
                                          pollviewModel.getAllCommentsPoll(
                                              pollModel['_id']);

                                          setState(() {
                                            _showCommentScreen(
                                                context, pollModel['_id']);
                                          });
                                        },
                                        child: SvgPicture.asset(
                                            IconAssets.commentsIcon),
                                      ),
                                      Text(
                                        pollModel["commentCount"].toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: InkWell(
                                              onTap: () {
                                                if (!widget.isProfile!) {
                                                  shareContent();
                                                  //  showShareContentModal();
                                                } else {
                                                  shareContent();
                                                  // showProfileModal(
                                                  //     widget.pollModel['_id']);
                                                }
                                              },
                                              child: InkWell(
                                                onTap: () {
                                                  print(
                                                      "https://pollchat.myappsdevelopment.co.in/api/v1/poll/ + ${pollModel['_id']}");
                                                  if (!widget.isProfile!) {
                                                    // shareContent();
                                                    showShareScreen(context,
                                                        "https://pollchat.myappsdevelopment.co.in/api/v1/poll/ + ${pollModel['_id']}");
                                                    //  showShareContentModal();
                                                  } else {
                                                    // shareContent();
                                                    // showProfileModal(
                                                    //     widget.pollModel['_id']);
                                                    showShareScreen(context,
                                                        "https://pollchat.myappsdevelopment.co.in/api/v1/poll/ + ${pollModel['_id']}");
                                                  }
                                                },
                                                child: SvgPicture.asset(
                                                    IconAssets.shareSendIcon),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Text(
                                              "${pollModel["shareCount"]}",
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                                Row(
                                  children: [
                                    pollModel["isPinned"] == true
                                        ? Image.asset(
                                            'assets/images/pinn.png',
                                            height: 16,
                                            width: 16,
                                            color: AppColor.purpleColor,
                                          )
                                        : Container(),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            _isClicked = !_isClicked!;
                                          });

                                          pollviewModel.savePoll(
                                              pollModel["_id"], 1);

                                          // await homeViewModelController
                                          //     .getAllPollsEveryOne();
                                        },
                                        child: widget.isPinnedPolls == false
                                            ? SizedBox(
                                                height: 20,
                                                child: _isClicked!
                                                    ? SvgPicture.asset(
                                                        IconAssets.bookmarkIcon,
                                                        color: _isClicked!
                                                            ? AppColor
                                                                .purpleColor
                                                            : AppColor
                                                                .whiteColor)
                                                    : SvgPicture.asset(
                                                        IconAssets
                                                            .bookmarkIcon),
                                              )
                                            : SizedBox(
                                                height: 20,
                                                child: widget.isPinnedPolls ==
                                                        true
                                                    ? SvgPicture.asset(
                                                        IconAssets.bookmarkIcon,
                                                        color:
                                                            widget.isPinnedPolls ==
                                                                    true
                                                                ? AppColor
                                                                    .purpleColor
                                                                : AppColor
                                                                    .whiteColor)
                                                    : SvgPicture.asset(
                                                        IconAssets
                                                            .bookmarkIcon),
                                              )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    )))
            : Container(
                height: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColor.purpleColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: pollModel["media"] != null &&
                              pollModel["media"].isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: pollModel["media"],
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )
                          : const Icon(Icons.image_not_supported),
                    ),
                    Text(
                      pollModel["caption"] ?? "Advertisement",
                      style: const TextStyle(color: AppColor.whiteColor),
                    ),
                    Text(pollModel["location"] ?? "",
                        style: const TextStyle(color: AppColor.whiteColor)),
                  ],
                ),
              ));
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_share/flutter_share.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:poll_chat/components/ButtonWithIcon.dart';
// import 'package:poll_chat/models/choice/choice.dart';
// import 'package:poll_chat/models/poll_model/poll_model.dart';
// import 'package:poll_chat/res/assets/icon_assets.dart';
// import 'package:poll_chat/res/colors/app_color.dart';
// import 'package:poll_chat/res/routes/routes_name.dart';
// import 'package:poll_chat/view/home/components/message_chip.dart';
// import 'package:poll_chat/view/home/components/utils.dart';
// import 'package:poll_chat/view_models/controller/home_model.dart';

// import 'package:timeago/timeago.dart' as timeago;
// import 'package:url_launcher/url_launcher.dart';

// class PollCard extends StatefulWidget {
//   final bool isProfile;
//   final Map<String, dynamic> pollModel;
//   final Map<String, dynamic> user;
//   const PollCard(
//       {super.key,
//       required this.isProfile,
//       required this.pollModel,
//       required this.user});

//   @override
//   State<StatefulWidget> createState() => _PollCardState();
// }

// class _PollCardState extends State<PollCard> {
//   final pollviewModel = Get.put(PollModel());
//   final homeViewModelController = Get.put(HomeViewModelController());
//   var click = false;
//   Future<void> shareContent() async {
//     await FlutterShare.share(
//         title: 'Check out this Poll',
//         text: 'Check out this poll on PollChat!',
//         linkUrl: 'pollurl will sending',
//         chooserTitle: 'Share Poll');
//   }

//   showHomeModal1() {
//     return Get.bottomSheet(
//       Container(
//         height: 150,
//         decoration: const BoxDecoration(
//           color: AppColor.whiteColor,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(25.0),
//             topRight: Radius.circular(25.0),
//           ),
//         ),
//         child: Column(
//           children: [
//             const SizedBox(height: 10),
//             Container(
//               width: 60,
//               height: 4,
//               decoration: const BoxDecoration(
//                 color: AppColor.blackColor,
//                 borderRadius: BorderRadius.all(Radius.circular(4)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     children: [
//                       InkWell(
//                         onTap: () {},
//                         child: SvgPicture.asset(IconAssets.pinPollIcon),
//                       ),
//                       const Text(
//                         "Pin Poll",
//                         style: TextStyle(
//                           color: AppColor.blackColor,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           launchEmail();
//                         },
//                         child: SvgPicture.asset(IconAssets.supportIcon),
//                       ),
//                       const Text(
//                         "Support",
//                         style: TextStyle(
//                           color: AppColor.blackColor,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       InkWell(
//                         onTap: () {},
//                         child: SvgPicture.asset(IconAssets.hideIcon),
//                       ),
//                       const Text(
//                         "Hide",
//                         style: TextStyle(
//                           color: AppColor.blackColor,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       barrierColor: AppColor.modalBackdropColor,
//       isDismissible: true,
//       enableDrag: false,
//     );
//   }

//   void launchEmail() async {
//     const email = 'admin123@gmail.com';
//     final Uri emailLaunchUri = Uri(
//       scheme: 'mailto',
//       path: email,
//       queryParameters: {
//         'subject': 'Support',
//         'body': 'massage...',
//       },
//     );

//     try {
//       await launch(emailLaunchUri.toString());
//     } catch (e) {
//       print('Error launching email: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Map<String, dynamic> pollModel = widget.pollModel;
//     pollviewModel.getAllCommentsPoll(pollModel["_id"]);
//     pollviewModel.refresh();
//     print("Current - ${pollModel["_id"]}");
//     DateTime timestamp = DateTime.parse(pollModel["createdAt"]);
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child: Card(
//         elevation: 7,
//         child: Container(
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15), color: Colors.white),
//           child: Padding(
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 16,
//                           child: ClipOval(
//                             child: SizedBox(
//                               width: 32,
//                               height: 32,
//                               child: Image.network(
//                                 pollModel["pollPhoto"]?.toString().trim() ?? '',
//                                 loadingBuilder: (BuildContext context,
//                                     Widget child,
//                                     ImageChunkEvent? loadingProgress) {
//                                   if (loadingProgress == null) {
//                                     return child;
//                                   } else {
//                                     return const CircularProgressIndicator();
//                                   }
//                                 },
//                                 errorBuilder: (BuildContext context,
//                                     Object exception, StackTrace? stackTrace) {
//                                   return const Icon(Icons.error);
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 5),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Text("${widget.user["name"] ?? ""}",
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold)),
//                               ),
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   timeago.format(timestamp),
//                                   style: const TextStyle(fontSize: 10),
//                                 ),
//                               )
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const MessageChip(),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 5),
//                           child: SizedBox(
//                             width: 22,
//                             height: 24,
//                             child: InkWell(
//                               onTap: () {
//                                 if (widget.isProfile) {
//                                   showProfileModal(pollModel["_id"]);
//                                 } else {
//                                   showHomeModal1();
//                                 }
//                               },
//                               child: SvgPicture.asset(
//                                 IconAssets.dotsVerticalIcon,
//                                 width: 30,
//                                 height: 30,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       pollModel["question"].toString(),
//                       textDirection: TextDirection.ltr,
//                       style: const TextStyle(
//                         color: AppColor.blackColor,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//                 ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: 2,
//                     itemBuilder: (context, index) {
//                       // final Choice? choice = pollModel.choices?[index];
//                       int vote = pollModel[index == 0 ? "countA" : "countB"] < 0
//                           ? int.parse(
//                               pollModel[index == 0 ? "countA" : "countB"]
//                                   .toString()
//                                   .substring(1))
//                           : pollModel[index == 0 ? "countA" : "countB"];
//                       double percent = vote *
//                           10 /
//                           (MediaQuery.of(context).size.width - 20) *
//                           100;

//                       return GestureDetector(
//                         onTap: () {
//                           print("Vote A ${pollModel["countA"]} ");
//                           print("Vote B ${pollModel["countB"]} ");

//                           print(pollModel["_id"] +
//                               (index == 0 ? "optionA" : "optionB").toString());
//                           setState(() {
//                             pollviewModel.sendVote(pollModel["_id"],
//                                 index == 0 ? "optionA" : "optionB");
//                             // click?0:pollModel[index==0?"countA":"countB"]=pollModel[index==0?"countA":"countB"]+1;
//                           });
//                           setState(() {
//                             click = true;
//                           });
//                           homeViewModelController.getAllPolls();
//                           homeViewModelController.refresh();
//                           // pollviewModel.refresh();
//                         },
//                         child: Stack(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.only(bottom: 10),
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: click
//                                           ? AppColor.purpleColor
//                                           : Colors.transparent),
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: AppColor.greyLightColor),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 15, horizontal: 10),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                         "${pollModel[index == 0 ? "optionA" : "optionB"]}"),
//                                     Text(
//                                         "${pollModel[index == 0 ? "countA" : "countB"]} Vote")
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             click
//                                 ? Container(
//                                     width: percent,
//                                     foregroundDecoration: BoxDecoration(
//                                         borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(8),
//                                             bottomLeft: Radius.circular(8)),
//                                         color: AppColor.purpleColor
//                                             .withOpacity(0.5)),
//                                     margin: const EdgeInsets.only(bottom: 10),
//                                     child: const Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           vertical: 15, horizontal: 10),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(""),
//                                           Text(""),
//                                         ],
//                                       ),
//                                     ),
//                                   )
//                                 : Container(),
//                           ],
//                         ),
//                       );
//                     }),
//                 const Padding(padding: EdgeInsets.all(5)),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           ButtonWithIcon(
//                             label: "${pollModel["likeCount"]}",
//                             icon: IconAssets.likeIcon,
//                             pollId: pollModel["_id"],
//                             callback: (String id) {
//                               pollviewModel.likeDislike(pollModel["_id"], 1);
//                               // homeViewModelController.getAllPolls();
//                               // homeViewModelController.refresh();
//                               // pollviewModel.refresh();
//                               print("pollid: ${id}");
//                             },
//                           ),
//                           ButtonWithIcon(
//                             label: "${pollModel["dislikeCount"]}",
//                             icon: IconAssets.dislikeIcon,
//                             pollId: pollModel["_id"],
//                             callback: (String id) {
//                               pollviewModel.likeDislike(pollModel["_id"], 0);
//                               homeViewModelController.getAllPolls();
//                               homeViewModelController.refresh();
//                               pollviewModel.refresh();
//                               print("pollid: ${id}");
//                             },
//                           ),
//                           ButtonWithIcon(
//                             label: "${pollModel["commentCount"]}",
//                             icon: IconAssets.commentsIcon,
//                             pollId: pollModel["_id"],
//                             callback: (String id) {
//                               pollviewModel.getAllCommentsPoll(id);
//                               pollviewModel.refresh();
//                               setState(() {
//                                 _showCommentScreen(context, id);
//                               });
//                               print("pollid: ${id}");
//                             },
//                           ),
//                           Row(
//                             children: [
//                               SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: InkWell(
//                                   onTap: () {
//                                     if (!widget.isProfile) {
//                                       // showShareContentModal();
//                                       shareContent();
//                                     }
//                                   },
//                                   child: SvgPicture.asset(
//                                       IconAssets.shareSendIcon),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 5),
//                                 child: Text(
//                                   "${pollModel["shareCount"]}",
//                                   style: const TextStyle(fontSize: 12),
//                                 ),
//                               )
//                             ],
//                           )
//                         ],
//                       ),
//                       SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: SvgPicture.asset(IconAssets.bookmarkIcon),
//                       )
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /*Comments Variables*/
//   TextEditingController _commentController = TextEditingController();
//   /* List<String> commentUsers=["User 1","User 2","User 3","User 4","User 5"];
//   List<bool> _commentsLikes = [false,false,false,false,false];
//   List<String> _comments = [
//     'Great photo!',
//     'Awesome!',
//     'Love it!',
//     'Beautiful!',
//     'Nice shot!',
//   ];
//   int yourComment=0;*/
//   /*Comments Variables*/

//   /*{"status":true,"message":"Comment added to the poll",
//   "commented":{"pollId":"660812b589bf429c06ef2e1c",
//   "userId":"65f95033773729a83ac0cfda"
//   ,"comment":"nice","
//   _id":"660871ab89bf429c06ef2ece",
//   "createdAt":"2024-03-30T20:10:19.279Z",
//   "updatedAt":"2024-03-30T20:10:19.279Z","__v":0}}*/

//   void _showCommentScreen(BuildContext context, var pollId) {
//     var commentModel;

//     commentModel = pollviewModel.allComments;
//     print(commentModel.toString());

//     showModalBottomSheet(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Container(
//           padding:
//               EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20.0),
//               topRight: Radius.circular(20.0),
//             ),
//           ),
//           height: MediaQuery.of(context).size.height - 100,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Center(
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: Colors
//                           .black, // Specify the background color of the container
//                       borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                     ),
//                     margin: const EdgeInsets.only(bottom: 10),
//                     height: 5,
//                     width: 50,
//                   ),
//                 ),
//                 const Center(
//                   child: Text("Comments"),
//                 ),
//                 Container(
//                   height: MediaQuery.of(context).size.height - 200,
//                   child: ListView.builder(
//                       itemCount: commentModel.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           leading: CircleAvatar(
//                             radius: 20,
//                             child: Image.network(
//                                 '${commentModel[index]["userId"]["profilePhoto"]}'),
//                           ),
//                           title:
//                               Text('${commentModel[index]["userId"]["name"]}'),
//                           subtitle: Text('${commentModel[index]["comment"]}'),
//                           trailing: Container(
//                             padding: const EdgeInsets.only(right: 5.0),
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.pop(context);
//                                 _showCommentScreen(context, pollId);
//                               },
//                               child: Text(
//                                   "${timeago.format(DateTime.parse(commentModel[index]["createdAt"]))}"),
//                             ),
//                           ),
//                         );
//                       }),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   decoration: BoxDecoration(
//                     color: AppColor.purpleLightColor.withOpacity(0.1),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(0.0),
//                       topRight: Radius.circular(0.0),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {},
//                           child: TextField(
//                             controller: _commentController,
//                             decoration: const InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderSide: BorderSide.none),
//                               hintText: 'Add a comment...',
//                             ),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed: () {
//                           if (_commentController.text.isNotEmpty) {
//                             setState(() {
//                               pollviewModel.addComment(widget.pollModel["_id"],
//                                   _commentController.text);
//                               pollviewModel.getAllCommentsPoll(pollId);

//                               setState(() {
//                                 commentModel = pollviewModel.allComments;
//                               });
//                               _commentController.clear();
//                               Navigator.of(context).pop();
//                               Get.off(RouteName.dashboardScreen);
//                               // _showCommentScreen(context,pollId);
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

