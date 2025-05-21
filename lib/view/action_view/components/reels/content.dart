// ignore_for_file: deprecated_member_use, avoid_print
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/simmer/simmerlist.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view/action_view/components/reels/water.dart';
import 'package:poll_chat/view/action_view/storycreate/createstory.dart';
import 'package:poll_chat/view_models/controller/music_view_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
// import 'package:video_watermark/video_watermark.dart';

class ContentScreen extends StatefulWidget {
  final dynamic src;
  final Function(String error)? onError;
  const ContentScreen({
    Key? key,
    required this.src,
    this.onError,
  }) : super(key: key);
  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final pollviewModel = Get.put(PollModel());
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  UserPreference userPreference = UserPreference();
  final TextEditingController _commentController = TextEditingController();
  bool _isIconRed = false;
  bool _isIconUnlike = false;
  bool _isBookmark = false;
  List<String> commentUsers = [];

  bool downloading = false;
  String progress = "";
  List<String> downloadedFiles = [];
  // late WatermarkSource _watermarkSource;
  final player = AudioPlayer();
  final musicModelController = Get.put(MusicViewModel());
  int _supportingCount = 0;
  @override
  void initState() {
    super.initState();
    initializePlayer();
    _fetchFriendRequests();
    updateIcon();
    _loadWatermarkImage();
    // loadcomments();
    _supportingCount = widget.src['userId']['supporting'] ?? 0;

    pollviewModel.getActionComment(widget.src['_id']);
  }

  Future<void> loadcomments() async {
    await pollviewModel.getActionComment(widget.src['_id'] ?? 0);
    pollviewModel.allactionComments;
  }

  Future<void> _loadWatermarkImage() async {
    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List list = data.buffer.asUint8List();
    final file = File('${(await getTemporaryDirectory()).path}/watermark.png');
    await file.writeAsBytes(list);
    setState(() {
      // _watermarkSource = WatermarkSource.file(file.path);
    });
  }

  Future<void> _downloadVideo(String url) async {
    setState(() {
      downloading = true;
      progress = "Downloading...";
    });
    try {
      final dio = Dio();
      var status = await Permission.storage.status;

      if (status.isGranted) {
        status = await Permission.storage.request();
        if (status.isGranted) {
          setState(() {
            progress = "Storage permission not granted";
            downloading = false;
          });
          return;
        }
      }

      final directory = Directory('/storage/emulated/0/Download');
      final path =
          '${directory.path}/downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress =
                  "Downloading: ${(received / total * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      final watermarkedPath =
          '${directory.path}/poll_video${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _addWatermark(path, watermarkedPath);
      setState(() {
        progress = "Video downloaded and watermarked successfully!";
        downloadedFiles.add(watermarkedPath);
        Utils.snackBar("Download", "Download video successfully");
      });

      print('Watermarked video saved at: $watermarkedPath');
      final file = File(watermarkedPath);
      print('File exists and is saved correctly.');
      _videoPlayerController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
        });
    } catch (e) {
      setState(() {
        progress = "Failed to download and watermark video.";
      });
      print(e);
    }

    setState(() {
      downloading = false;
    });
  }

  Future<void> _addWatermark(String videoPath, String outputPath) async {
    try {
      // final watermark = Watermark(
      //   image: _watermarkSource,
      //   watermarkSize: WatermarkSize.symmertric(
      //       100), // Set the desired size for the watermark
      //   watermarkAlignment:
      //       WatermarkAlignment.botomRight, // Set the watermark alignment
      //   opacity: 1.0, // Set desired watermark opacity
      // )
      ;

      // final videoWatermark = VideoWatermark(
      //   sourceVideoPath: videoPath,
      //   videoFileName: null,
      //   // watermark: watermark,
      //   outputFormat: OutputFormat.mp4,
      //   savePath: outputPath,
      //   onSave: (outputVideo) {
      //     if (outputVideo != null) {
      //       setState(() {
      //         progress = "Watermark added successfully!";
      //         downloadedFiles.add(outputVideo);
      //       });

      //       final file = File(outputVideo);

      //       _videoPlayerController = VideoPlayerController.file(file)
      //         ..initialize().then((_) {
      //           setState(() {});
      //           _videoPlayerController!.pause();
      //         });
      //     } else {
      //       setState(() {
      //         progress = "Failed to add watermark.";
      //       });
      //     }
      //   },
      //   // progress: (p) {
      //   //   setState(() {
      //   //     progress = "Watermarking: ${(p * 100).toStringAsFixed(0)}%";
      //   //   });
      //   // },
      // );

      // await videoWatermark.generateVideo();
    } catch (e) {
      setState(() {
        progress = "Failed to add watermark.";
      });
      print("Failed to add watermark: $e");
    }
  }

  Future<void> likeDislikeAction(String id, int value) async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken'
    };

    var request = http.Request(
        'POST',
        Uri.parse(
          '${AppUrl.baseUrl}/api/v1/likeDislike/$id'));
            // 'https://pollchat.myappsdevelopment.co.in/api/v1/likeDislike/$id'));
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

  updateIcon() async {
    setState(() {
      _isIconRed = widget.src['liked'];
    });
  }

  List<dynamic> _friendRequests = [];
  Future<void> _fetchFriendRequests() async {
    var token = await userPreference.getAuthToken();
    var response = await http.get(
      Uri.parse(
        '${AppUrl.baseUrl}/api/v1/friend/friendList/'),
          // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/friendList/'),
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

  void supportApi() async {
    var userid = await userPreference.getUserID();
    var token = await userPreference.getAuthToken();
    var url = '${AppUrl.baseUrl}/api/v1/support/$userid';
    // 'http://pollchat.myappsdevelopment.co.in/api/v1/support/$userid';
    var headers = {
      'Authorization': 'Bearer $token',
    };

    var success = await sendPostRequest(url, headers);
    if (success) {
      setState(() {
        _supportingCount++;
      });
    }
  }

  Future<bool> sendPostRequest(String url, Map<String, String> headers) async {
    try {
      var request = http.Request('POST', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var responseJson = jsonDecode(responseBody);
        String message = responseJson['message'] ?? 'Success';
        Utils.snackBar('Success', message);
        return true;
      } else {
        var responseJson = jsonDecode(responseBody);
        String message = responseJson['message'] ??
            response.reasonPhrase ??
            'Error occurred';
        Utils.snackBar('Error', message);
        return false;
      }
    } catch (e) {
      print('An error occurred: $e');
      Utils.snackBar('Error', 'An unexpected error occurred');
      return false;
    }
  }

  Future<void> saveaction(String? id) async {
    var token = await userPreference.getAuthToken();
    // Fixed URL and headers
    var url = '${AppUrl.baseUrl}/api/v1/saved/action/$id';
        // 'https://pollchat.myappsdevelopment.co.in/api/v1/saved/action/$id';
    var headers = {
      'Authorization': 'Bearer $token',
    };

    var request = http.Request('POST', Uri.parse(url));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        print(responseBody); // Handle the response as needed
      } else {
        print(response.reasonPhrase); // Handle error cases
      }
    } catch (e) {
      print('Error: $e'); // Handle exceptions
    }
  }

  var _imageNetworkUrl = null;
  Future<void> initializePlayer() async {
    try {
      String? action = widget.src['action'];
      print(action);

      if (action != null &&
          (action.endsWith('.png') ||
              action.endsWith('.jpg') ||
              action.endsWith('.jpeg'))) {
        _imageNetworkUrl = action;
        setState(() {
          musicModelController
              .playMusic(widget.src['musicId']?['music'] ?? "no music");
        });
      } else {
        _videoPlayerController = VideoPlayerController.network(action!);
        await _videoPlayerController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          aspectRatio: _videoPlayerController!.value.aspectRatio != 0
              ? _videoPlayerController!.value.aspectRatio
              : 16 / 9, // Set a default aspect ratio if it's zero
          autoPlay: true,
          showControls: false,
          looping: true,
        );
        setState(() {
          musicModelController
              .playMusic(widget.src['musicId']?['music'] ?? "no music");
        });
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!(e.toString());
      }
    }
  }

  void _showCommentScreen(BuildContext context, String actionId) async {
    final pollviewModel = Get.find<PollModel>();
    await pollviewModel.getActionComment(actionId);
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
                        child: pollviewModel.allactionComments.isEmpty
                            ? pollviewModel.loading.value
                                ? const Center(
                                    child: ShimmerListView(itemCount: 10))
                                : const Center(child: Text('No comments yet'))
                            : ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount:
                                    pollviewModel.allactionComments.length,
                                itemBuilder: (context, index) {
                                  var comment =
                                      pollviewModel.allactionComments[index];
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
                                  await pollviewModel.addCommentAction(
                                      actionId, _commentController.text);
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

  // void _showPollCommentScreen(BuildContext context, String actionId) async {
  //   final pollviewModel = Get.find<PollModel>();
  //   await pollviewModel.getActionComment(actionId);

  //   showModalBottomSheet(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(10.0),
  //     ),
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (BuildContext context) {
  //       return GetBuilder<PollModel>(
  //         builder: (pollviewModel) => DraggableScrollableSheet(
  //           expand: false,
  //           initialChildSize: 0.9, // Full screen size
  //           minChildSize: 0.9, // Full screen size
  //           maxChildSize: 0.9, // Full screen size
  //           builder: (BuildContext context, ScrollController scrollController) {
  //             return Container(
  //               padding: EdgeInsets.only(
  //                 bottom: MediaQuery.of(context).viewInsets.bottom,
  //               ),
  //               decoration: const BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(20.0),
  //                   topRight: Radius.circular(20.0),
  //                 ),
  //               ),
  //               child: Column(
  //                 children: [
  //                   const SizedBox(height: 10),
  //                   Center(
  //                     child: Container(
  //                       decoration: const BoxDecoration(
  //                         color: Colors.black,
  //                         borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //                       ),
  //                       margin: const EdgeInsets.only(bottom: 10),
  //                       height: 5,
  //                       width: 50,
  //                     ),
  //                   ),
  //                   const Center(child: Text("Comments")),
  //                   Expanded(
  //                     child: pollviewModel.allactionComments.isEmpty
  //                         ? const Center(child: Text('No comments yet'))
  //                         : ListView.builder(
  //                             controller: scrollController,
  //                             shrinkWrap: true,
  //                             itemCount: pollviewModel.allactionComments.length,
  //                             itemBuilder: (context, index) {
  //                               var comment =
  //                                   pollviewModel.allactionComments[index];
  //                               return ListTile(
  //                                 leading: CircleAvatar(
  //                                   radius: 20,
  //                                   backgroundImage: NetworkImage(
  //                                     '${comment["userId"]["profilePhoto"]}',
  //                                   ),
  //                                 ),
  //                                 title: Text('${comment["userId"]["name"]}'),
  //                                 subtitle: Text('${comment["comment"]}'),
  //                                 trailing: Text(
  //                                   "${timeago.format(DateTime.parse(comment["createdAt"]))}",
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                     decoration: BoxDecoration(
  //                       color: AppColor.purpleLightColor.withOpacity(0.1),
  //                       borderRadius: const BorderRadius.only(
  //                         topLeft: Radius.circular(0.0),
  //                         topRight: Radius.circular(0.0),
  //                       ),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: TextField(
  //                             controller: _commentController,
  //                             decoration: const InputDecoration(
  //                               border: OutlineInputBorder(
  //                                   borderSide: BorderSide.none),
  //                               hintText: 'Add a comment...',
  //                             ),
  //                           ),
  //                         ),
  //                         IconButton(
  //                           icon: const Icon(Icons.send),
  //                           onPressed: () async {
  //                             if (_commentController.text.isNotEmpty) {
  //                               await pollviewModel.addComment(
  //                                   actionId, _commentController.text);
  //                               _commentController.clear();
  //                               pollviewModel.update();
  //                             }
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  void showShareScreen(BuildContext context) {
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DisplayImageStory(
                            imagePath: _imageNetworkUrl,
                          ),
                        ),
                      );
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
                      Get.back();

                      // _loadWatermarkImage();
                      //_downloadVideo(widget.src['action']);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoDownloadAndPlayScreen()),
                      );

                      // shareContent();
                      //    _downloadAndAddWatermarkToVideo(widget.src['action']);
                      //  Get.back();
                      // await _addWatermarkToVideo(widget.src['action']);
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
                              Get.toNamed(
                                '/chatpage',
                                arguments: {
                                  'user': user,
                                  'action': widget.src['action'] ?? '',
                                },
                              );
                              _videoPlayerController!.dispose();
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: ClipPath(
                                    clipper: OctagonClipper(),
                                    child: user['profilePhoto'] != null &&
                                            user['profilePhoto']!.isNotEmpty
                                        ? SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: CachedNetworkImage(
                                              imageUrl: user['profilePhoto']!
                                                  .toString(),
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          )
                                        : const Icon(Icons.person,
                                            size:
                                                50), // Default icon or image when imageUrl is null or empty
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user['name'] ?? "",
                                  style: const TextStyle(
                                    color: AppColor.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _chewieController?.dispose();
    player.dispose();
    musicModelController.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.blackColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageNetworkUrl != null
                        ? Expanded(
                            child: InkWell(
                              child: Image.network(
                                _imageNetworkUrl!,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          )
                        : _chewieController != null
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    if (_videoPlayerController!
                                        .value.isPlaying) {
                                      _videoPlayerController!.pause();
                                    } else {
                                      _videoPlayerController!.play();
                                    }
                                  });
                                },
                                child: AspectRatio(
                                  aspectRatio: _chewieController!.aspectRatio!,
                                  child: Chewie(
                                    controller: _chewieController!,
                                  ),
                                ))
                            : Image.asset(
                                'assets/images/logo.png',
                                height: 50,
                                width: 50,
                              )
                  ],
                ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteName.userprofileview,
                                    arguments: widget.src);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin:
                                    const EdgeInsets.only(bottom: 5, right: 0),
                                child: ClipPath(
                                  clipper: OctagonClipper(),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.network(
                                      fit: BoxFit.cover,
                                      widget.src != null &&
                                              widget.src['userId']
                                                      ['profilePhoto'] !=
                                                  null
                                          ? widget.src['userId']['profilePhoto']
                                              .toString()
                                          : 'assets/images/logo.png',
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Image.asset(
                                          'assets/images/logo.png',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 10, left: 5),
                            //   child: Text(
                            //     widget.src['userId']['name'] ?? "",
                            //     style: const TextStyle(
                            //       fontWeight: FontWeight.bold,
                            //       color: Colors.white,
                            //     ),
                            //   ),
                            // ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteName.userprofileview,
                                    arguments: widget.src);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, left: 5),
                                child: Text(
                                  widget.src['userId']['name'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                supportApi();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.only(top: 5),
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: AppColor.whiteColor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    "Support $_supportingCount",
                                    style: const TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, bottom: 10),
                          child: Text(
                            widget.src['actionCaption'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.music_note_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  // widget.src['musicId']['musicName'] ?? "",

                                  widget.src['musicId']?['musicName'] ??
                                      "no music",

                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
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
                                color: _isIconRed
                                    ? AppColor.purpleColor
                                    : Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  _isIconRed
                                      ? (widget.src['likeCount'] + 1).toString()
                                      : (widget.src['likeCount']).toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
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
                                color: _isIconUnlike
                                    ? AppColor.purpleColor
                                    : Colors.white,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  _isIconUnlike
                                      ? (widget.src['dislikeCount'] + 1)
                                          .toString()
                                      : (widget.src['dislikeCount']).toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            pollviewModel.getActionComment(widget.src['_id']);
                            setState(() {
                              _showCommentScreen(context, widget.src['_id']);
                            });
                          },
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                IconAssets.commentsWhiteIcon,
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    widget.src['commentCount']?.toString() ??
                                        "0",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  )),
                            ],
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
                        downloading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: AppColor.purpleColor))
                            : IconButton(
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  //  _loadWatermarkImage();
                                  _downloadVideo(widget.src['action']);
                                },
                              ),
                        IconButton(
                          icon: Icon(
                            _isBookmark
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                          ),
                          color: _isBookmark
                              ? AppColor.purpleColor
                              : AppColor.whiteColor,
                          onPressed: () {
                            setState(() {
                              _isBookmark = !_isBookmark;
                              saveaction(widget.src["_id"]);
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
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          child: const Icon(
                            Icons.multitrack_audio_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
