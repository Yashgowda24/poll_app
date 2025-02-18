import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/action_view/components/stickers.dart';
import 'package:poll_chat/view/action_view/components/stickerstype.dart';
import 'package:poll_chat/view/action_view/storycreate/bottomsheetfilter.dart';
import 'package:poll_chat/view/action_view/storycreate/storycontroller.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

String? filteredImagePath = '';

enum FilterType {
  GRAYSCALE,
  SEPIA,
  ANTIQUE,
  BLUR,
}

List<CameraDescription>? _cameras;
final List<Sticker> _stickers = [];
final List<String> stickerUrls = [
  'assets/images/brainstorm.png',
  'assets/images/catlover.png',
  'assets/images/creativity.png',
  'assets/images/dog.png',
  'assets/images/rocket.png',
  'assets/images/cupcake.png',
  'assets/images/morning.png',
  'assets/images/afternoon.png',
  'assets/images/night.png',
];

class GroupChatScreen extends StatefulWidget {
  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final cameraModelController = Get.put(StoryViewModel());
  final player = AudioPlayer();
  PlayerState playerState = PlayerState.stopped;
  CameraController? controller;
  XFile? video;
  XFile? pickedProfile;
  var toggle = true;
  var flash_toggle = false;
  var onPress = false;
  Future<void> toggleFlash() async {
    await controller!.setFlashMode(
      flash_toggle ? FlashMode.off : FlashMode.torch,
    );
    setState(() => flash_toggle = !flash_toggle);
  }

  getCamera() async {
    setState(() {
      availableCameras().then((value) {
        _cameras = value;
        controller = CameraController(_cameras![0], ResolutionPreset.max);
        controller!.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        }).catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                break;
              default:
                break;
            }
          }
        });
      });
    });
  }

  @override
  void initState() {
    getCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Send Picture",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SizedBox(
        height: h,
        width: w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                bottom: 0,
                top: 0,
                right: 0,
                left: 0,
                child: CameraPreview(controller!)),
            Positioned(
                bottom: 40,
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: toggleFlash,
                        icon: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            flash_toggle ? Colors.purple : Colors.transparent,
                            BlendMode.srcATop,
                          ),
                          child: Image.asset(
                            "assets/images/flashIcon.png",
                            height: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 80,
                      width: 80,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white70,
                          width: 3,
                        ),
                      ),
                      child: GestureDetector(
                        onLongPressEnd: (details) async {
                          setState(() {
                            onPress = false;
                          });
                          // Stop video recording
                          video = await controller!.stopVideoRecording();
                          cameraModelController.addPostStoryDetails(video!);
                          setState(() {
                            player.pause();
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DisplayGroupChatVideoScreen(
                                videoPath: video!,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          setState(() {
                            onPress = true;
                          });
                          _startRecording();
                        },
                        onTap: () async {
                          try {
                            final image = await controller!.takePicture();
                            cameraModelController.addPostStoryDetails(image);
                            if (!context.mounted) return;
                            player.pause();

                            controller!.setFlashMode(FlashMode.off);

                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DisplayGroupChatImage(
                                  imagePath: image.path,
                                ),
                              ),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              "assets/images/chatcamera.png",
                              height: 70,
                              width: 70,
                            ),
                            if (onPress)
                              const Positioned.fill(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.red),
                                  strokeWidth: 4.0,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Hold for video, tap for photo",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                )),
            Positioned(
                left: 30,
                bottom: 50 + 35,
                child: SizedBox(
                    height: 45,
                    width: 45,
                    child: IconButton(
                      onPressed: () {
                        checkPermissions();
                      },
                      icon: Image.asset("assets/images/galleryIcon2.png"),
                    ))),
            Positioned(
                right: 25,
                bottom: 50 + 25,
                child: SizedBox(
                    height: 60,
                    width: 60,
                    child: IconButton(
                      onPressed: () {
                        controller = CameraController(
                            _cameras![toggle ? 1 : 0], ResolutionPreset.max);
                        setState(() {
                          toggle = !toggle;
                        });

                        controller!.initialize().then((_) {
                          if (!mounted) {
                            return;
                          }
                          setState(() {});
                        }).catchError((Object e) {
                          if (e is CameraException) {
                            switch (e.code) {
                              case 'CameraAccessDenied':
                                break;
                              default:
                                break;
                            }
                          }
                        });
                      },
                      icon: Image.asset("assets/images/flipCam.png"),
                    )))
          ],
        ),
      ),
    );
  }

  Future<void> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted &&
        statuses[Permission.storage] != PermissionStatus.granted) {
      print("Camera or storage permission not granted.");
    } else {
      print("Permissions checked and granted.");
    }
    _pickProfile();
  }

  Future<void> _pickProfile() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    bool? isImage = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select media type'),
          content: const Text('Do you want to pick an image or a video?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Pick image
              },
              child: const Text('Image'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Pick video
              },
              child: const Text('Video'),
            ),
          ],
        );
      },
    );

    if (isImage != null) {
      if (isImage) {
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
      } else {
        pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        setState(() {
          cameraModelController.addPostStoryDetails(
            pickedFile!,
          );
        });

        player.pause();
        if (isImage) {
          player.pause();
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayGroupChatImage(
              imagePath: pickedFile!.path,
            ),
          ));
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayGroupChatVideoScreen(
                videoPath: pickedFile!,
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _play(var audioUrl) async {
    await player.play(UrlSource(audioUrl));
  }

  Future<void> _pause() async {
    await player.pause();
  }

  Future<void> _startRecording() async {
    // Start video recording
    // final path = (await getTemporaryDirectory()).path+'${DateTime.now()}.mp4';
    await controller!.startVideoRecording();
    if (!context.mounted) return;
  }
}

class DisplayGroupChatVideoScreen extends StatefulWidget {
  final XFile videoPath;

  DisplayGroupChatVideoScreen({super.key, required this.videoPath});

  @override
  State<DisplayGroupChatVideoScreen> createState() =>
      _DisplayGroupChatVideoScreenState();
}

class _DisplayGroupChatVideoScreenState
    extends State<DisplayGroupChatVideoScreen> {
  final cameraModelController = Get.put(StoryViewModel());
  double playbackSpeed = 1.0;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    _controller = VideoPlayerController.file(
      File(widget.videoPath.path),
    );
    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.play();
    _controller!.setLooping(true);
    super.initState();
    filteredImagePath == widget.videoPath.path;
  }

  @override
  void dispose() {
    // _controller!.pause();
    _controller!.dispose();

    super.dispose();
  }

  Future<void> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted &&
        statuses[Permission.storage] != PermissionStatus.granted) {
      print("Camera or storage permission not granted.");
    } else {
      print("Permissions checked and granted.");
    }
    _pickProfile();
  }

  Future<void> _pickProfile() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    bool? isImage = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select media type'),
          content: const Text('Do you want to pick an image or a video?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Pick image
              },
              child: const Text('Image'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Pick video
              },
              child: const Text('Video'),
            ),
          ],
        );
      },
    );

    if (isImage != null) {
      if (isImage) {
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
      } else {
        pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        setState(() {
          cameraModelController.addPostStoryDetails(
            pickedFile!,
          );
        });

        //player.pause();
        if (isImage) {
          // player.pause();
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayGroupChatImage(
              imagePath: pickedFile!.path,
            ),
          ));
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayGroupChatVideoScreen(
                videoPath: pickedFile!,
              ),
            ),
          );
        }
      }
    }
  }

  void removeSticker(Sticker sticker) {
    setState(() {
      _stickers.remove(sticker);
    });
  }

  void _showStickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.count(
          crossAxisCount: 3,
          children: List.generate(stickerUrls.length, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _stickers.add(
                    Sticker(
                      imageUrl: stickerUrls[index],
                    ),
                  );
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(stickerUrls[index]),
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _trimVideo(String startTime, String endTime) async {
    final Directory tempDir = Directory.systemTemp;
    filteredImagePath = '${tempDir.path}/trimmed_video.mp4';
    final List<String> command = [
      '-i',
      widget.videoPath.path,
      '-ss',
      startTime,
      '-to',
      endTime,
      filteredImagePath!,
    ];

    try {
      //await flutterFFmpeg.executeWithArguments(command);
      print('Video trimmed successfully. Output path: $filteredImagePath');
      _controller = VideoPlayerController.file(File(filteredImagePath!));
      await _controller!.initialize();
      await _controller!.play();
      setState(() {}); // Trigger a rebuild to show the trimmed video
    } catch (e) {
      print('Error trimming video: $e');
    }
  }

  Future<void> _showTrimDialog() async {
    String startTime = '00:00:05';
    String endTime = '00:00:10';

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Set Start and End Time",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text("Start Time: $startTime"),
                  Slider(
                    value: double.parse(startTime.split(':')[2]),
                    min: 0,
                    max: 59,
                    onChanged: (double value) {
                      setState(() {
                        startTime =
                            '00:00:${value.toInt().toString().padLeft(2, '0')}';
                      });
                    },
                  ),
                  Text("End Time: $endTime"),
                  Slider(
                    value: double.parse(endTime.split(':')[2]),
                    min: 0,
                    max: 59,
                    onChanged: (double value) {
                      setState(() {
                        endTime =
                            '00:00:${value.toInt().toString().padLeft(2, '0')}';
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _trimVideo(startTime, endTime);
                    },
                    child: const Text('Trim Video'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> applySlowMotion() async {
    final Directory tempDir = Directory.systemTemp;
    filteredImagePath = '${tempDir.path}/slow_motion.mp4';
    final List<String> command = [
      '-i',
      widget.videoPath.path,
      '-filter:v',
      'setpts=${(1 / playbackSpeed)}*PTS',
      filteredImagePath!,
    ];

    try {
      //await flutterFFmpeg.executeWithArguments(command);
      await _controller!.pause();
      await _controller!.dispose();
      _controller = VideoPlayerController.file(File(filteredImagePath!))
        ..initialize().then((_) {
          setState(() {
            filteredImagePath = widget.videoPath.path;
          });
        });
    } catch (e) {
      print('Error applying slow motion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Send Video",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          InkWell(
              onTap: () {
                Get.toNamed(RouteName.choosepage,
                    arguments: filteredImagePath.toString());
                //cameraModelController.createStoryPost(filteredImagePath!);
                _controller!.dispose();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColor.purpleColor,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: Text(
                      'Next',
                      style: TextStyle(
                          color: AppColor.whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),

          Positioned(
              top: 80,
              right: 15,
              child: Column(
                children: [
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => BottomSheetContent(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0)),
                            ),
                            isScrollControlled: true,
                          );

                          // showModalBottomSheet(
                          //   context: context,
                          //   builder: (BuildContext context) {
                          //     return Container(
                          //       padding: const EdgeInsets.all(16),
                          //       child: Column(
                          //         mainAxisSize: MainAxisSize.min,
                          //         crossAxisAlignment:
                          //             CrossAxisAlignment.stretch,
                          //         children: [
                          //           const Text(
                          //             "Choose filter to apply:",
                          //             textAlign: TextAlign.center,
                          //             style: TextStyle(fontSize: 18),
                          //           ),
                          //           const SizedBox(height: 16),
                          //           TextButton(
                          //             onPressed: () async {
                          //               Navigator.of(context).pop();
                          //               // await _videoFilter1(FilterType.SEPIA);
                          //             },
                          //             child: const Row(
                          //               children: [
                          //                 CircleAvatar(
                          //                   radius: 27,
                          //                   backgroundImage: AssetImage(
                          //                     "assets/images/black.jpg",
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: 8),
                          //                 Text("Black & White"),
                          //               ],
                          //             ),
                          //           ),
                          //           const SizedBox(height: 8),
                          //           TextButton(
                          //             onPressed: () async {
                          //               Navigator.of(context).pop();
                          //               // await _videoFilter2(
                          //               //     FilterType.GRAYSCALE);
                          //             },
                          //             child: const Row(
                          //               children: [
                          //                 CircleAvatar(
                          //                   radius: 27,
                          //                   backgroundImage: AssetImage(
                          //                     "assets/images/black.jpg",
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: 8),
                          //                 Text("Sepia"),
                          //               ],
                          //             ),
                          //           ),
                          //           const SizedBox(height: 8),
                          //           TextButton(
                          //             onPressed: () async {
                          //               Navigator.of(context).pop();
                          //               // await _videoFilter3(FilterType.ANTIQUE);
                          //             },
                          //             child: const Row(
                          //               children: [
                          //                 CircleAvatar(
                          //                   radius: 27,
                          //                   backgroundImage: AssetImage(
                          //                     "assets/images/antique.jpg",
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: 8),
                          //                 Text("Antique"),
                          //               ],
                          //             ),
                          //           ),
                          //           const SizedBox(height: 8),
                          //           TextButton(
                          //             onPressed: () async {
                          //               Navigator.of(context).pop();
                          //               // await _videoFilter4(FilterType.BLUR);
                          //             },
                          //             child: const Row(
                          //               children: [
                          //                 CircleAvatar(
                          //                   radius: 27,
                          //                   backgroundImage: AssetImage(
                          //                     "assets/images/bl.jpg",
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: 8),
                          //                 Text("Blur"),
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // );
                        },
                        icon: Image.asset("assets/images/filter1.png"),
                      )),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          // setState(() {
                          //   if (speed != 3) {
                          //     speed = speed + 1;
                          //   } else {
                          //     speed = 1;
                          //   }
                          // });
                          setState(() {
                            if (playbackSpeed == 1.0) {
                              playbackSpeed = 0.5;
                            } else if (playbackSpeed == 0.5) {
                              playbackSpeed = 0.25;
                            } else {
                              playbackSpeed = 1.0;
                            }
                            applySlowMotion();
                          });
                        },
                        icon: Text(
                          "${playbackSpeed}x",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () async {
                          await _showTrimDialog();
                        },
                        icon: Image.asset("assets/images/filter2.png"),
                      )),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(RouteName.musicScreen);
                        },
                        icon: Image.asset("assets/images/filter3.png"),
                      )),
                  IconButton(
                    onPressed: () => _showStickerBottomSheet(),
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/star.png",
                          height: 24,
                          width: 24,
                        ),
                        const Text(
                          'Stickers',
                          style: TextStyle(color: AppColor.whiteColor),
                        )
                      ],
                    ),
                  ),
                ],
              )),
          //CamIcon
          Positioned(
              bottom: 40,
              child: Column(
                children: [
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(RouteName.createstory);
                        },
                        icon: Image.asset("assets/images/chatcamera.png"),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )),

          ..._stickers.map((sticker) {
            return DraggableSticker(
              sticker: sticker,
              onDelete: () {
                setState(() {
                  _stickers.remove(sticker);
                });
              },
            );
          }).toList()
        ],
      ),
    );
  }
}

class DisplayGroupChatImage extends StatefulWidget {
  var imagePath;

  DisplayGroupChatImage({super.key, required this.imagePath});

  @override
  _DisplayGroupChatImageState createState() => _DisplayGroupChatImageState();
}

class _DisplayGroupChatImageState extends State<DisplayGroupChatImage> {
  final cameraModelController = Get.put(StoryViewModel());
  final TextEditingController _controllerText = TextEditingController();

  var speed = 1;
  @override
  void initState() {
    super.initState();
  }

  void removeSticker(Sticker sticker) {
    setState(() {
      _stickers.remove(sticker);
    });
  }

  Future<void> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted &&
        statuses[Permission.storage] != PermissionStatus.granted) {
      print("Camera or storage permission not granted.");
    } else {
      print("Permissions checked and granted.");
    }
    _pickProfile();
  }

  Future<void> _pickProfile() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    bool? isImage = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select media type'),
          content: const Text('Do you want to pick an image or a video?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Pick image
              },
              child: const Text('Image'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Pick video
              },
              child: const Text('Video'),
            ),
          ],
        );
      },
    );

    if (isImage != null) {
      if (isImage) {
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
      } else {
        pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        setState(() {
          cameraModelController.addPostStoryDetails(
            pickedFile!,
          );
        });

        //player.pause();
        if (isImage) {
          // player.pause();
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayGroupChatImage(
              imagePath: pickedFile!.path,
            ),
          ));
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayGroupChatVideoScreen(
                videoPath: pickedFile!,
              ),
            ),
          );
        }
      }
    }
  }

  void _showStickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.count(
          crossAxisCount: 3,
          children: List.generate(stickerUrls.length, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _stickers.add(
                    Sticker(
                      imageUrl: stickerUrls[index],
                    ),
                  );
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(stickerUrls[index]),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Send Picture",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          InkWell(
              onTap: () {
                //cameraModelController.createStoryPost(filteredImagePath!);
                Get.toNamed(RouteName.choosepage,
                    arguments: widget.imagePath.toString());
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Container(
                  decoration: const BoxDecoration(
                      color: AppColor.purpleColor,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: Text(
                      'Next',
                      style: TextStyle(
                          color: AppColor.whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height - 50,
              width: MediaQuery.of(context).size.width,
              child: Image.file(
                File(
                  widget.imagePath!,
                ),
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              )),
          Positioned(
              top: 80,
              right: 15,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => BottomSheetContent(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0)),
                          ),
                          isScrollControlled: true,
                        );
                      },
                      icon: Image.asset("assets/images/filter1.png"),
                    ),
                  ),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (speed != 3) {
                              speed = speed + 1;
                            } else {
                              speed = 1;
                            }
                          });
                        },
                        icon: Text(
                          "${speed}x",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset("assets/images/filter2.png"),
                      )),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          //Get.toNamed(RouteName.musicScreen);
                        },
                        icon: Image.asset("assets/images/filter3.png"),
                      )),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: SizedBox(
                              height: 120,
                              child: Column(
                                children: [
                                  TextField(
                                      controller: _controllerText,
                                      decoration: const InputDecoration(
                                          hintText: 'type..',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 5.0),
                                          ))),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pop(_controllerText.text);
                                        },
                                        child: Container(
                                            height: 30,
                                            width: 70,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: AppColor.purpleColor),
                                            child: const Center(
                                              child: Text(
                                                "Add",
                                                style: TextStyle(
                                                    color: AppColor.whiteColor),
                                              ),
                                            )),
                                      ))
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Column(
                      children: [
                        Text(
                          'T',
                          style: TextStyle(
                              color: AppColor.whiteColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Text',
                          style: TextStyle(
                              color: AppColor.whiteColor,
                              fontSize: 10,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showStickerBottomSheet(),
                    // onPressed: () {
                    //   Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (context) => StickerEditorDemo(),
                    //     ),
                    //   );
                    // },
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/star.png",
                          height: 24,
                          width: 24,
                        ),
                        const Text(
                          'Stickers',
                          style: TextStyle(color: AppColor.whiteColor),
                        )
                      ],
                    ),
                  ),
                ],
              )),
          Positioned(
              bottom: 40,
              child: Column(
                children: [
                  Text(
                    _controllerText.text,
                    style: const TextStyle(
                        color: AppColor.whiteColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: IconButton(
                        onPressed: () {
                          // Get.toNamed(RouteName.createstory);
                        },
                        icon: Image.asset("assets/images/chatcamera.png"),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )),
          ..._stickers.map((sticker) {
            return DraggableSticker(
              sticker: sticker,
              onDelete: () {
                setState(() {
                  _stickers.remove(sticker);
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
