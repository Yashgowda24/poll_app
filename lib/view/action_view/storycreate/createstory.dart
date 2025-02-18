import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/imagefilter/filters/filters.dart';
import 'package:poll_chat/imagefilter/filters/preset_filters.dart';
import 'package:poll_chat/imagefilter/widgets/photo_filter.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/action_view/components/dragbletext.dart';
import 'package:poll_chat/view/action_view/components/reels/stickernew.dart';
import 'package:poll_chat/view/action_view/components/stickers.dart';
import 'package:poll_chat/view/action_view/components/stickerstype.dart';
import 'package:poll_chat/view/action_view/storycreate/storycontroller.dart';
import 'package:poll_chat/view_models/controller/music_view_model.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as imagelib;

String? filteredImagePath = '';

enum FilterType {
  GRAYSCALE,
  SEPIA,
  ANTIQUE,
  BLUR,
}

List<CameraDescription>? _cameras;

class CreateStoryScreen extends StatefulWidget {
  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final cameraModelControllerStory = Get.put(StoryViewModel());
  final player = AudioPlayer();
  PlayerState playerState = PlayerState.stopped;
  CameraController? controller;
  XFile? video;
  XFile? pickedProfile;
  var toggle = true;
  var flash_toggle = false;
  var onPress = false;

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

  Future<void> toggleFlash() async {
    await controller!.setFlashMode(
      flash_toggle ? FlashMode.off : FlashMode.torch,
    );
    setState(() => flash_toggle = !flash_toggle);
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
          "Create Moment",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // actions: [
        //   InkWell(
        //       onTap: () {
        //         cameraModelController.createStoryPost(filteredImagePath!);
        //       },
        //       child: Padding(
        //         padding: const EdgeInsets.only(right: 15),
        //         child: Container(
        //           decoration: const BoxDecoration(
        //               color: AppColor.purpleColor,
        //               borderRadius: BorderRadius.all(Radius.circular(25))),
        //           child: const Padding(
        //             padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        //             child: Text(
        //               'Post',
        //               style: TextStyle(
        //                   color: AppColor.whiteColor,
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w500),
        //             ),
        //           ),
        //         ),
        //       )),
        // ],
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
            // Add your UI elements on top of the camera preview here
            //CamIcon
            Positioned(
                bottom: 40,
                child: Column(
                  children: [
                    // SizedBox(
                    //     height: 40,
                    //     width: 40,
                    //     child: IconButton(
                    //       onPressed: () {
                    //         // setState(() {
                    //         controller!.setFlashMode(
                    //             flash_toggle ? FlashMode.off : FlashMode.torch);
                    //         setState(() {
                    //           flash_toggle = !flash_toggle;
                    //         });
                    //         // });
                    //       },
                    //       icon: Image.asset("assets/images/flashIcon.png"),
                    //     )),
                    IconButton(
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
                          await controller!.setFlashMode(FlashMode.off);

                          cameraModelControllerStory
                              .addPostStoryDetails(video!);
                          setState(() {
                            player.pause();
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DisplayStoryScreen(
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
                            cameraModelControllerStory
                                .addPostStoryDetails(image);
                            if (!context.mounted) return;
                            player.pause();

                            controller!.setFlashMode(FlashMode.off);

                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DisplayImageStory(
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
                              "assets/images/camIcon.png",
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

                    // Container(
                    //     height: 80,
                    //     width: 80,
                    //     padding: const EdgeInsets.all(2),
                    //     decoration: onPress
                    //         ? BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             border: Border.all(
                    //               color: Colors.white70,
                    //               width: 3,
                    //             ))
                    //         : const BoxDecoration(),
                    //     child: GestureDetector(
                    //       onLongPressEnd: (details) async {
                    //         setState(() {
                    //           onPress = false;
                    //         });
                    //         // Stop video recording

                    //         video = await controller!.stopVideoRecording();
                    //         cameraModelControllerStory.addPostStoryDetails(video!);
                    //         setState(() {
                    //           player.pause();
                    //         });

                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) => DisplayStoryScreen(
                    //               videoPath: video!,
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //       onLongPress: () {
                    //         setState(() {
                    //           onPress = true;
                    //         });
                    //         //_play(Get.arguments["musicId"]);
                    //         _startRecording();
                    //       },
                    //       onTap: () async {
                    //         try {
                    //           final image = await controller!.takePicture();

                    //           cameraModelControllerStory.addPostStoryDetails(image);
                    //           if (!context.mounted) return;
                    //           player.pause();
                    //           var flash_toggle = false;

                    //           controller!.setFlashMode(FlashMode.off);
                    //           setState(() {
                    //             flash_toggle = !flash_toggle;
                    //           });

                    //           await Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //               builder: (context) => DisplayImageStory(
                    //                 imagePath: image.path,
                    //               ),
                    //             ),
                    //           );
                    //         } catch (e) {
                    //           print(e);
                    //         }
                    //       },
                    //       child: Image.asset("assets/images/camIcon.png"),
                    //     )),

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
          cameraModelControllerStory.addPostStoryDetails(
            pickedFile!,
          );
        });

        player.pause();
        if (isImage) {
          player.pause();
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayImageStory(
              imagePath: pickedFile!.path,
            ),
          ));
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayStoryScreen(
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

class DisplayStoryScreen extends StatefulWidget {
  final XFile videoPath;

  DisplayStoryScreen({super.key, required this.videoPath});

  @override
  State<DisplayStoryScreen> createState() => _DisplayStoryScreenState();
}

class _DisplayStoryScreenState extends State<DisplayStoryScreen> {
  final cameraModelControllerStory = Get.put(StoryViewModel());
  Offset _textPosition = Offset(100, 100); // Set initial position here
  bool _isTextVisible = true; // Control visibility of draggable text
  TextEditingController _controllerText =
      TextEditingController(); // Ensure this is initialized

  double playbackSpeed = 1.0;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  TextEditingController _searchController = TextEditingController();
  final player = AudioPlayer();
  Map<String, dynamic>? _selectedMusic;
  void _removeText() {
    setState(() {
      _isTextVisible = false;
      _controllerText.clear();
    });
  }

  // String fileName = "";
  // List<Filter> filters = presetFiltersList;
  // final picker = ImagePicker();
  // File? imageFile;

  final List<Sticker> _stickers = [];
  Uint8List? _editedImage;
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
  String filteredVideoPath = '';
  final musicModelController = Get.put(MusicViewModel());
  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.videoPath.path)
        // imageFile == null ? File(widget.videoPath.path) : File(imageFile!.path),
        );

    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.setLooping(true);
    musicModelController.getallMusic();
    _controller!.play();

    super.initState();
    filteredImagePath == widget.videoPath.path;
  }

  void musicMethod() async {
    _controller!.play();
    if (_selectedMusic != null) {
      setState(() {
        musicModelController.playMusic(_selectedMusic!["music"]);
      });
    }
  }

  List musiclist = [
    "StaySolidRocky",
    "Giveon",
    "The Weeknd",
    "Demi Lovato, Sam..."
  ];
  List musicimg = [
    "assets/images/music1.png",
    "assets/images/music2.png",
    "assets/images/music3.png",
    "assets/images/music4.png"
  ];

  Future<void> showMusicBottomSheet() async {
    setState(() {
      musicModelController.allMusic;
      _controller!.play();
    });

    final result = await Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (val) {
                  _searchController.text = val;
                },
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: musicModelController.allMusic.length,
                itemBuilder: (context, index) {
                  if (musicModelController.allMusic[index]["musicName"]
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context, {
                          "musicId": musicModelController.allMusic[index]
                              ["_id"],
                          "music": musicModelController.allMusic[index]["music"]
                        });
                        // _controller!.play();
                      },
                      child: ListTile(
                        title: Text(
                          musicModelController.allMusic[index]["musicName"],
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                            musicModelController.allMusic[index]["singer"]),
                        leading:
                            Image.asset(musicimg[index % musiclist.length]),
                        trailing: Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF781069), width: 2),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF781069),
                            ),
                            onPressed: () async {
                              Navigator.pop(context, {
                                "musicId": musicModelController.allMusic[index]
                                    ["_id"],
                                "music": musicModelController.allMusic[index]
                                    ["music"],
                              });
                              // _controller!.play();
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMusic = result;
        musicMethod();
        _controller?.play();
      });
    }
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

  final List<String> filterCommands = [
    '', // Original

    'hue=s=0', // Black and White
    'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131', // Sepia
    'negate', // Invert Colors
    'format=gray', // Grayscale
    'boxblur=10:1', // Blur
    'unsharp=5:5:1.0:5:5:0.0', // Sharpen
    'convolution=-2 -1 0 -1 1 1 0 1 2', // Emboss
    'edgedetect=low=0.1:high=0.4', // Edge Detection
    'scale=iw/10:ih/10,scale=iw*10:ih*10', // Pixelate
    'vignette', // Vignette
    'eq=brightness=0.06', // Brightness Adjustment
    'eq=contrast=1.5', // Contrast Adjustment
    'eq=saturation=2', // Saturation Adjustment
  ];

  final List<String> filterNames = [
    'Original',
    'Black & White',
    'Sepia',
    'Invert Colors',
    'Grayscale',
    'Blur',
    'Sharpen',
    'Emboss',
    'Edge Detection',
    'Pixelate',
    'Vignette',
    'Brightness ',
    'Contrast ',
    'Saturation ',
  ];
  final List<String> filterImages = [
    'assets/images/logo.png',
    'assets/images/cta.png',
    'assets/images/sepia.jpg',
    'assets/images/bl.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
    'assets/images/sepia.jpg',
  ];

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.count(
          crossAxisCount: 3,
          children: List.generate(filterCommands.length, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (filterCommands[index].isEmpty) {
                  setState(() {
                    filteredVideoPath = widget.videoPath.path;
                    _controller!.dispose();
                    _controller =
                        VideoPlayerController.file(File(filteredVideoPath));
                    _initializeVideoPlayerFuture = _controller!.initialize();
                    _controller!.play();
                    _controller!.setLooping(true);
                  });
                } else {
                  applyFilterToVideo(filterCommands[index]);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        filterImages[index],
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      filterNames[index],
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> applyFilterToVideo(String filterCommand) async {
    String inputPath = widget.videoPath.path;
    String outputPath = '${Directory.systemTemp.path}/filtered_video.mp4';

    final file = File(outputPath);
    if (file.existsSync()) {
      file.deleteSync();
    }

    String command = "-i $inputPath -vf '$filterCommand' $outputPath";

    try {
      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        final allLogs = await session.getAllLogsAsString();
        final failStackTrace = await session.getFailStackTrace();

        print("FFmpeg Command: $command");
        print("Logs: $allLogs");
        print("Error Logs: $failStackTrace");

        if (ReturnCode.isSuccess(returnCode)) {
          print("Filter applied successfully!");
          setState(() {
            filteredVideoPath = outputPath;
          });
          _controller!.dispose();
          _controller = VideoPlayerController.file(File(filteredVideoPath));
          _initializeVideoPlayerFuture = _controller!.initialize();
          _controller!.play();
          _controller!.setLooping(true);
        } else if (ReturnCode.isCancel(returnCode)) {
          print("Filter application cancelled.");
        } else {
          print("Filter application failed.");
        }
      });
    } catch (e) {
      print("Exception while running FFmpeg: $e");
    }
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
          cameraModelControllerStory.addPostStoryDetails(
            pickedFile!,
          );
        });

        //player.pause();
        if (isImage) {
          // player.pause();
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayImageStory(
              imagePath: pickedFile!.path,
            ),
          ));
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayStoryScreen(
                videoPath: pickedFile!,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    player.dispose();
    musicModelController.pause();
    super.dispose();
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
    filteredVideoPath = '${tempDir.path}/trimmed_video.mp4';

    // Delete the existing file if it exists
    final file = File(filteredVideoPath);
    if (file.existsSync()) {
      file.deleteSync();
    }

    final List<String> command = [
      '-i',
      widget.videoPath.path,
      '-ss',
      startTime,
      '-to',
      endTime,
      '-c',
      'copy',
      filteredVideoPath,
    ];

    try {
      await FFmpegKit.executeAsync(command.join(' '), (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          print('Video trimmed successfully. Output path: $filteredVideoPath');

          _controller?.dispose();
          _controller = VideoPlayerController.file(File(filteredVideoPath));
          await _controller!.initialize();
          await _controller!.play();
          _controller!.setLooping(true);
          setState(() {});
        } else {
          print('Error trimming video. Return code: $returnCode');
        }
      });
    } catch (e) {
      print('Error trimming video: $e');
      await _controller!.pause();
    }
  }

  Future<void> _showTrimDialog() async {
    String startTime = '00:00:00';
    String endTime = '00:00:02';

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
    try {
      await _controller?.setPlaybackSpeed(playbackSpeed);
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
          "Share Moment",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Obx(() {
            return InkWell(
              onTap: () async {
                if (cameraModelControllerStory.loading.value) return;

                await cameraModelControllerStory
                    .createStoryPost(filteredImagePath!);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: !cameraModelControllerStory.loading.value,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: AppColor.purpleColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                          child: Text('Post',
                              style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    if (cameraModelControllerStory.loading.value)
                      const CircularProgressIndicator(
                        color: AppColor.purpleColor,
                      ),
                  ],
                ),
              ),
            );
          }),
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
                          _showFilterBottomSheet();
                        },
                        icon: Image.asset("assets/images/filter1.png"),
                      )),
                  SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {
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
                          showMusicBottomSheet();
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
                  // Text(
                  //   _controllerText.text,
                  //   style: const TextStyle(
                  //       color: AppColor.whiteColor,
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w600),
                  // ),
                  //           ..._stickers.map((sticker) {
                  //   return DraggableSticker(
                  //     sticker: sticker,
                  //     onDelete: () {
                  //       setState(() {
                  //         _stickers.remove(sticker);
                  //       });
                  //     },
                  //   );
                  // }),
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(RouteName.createstory);
                        },
                        icon: Image.asset("assets/images/camIcon.png"),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Moment",
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
                    icon: Image.asset("assets/images/galleryIcon.png"),
                  ))),
          if (_isTextVisible) // Conditionally show the DraggableText
            DraggableText(
              text: _controllerText.text,
              initialPosition: _textPosition,
              onPositionChanged: (newPosition) {
                setState(() {
                  _textPosition = newPosition;
                });
              },
              onRemove: _removeText, // Set the removal function
            ),
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

class DisplayImageStory extends StatefulWidget {
  var imagePath;

  DisplayImageStory({super.key, required this.imagePath});

  @override
  _DisplayImageStoryState createState() => _DisplayImageStoryState();
}

class _DisplayImageStoryState extends State<DisplayImageStory> {
  final cameraModelControllerStory = Get.put(StoryViewModel());

  final musicModelControllerimg = Get.put(MusicViewModel());
  TextEditingController _searchController = TextEditingController();
  Offset _textPosition = Offset(100, 100); // Set initial position here
  bool _isTextVisible = true; // Control visibility of draggable text
  TextEditingController _controllerText =
      TextEditingController(); // Ensure this is initialized

  Map<String, dynamic>? _selectedMusic;
  String fileName = "";
  void _removeText() {
    setState(() {
      _isTextVisible = false;
      _controllerText.clear();
    });
  }

  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? imageFile;
  var speed = 1;
  final List<Sticker> _stickers = [];
  Uint8List? _editedImage;
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
  @override
  void initState() {
    super.initState();
  }

  List musiclist = [
    "StaySolidRocky",
    "Giveon",
    "The Weeknd",
    "Demi Lovato, Sam..."
  ];
  List musicimg = [
    "assets/images/music1.png",
    "assets/images/music2.png",
    "assets/images/music3.png",
    "assets/images/music4.png"
  ];
  void musicMethod() async {
    if (_selectedMusic != null) {
      setState(() {
        musicModelControllerimg.playMusic(_selectedMusic!["music"]);
      });
    }
  }

  Future<void> showMusicImageBottomSheet() async {
    final result = await Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (val) {
                  _searchController.text = val;
                },
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: musicModelControllerimg.allMusic.length,
                itemBuilder: (context, index) {
                  if (musicModelControllerimg.allMusic[index]["musicName"]
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context, {
                          "musicId": musicModelControllerimg.allMusic[index]
                              ["_id"],
                          "music": musicModelControllerimg.allMusic[index]
                              ["music"]
                        });
                      },
                      child: ListTile(
                        title: Text(
                          musicModelControllerimg.allMusic[index]["musicName"],
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                            musicModelControllerimg.allMusic[index]["singer"]),
                        leading:
                            Image.asset(musicimg[index % musiclist.length]),
                        trailing: Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF781069), width: 2),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: Color(0xFF781069),
                            ),
                            onPressed: () async {
                              Navigator.pop(context, {
                                "musicId": musicModelControllerimg
                                    .allMusic[index]["_id"],
                                "music": musicModelControllerimg.allMusic[index]
                                    ["music"],
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMusic = result;
      });
      musicMethod();
    }
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
          cameraModelControllerStory.addPostStoryDetails(
            pickedFile!,
          );
        });

        //player.pause();
        if (isImage) {
          // player.pause();
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayImageStory(
              imagePath: pickedFile!.path,
            ),
          ));
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayStoryScreen(
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

  void getImage() async {
    if (widget.imagePath != null) {
      imageFile = File(widget.imagePath!);
      fileName = path.basename(widget.imagePath!);
      var image = imagelib.decodeImage(await imageFile!.readAsBytes());
      image = imagelib.copyResize(image!, width: 600);
      // imageFile == filteredImagePath!;
      Map imagefile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoFilterSelector(
            title: const Text("Filters"),
            image: image!,
            filters: presetFiltersList,
            filename: fileName,
            loader: const Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );

      if (imagefile.containsKey('image_filtered')) {
        setState(() {
          imageFile = imagefile['image_filtered'];
        });
        debugPrint(imageFile!.path);
      }
    }
  }

  @override
  void dispose() {
    musicModelControllerimg.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Share Moment",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Obx(() {
            return InkWell(
              onTap: () async {
                if (imageFile != null && imageFile != '') {
                  cameraModelControllerStory.createStoryPost(imageFile!.path);
                  print(imageFile!.path.toString());
                } else {
                  cameraModelControllerStory
                      .createStoryPost(filteredImagePath!);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The Post button with conditional visibility of text
                    Visibility(
                      visible: !cameraModelControllerStory.loading.value,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: AppColor.purpleColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                          child: Text('Post',
                              style: TextStyle(
                                  color: AppColor.whiteColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),

                    if (cameraModelControllerStory.loading.value)
                      const CircularProgressIndicator(
                        color: AppColor.purpleColor,
                      ),
                  ],
                ),
              ),
            );
          }),
          // InkWell(
          //     onTap: () {
          //       if (imageFile != null && imageFile != '') {
          //         cameraModelControllerStory.createStoryPost(imageFile!.path);
          //         print(imageFile!.path.toString());
          //       } else {
          //         cameraModelControllerStory
          //             .createStoryPost(filteredImagePath!);
          //       }
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.only(right: 15),
          //       child: Container(
          //         decoration: const BoxDecoration(
          //             color: AppColor.purpleColor,
          //             borderRadius: BorderRadius.all(Radius.circular(25))),
          //         child: const Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          //           child: Text(
          //             'Post',
          //             style: TextStyle(
          //                 color: AppColor.whiteColor,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w500),
          //           ),
          //         ),
          //       ),
          //     )),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          imageFile == null
              ? Image.file(File(widget.imagePath!),
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height - 50,
                  width: MediaQuery.of(context).size.width)
              : Image.file(File(imageFile!.path),
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height - 50,
                  width: MediaQuery.of(context).size.width),
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
                        getImage();
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
                        onPressed: () async {
                          //Get.toNamed(RouteName.musicScreen);
                          showMusicImageBottomSheet();
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
                    // onPressed: () => _showStickerBottomSheet(),
                    onPressed: () {
                      Get.to(() => ImageOverlayPage(
                          imagePath: widget.imagePath!, type: 'story'));
                    },
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
                  // Text(
                  //   _controllerText.text,
                  //   style: const TextStyle(
                  //       color: AppColor.whiteColor,
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w600),
                  // ),
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(RouteName.createstory);
                        },
                        icon: Image.asset("assets/images/camIcon.png"),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Moment",
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
                    icon: Image.asset("assets/images/galleryIcon.png"),
                  ))),
          if (_isTextVisible) // Conditionally show the DraggableText
            DraggableText(
              text: _controllerText.text,
              initialPosition: _textPosition,
              onPositionChanged: (newPosition) {
                setState(() {
                  _textPosition = newPosition;
                });
              },
              onRemove: _removeText, // Set the removal function
            ),
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
