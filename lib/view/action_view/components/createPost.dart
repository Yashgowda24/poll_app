import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:poll_chat/imagefilter/filters/filters.dart';
import 'package:poll_chat/imagefilter/filters/preset_filters.dart';
import 'package:poll_chat/imagefilter/widgets/photo_filter.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/action_view/components/dragbletext.dart';
import 'package:poll_chat/view/action_view/components/reels/stickernew.dart';
import 'package:poll_chat/view_models/controller/music_view_model.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import '../../../view_models/controller/camera_view_model.dart';
import 'package:image/image.dart' as imagelib;

String? filteredImagePath = '';
List<CameraDescription>? _cameras;

class CameraPreviewWidget extends StatefulWidget {
  @override
  _CameraPreviewWidgetState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  final cameraModelController = Get.put(CameraViewModel());

  PlayerState playerState = PlayerState.stopped;
  CameraController? controller;
  XFile? video;
  XFile? pickedProfile;
  var toggle = true;
  var flash_toggle = false;
  var onPress = false;

  @override
  void initState() {
    super.initState();
    getCam();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  Future<void> getCam() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras![0], ResolutionPreset.max);
    await controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Create Action",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          // InkWell(
          //   onTap: () {
          //     if (filteredImagePath != null) {
          //       cameraModelController.createPost(filteredImagePath!);
          //     }
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 15),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: AppColor.purpleColor,
          //         borderRadius: BorderRadius.circular(25),
          //       ),
          //       child: const Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          //         child: Text(
          //           'Post',
          //           style: TextStyle(
          //             color: AppColor.whiteColor,
          //             fontSize: 14,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller!.value.isInitialized)
            CameraPreview(controller!),
          buildBottomControls(),
          buildSideControls(),
        ],
      ),
    );
  }

  Widget buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
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
          GestureDetector(
            onLongPress: () async {
              setState(() => onPress = true);
              await startRecording();
            },
            onTap: () => takePicture(),
            onLongPressEnd: (details) async {
              setState(() => onPress = false);
              if (controller != null) {
                video = await controller!.stopVideoRecording();
                await controller!.setFlashMode(FlashMode.off);
                // cameraModelController.addPostDetails(
                //     video!, Get.arguments?["musicId"] ?? "");
                // player.pause();

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DisplayVideoScreen(videoPath: video!),
                ));
              }
            },
            child: Container(
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        strokeWidth: 4.0,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Text("Hold for video, tap for photo",
              style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildSideControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => checkPermissions(),
              icon: Image.asset(
                "assets/images/galleryIcon2.png",
                height: 30,
              ),
            ),
            IconButton(
              onPressed: () => switchCamera(),
              icon: Image.asset("assets/images/flipCam.png", height: 50),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> toggleFlash() async {
    await controller!.setFlashMode(
      flash_toggle ? FlashMode.off : FlashMode.torch,
    );
    setState(() => flash_toggle = !flash_toggle);
  }

  Future<void> startRecording() async {
    setState(() => onPress = true);
    if (controller != null) {
      await controller!.startVideoRecording();
    } else {
      print("Camera controller is not initialized.");
    }
  }

  Future<void> takePicture() async {
    final image = await controller!.takePicture();
    // Turn off the flash after taking a picture
    await controller!.setFlashMode(FlashMode.off);
    // cameraModelController.addPostDetails(
    //     image, Get.arguments?["musicId"] ?? "");
    // player.pause();
    setState(() {
      controller!.setFlashMode(FlashMode.off);
    });

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(imagePath: image.path)));
  }

  Future<void> switchCamera() async {
    controller =
        CameraController(_cameras![toggle ? 1 : 0], ResolutionPreset.max);
    await controller!.initialize();
    if (!mounted) return;
    setState(() => toggle = !toggle);
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
          // cameraModelController.addPostDetails(
          //     pickedFile!, Get.arguments?["musicId"] ?? "");
        });

        if (isImage) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayPictureScreen(
                imagePath: pickedFile!.path,
              ),
            ),
          );
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayVideoScreen(
                videoPath: pickedFile!,
              ),
            ),
          );
        }
      }
    }
  }
}

class DisplayPictureScreen extends StatefulWidget {
  String? imagePath;

  DisplayPictureScreen({required this.imagePath});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final cameraModelController = Get.put(CameraViewModel());
  String fileName = "";
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? imageFile;
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
  final musicModelControllerimg = Get.put(MusicViewModel());
  TextEditingController _searchController = TextEditingController();
  Offset _textPosition = const Offset(100, 100);
  bool _isTextVisible = true;
  final TextEditingController _controllerText = TextEditingController();

  void _removeText() {
    setState(() {
      _isTextVisible = false;
      _controllerText.clear();
    });
  }

  Map<String, dynamic>? _selectedMusic;
  final List<Sticker> _stickers = [];
  void removeSticker(Sticker sticker) {
    setState(() {
      _stickers.remove(sticker);
    });
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
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
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
      shape: const RoundedRectangleBorder(
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
          cameraModelController.createPost(
            pickedFile!.path,
          );
        });

        //player.pause();
        if (isImage) {
          // player.pause();
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(
              imagePath: pickedFile!.path,
            ),
          ));
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayVideoScreen(
                videoPath: pickedFile!,
              ),
            ),
          );
        }
      }
    }
  }

  void getImage() async {
    //final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // imageFile == filteredImagePath!;
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
        title: const Text("Share Action",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          // InkWell(
          //   onTap: () async {
          //     final RxString imagePathRx = widget.imagePath!.obs;
          //     print(widget.imagePath!);
          //     await cameraModelController.addPostDetailsImage(
          //         imagePathRx, _selectedMusic!["musicId"]);
          //     // player.pause();
          //     await cameraModelController.createPost(widget.imagePath!);
          //     // if (widget.imagePath != null && widget.imagePath != '') {
          //     //   cameraModelController.createPost(widget.imagePath!);
          //     //   print(imageFile!.path.toString());
          //     // } else {
          //     //   cameraModelController.createPost(widget.imagePath!);
          //     // }
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 15),
          //     child: Container(
          //       decoration: const BoxDecoration(
          //           color: AppColor.purpleColor,
          //           borderRadius: BorderRadius.all(Radius.circular(25))),
          //       child: const Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          //         child: Text('Post',
          //             style: TextStyle(
          //                 color: AppColor.whiteColor,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w500)),
          //       ),
          //     ),
          //   ),
          // ),
          Obx(() {
            return InkWell(
                onTap: () async {
                  final RxString imagePathRx = widget.imagePath!.obs;
                  if (cameraModelController.loading.value)
                    return; // Prevent multiple taps while loading

                  await cameraModelController.addPostDetailsImage(imagePathRx,
                      _selectedMusic != null ? _selectedMusic!["musicId"] : '');
                  await cameraModelController.createPost(widget.imagePath!);
                },
                child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Stack(alignment: Alignment.center, children: [
                      // The Post button with conditional visibility of text
                      Visibility(
                        visible: !cameraModelController.loading.value,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: AppColor.purpleColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 8),
                            child: Text('Post',
                                style: TextStyle(
                                    color: AppColor.whiteColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                      // The loader
                      if (cameraModelController.loading.value)
                        const CircularProgressIndicator(
                          color: AppColor.purpleColor,
                        )
                    ])));
          }),
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
          buildPictureControls(widget.imagePath!),
          Positioned(
              bottom: 40,
              child: Column(
                children: [
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(RouteName.camera);
                        },
                        icon: Image.asset("assets/images/camIcon.png"),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Action",
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
          if (_isTextVisible)
            DraggableText(
              text: _controllerText.text,
              initialPosition: _textPosition,
              onPositionChanged: (newPosition) {
                setState(() {
                  _textPosition = newPosition;
                });
              },
              onRemove: _removeText,
            ),
          ..._stickers.map((sticker) {
            return Positioned(
              left: sticker.position.dx,
              top: sticker.position.dy,
              child: DraggableSticker(
                sticker: sticker,
                onStickerDragged: (newPosition) {
                  setState(() {
                    sticker.position = newPosition;
                  });
                },
                onStickerDeleted: () {
                  removeSticker(sticker);
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildPictureControls(String? imagePath) {
    return Positioned(
      top: 80,
      right: 15,
      child: Column(
        children: [
          IconButton(
            onPressed: () async {
              getImage();
              // await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ImageFilterMain(imagePath!)));
            },
            icon: Image.asset("assets/images/filter1.png"),
          ),
          IconButton(
            onPressed: () {},
            icon: const Text("1x",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          IconButton(
            onPressed: () {},
            icon: Image.asset("assets/images/filter2.png"),
          ),
          IconButton(
            onPressed: () async {
              showMusicImageBottomSheet();
            },
            //=> Get.toNamed(RouteName.musicScreen),
            icon: Image.asset("assets/images/filter3.png"),
          ),
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
                                        borderRadius: BorderRadius.circular(20),
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
            //onPressed: () => _showStickerBottomSheet(),
            onPressed: () {
              Get.to(() => ImageOverlayPage(
                  imagePath: widget.imagePath!, type: 'action'));
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
      ),
    );
  }
}

// class DisplayVideoScreen extends StatefulWidget {
//   final XFile videoPath;

//   DisplayVideoScreen({required this.videoPath});

//   @override
//   _DisplayVideoScreenState createState() => _DisplayVideoScreenState();
// }

// class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
//   final cameraModelController = Get.put(CameraViewModel());
//   double playbackSpeed = 1.0;
//   VideoPlayerController? _controller;
//   Future<void>? _initializeVideoPlayerFuture;
//   final List<String> stickerUrls = [
//     'assets/images/brainstorm.png',
//     'assets/images/catlover.png',
//     'assets/images/creativity.png',
//     'assets/images/dog.png',
//     'assets/images/rocket.png',
//     'assets/images/cupcake.png',
//     'assets/images/morning.png',
//     'assets/images/afternoon.png',
//     'assets/images/night.png',
//   ];
//   final List<Sticker> _stickers = [];
//   @override
//   void initState() {
//     _controller = VideoPlayerController.file(
//       File(widget.videoPath.path),
//     );
//     _initializeVideoPlayerFuture = _controller!.initialize();
//     _controller!.play();
//     _controller!.setLooping(true);
//     super.initState();
//     filteredImagePath == widget.videoPath.path;
//   }

//   @override
//   void dispose() {
//     _controller!.dispose();
//     super.dispose();
//   }

//   void removeSticker(Sticker sticker) {
//     setState(() {
//       _stickers.remove(sticker);
//     });
//   }

//   void _showStickerBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return GridView.count(
//           crossAxisCount: 3,
//           children: List.generate(stickerUrls.length, (index) {
//             return GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//                 setState(() {
//                   _stickers.add(
//                     Sticker(
//                       imageUrl: stickerUrls[index],
//                     ),
//                   );
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Image.asset(stickerUrls[index]),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }

//   Future<void> applySlowMotion() async {
//     try {
//       await _controller?.setPlaybackSpeed(playbackSpeed);
//     } catch (e) {
//       print('Error applying slow motion: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Share Action",
//             style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16)),
//         actions: [
//           InkWell(
//             onTap: () => cameraModelController.createPost(filteredImagePath!),
//             child: Padding(
//               padding: const EdgeInsets.only(right: 15),
//               child: Container(
//                 decoration: const BoxDecoration(
//                     color: AppColor.purpleColor,
//                     borderRadius: BorderRadius.all(Radius.circular(25))),
//                 child: const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
//                   child: Text('Post',
//                       style: TextStyle(
//                           color: AppColor.whiteColor,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500)),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             color: Colors.white,
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (_controller!.value.isPlaying) {
//                     _controller!.pause();
//                   } else {
//                     _controller!.play();
//                   }
//                 });
//               },
//               child: FutureBuilder(
//                 future: _initializeVideoPlayerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return AspectRatio(
//                       aspectRatio: _controller!.value.aspectRatio,
//                       child: VideoPlayer(_controller!),
//                     );
//                   } else {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//                 },
//               ),
//             ),
//           ),

//           Positioned(
//               top: 80,
//               right: 15,
//               child: Column(
//                 children: [
//                   Container(
//                       height: 50,
//                       width: 50,
//                       child: IconButton(
//                         onPressed: () {
//                           showModalBottomSheet(
//                             context: context,
//                             builder: (context) => BottomSheetContent(),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(25.0)),
//                             ),
//                             isScrollControlled: true,
//                           );
//                         },
//                         icon: Image.asset("assets/images/filter1.png"),
//                       )),
//                   Container(
//                     height: 50,
//                     width: 50,
//                     child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           // Toggle between different playback speeds
//                           if (playbackSpeed == 1.0) {
//                             playbackSpeed = 0.5;
//                           } else if (playbackSpeed == 0.5) {
//                             playbackSpeed = 0.25;
//                           } else if (playbackSpeed == 0.25) {
//                             playbackSpeed = 2.0; // New speed option: 2x
//                           } else {
//                             playbackSpeed = 1.0;
//                           }
//                           applySlowMotion();
//                         });
//                       },
//                       icon: Text(
//                         "${playbackSpeed}x",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                       height: 50,
//                       width: 50,
//                       child: IconButton(
//                         onPressed: () async {
//                           //await _trimVideo(context);
//                         },
//                         icon: Image.asset("assets/images/filter2.png"),
//                       )),
//                   Container(
//                       height: 50,
//                       width: 50,
//                       child: IconButton(
//                         onPressed: () {
//                           Get.toNamed(RouteName.musicScreen);
//                         },
//                         icon: Image.asset("assets/images/filter3.png"),
//                       )),
//                   IconButton(
//                     onPressed: () => _showStickerBottomSheet(),
//                     // onPressed: () {
//                     //   Utils.snackBar('Soon', 'Comming soon!');
//                     // },
//                     icon: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           "assets/images/star.png",
//                           height: 24,
//                           width: 24,
//                         ),
//                         const Text(
//                           'Stickers',
//                           style: TextStyle(color: AppColor.whiteColor),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               )),
//           //CamIcon
//           Positioned(
//               bottom: 40,
//               child: Column(
//                 children: [
//                   Container(
//                       height: 80,
//                       width: 80,
//                       child: IconButton(
//                         onPressed: () {
//                           Get.toNamed(RouteName.camera);
//                         },
//                         icon: Image.asset("assets/images/camIcon.png"),
//                       )),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   const Text(
//                     "Action",
//                     style: TextStyle(color: Colors.white),
//                   )
//                 ],
//               )),
//           Positioned(
//               left: 30,
//               bottom: 50 + 35,
//               child: Container(
//                   height: 45,
//                   width: 45,
//                   child: IconButton(
//                     onPressed: () {},
//                     icon: Image.asset("assets/images/galleryIcon.png"),
//                   ))),

//           ..._stickers.map((sticker) {
//             return DraggableSticker(
//               sticker: sticker,
//               onDelete: () {
//                 setState(() {
//                   _stickers.remove(sticker);
//                 });
//               },
//             );
//           }).toList()
//         ],
//       ),
//     );
//   }
// }
class DisplayVideoScreen extends StatefulWidget {
  final XFile videoPath;

  DisplayVideoScreen({required this.videoPath});

  @override
  _DisplayVideoScreenState createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
  final cameraModelController = Get.put(CameraViewModel());

  Offset _textPosition = const Offset(100, 100); // Set initial position here
  bool _isTextVisible = true; // Control visibility of draggable text
  TextEditingController _controllerText =
      TextEditingController(); // Ensure this is initialized

  double playbackSpeed = 1.0;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
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
  final List<Sticker> _stickers = [];
  String filteredVideoPath = '';
  final musicModelController = Get.put(MusicViewModel());
  TextEditingController _searchController = TextEditingController();

  final player = AudioPlayer();
  Map<String, dynamic>? _selectedMusic;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath.path));
    _initializeVideoPlayerFuture = _controller!.initialize();

    _controller!.setLooping(true);
    filteredVideoPath = widget.videoPath.path;
    musicModelController.getallMusic();
    _controller!.play();
  }

  void removeSticker(Sticker sticker) {
    setState(() {
      _stickers.remove(sticker);
    });
  }

  void _removeText() {
    setState(() {
      _isTextVisible = false;
      _controllerText.clear();
    });
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
      _controller!.play();
    });

    final result = await Get.bottomSheet(
      Container(
        padding:  const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
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
      shape: const RoundedRectangleBorder(
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

  Future<void> applySlowMotion() async {
    try {
      await _controller?.setPlaybackSpeed(playbackSpeed);
    } catch (e) {
      print('Error applying slow motion: $e');
    }
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

  @override
  void dispose() {
    _controller!.dispose();
    player.dispose();
    musicModelController.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Share Action",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          // InkWell(
          //   onTap: () async {
          //     cameraModelController.addPostDetails(widget.videoPath,
          //         _selectedMusic != null ? _selectedMusic!["musicId"] : '');
          //     player.pause();
          //     cameraModelController.createPost(filteredVideoPath);
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 15),
          //     child: Container(
          //       decoration: const BoxDecoration(
          //           color: AppColor.purpleColor,
          //           borderRadius: BorderRadius.all(Radius.circular(25))),
          //       child: const Padding(
          //         padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          //         child: Text('Post',
          //             style: TextStyle(
          //                 color: AppColor.whiteColor,
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w500)),
          //       ),
          //     ),
          //   ),
          // ),
          Obx(() {
            return InkWell(
              onTap: () async {
                if (cameraModelController.loading.value)
                  return; // Prevent multiple taps while loading

                cameraModelController.addPostDetails(widget.videoPath,
                    _selectedMusic != null ? _selectedMusic!["musicId"] : '');
                player.pause();
                cameraModelController.createPost(filteredVideoPath);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The Post button with conditional visibility of text
                    Visibility(
                      visible: !cameraModelController.loading.value,
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
                    // The loader
                    if (cameraModelController.loading.value)
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
              onTap: () async {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                    musicModelController.pause();
                  } else {
                    _controller!.play();
                    // musicModelController.playMusic(musicModelController
                    //     .playMusic(_selectedMusic!["music"]));
                    //player.play(_selectedMusic!["music"]);
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
                  Container(
                    height: 50,
                    width: 50,
                    child: IconButton(
                      onPressed: () {
                        _showFilterBottomSheet();
                      },
                      icon: Image.asset("assets/images/filter1.png"),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          // Toggle between different playback speeds
                          if (playbackSpeed == 1.0) {
                            playbackSpeed = 0.5;
                          } else if (playbackSpeed == 0.5) {
                            playbackSpeed = 0.25;
                          } else if (playbackSpeed == 0.25) {
                            playbackSpeed = 2.0; // New speed option: 2x
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
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () async {
                          await _showTrimDialog();
                        },
                        icon: Image.asset("assets/images/filter2.png"),
                      )),
                  Container(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          // Get.toNamed(RouteName.musicScreen);
                          showMusicBottomSheet();
                        },
                        icon: Image.asset("assets/images/filter3.png"),
                      )),
                  IconButton(
                    onPressed: () async {
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
                    //   Utils.snackBar('Soon', 'Comming soon!');
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

          //CamIcon
          Positioned(
              bottom: 40,
              child: Column(
                children: [
                  Container(
                      height: 80,
                      width: 80,
                      child: IconButton(
                        onPressed: () {
                          Get.toNamed(RouteName.camera);
                        },
                        icon: Image.asset("assets/images/camIcon.png"),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Action",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              )),
          Positioned(
              left: 30,
              bottom: 50 + 35,
              child: Container(
                  height: 45,
                  width: 45,
                  child: IconButton(
                    onPressed: () {},
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

          ..._stickers.map((sticker) => Positioned(
                top: sticker.position.dy,
                left: sticker.position.dx,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      sticker.position += details.delta;
                    });
                  },
                  onDoubleTap: () => removeSticker(sticker),
                  child: Image.asset(sticker.imageUrl, width: 80, height: 80),
                ),
              ))
        ],
      ),
    );
  }
}

class Sticker {
  final String imageUrl;
  Offset position;

  Sticker({required this.imageUrl, this.position = Offset.zero});
}

class DraggableSticker extends StatelessWidget {
  final Sticker sticker;
  final Function(Offset) onStickerDragged;
  final Function onStickerDeleted;

  const DraggableSticker({
    Key? key,
    required this.sticker,
    required this.onStickerDragged,
    required this.onStickerDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Sticker>(
      data: sticker,
      feedback: Image.asset(sticker.imageUrl),
      child: Image.asset(sticker.imageUrl),
      childWhenDragging: Container(),
      onDragEnd: (details) {
        if (details.wasAccepted) {
          onStickerDragged(details.offset);
        }
      },
      onDraggableCanceled: (velocity, offset) {
        onStickerDragged(offset);
      },
    );
  }
}
