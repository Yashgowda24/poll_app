// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// class CustomCameraScreen extends StatefulWidget {
//   @override
//   _CustomCameraScreenState createState() => _CustomCameraScreenState();
// }

// class _CustomCameraScreenState extends State<CustomCameraScreen> {



//   var toggle = true;
//   var flash_toggle = true;
//   var onPress = false;

//   getCamera() async {
//     setState(() {
//       availableCameras().then((value) {
       
//           setState(() {});
//         }).catchError((Object e) {
//           if (e is CameraException) {
//             switch (e.code) {
//               case 'CameraAccessDenied':
//                 break;
//               default:
//                 break;
//             }
//           }
//         });
//       });
    
//   }

//   @override
//   void initState() {
//     getCamera();
//     super.initState();
//   }

//   @override
//   void dispose() {
   
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {

//     var w = MediaQuery.of(context).size.width;
//     var h = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           "Picture",
//           style: TextStyle(
//               color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//       ),
//       body: SizedBox(
//         height: h,
//         width: w,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Positioned(
//                 bottom: 0,
//                 top: 0,
//                 right: 0,
//                 left: 0,
//                 child: CameraPreview(controller!)),
//             Positioned(
//                 bottom: 40,
//                 child: Column(
//                   children: [
//                     SizedBox(
//                         height: 40,
//                         width: 40,
//                         child: IconButton(
//                           onPressed: () {
//                             // setState(() {
//                             controller!.setFlashMode(
//                                 flash_toggle ? FlashMode.off : FlashMode.torch);
//                             setState(() {
//                               flash_toggle = !flash_toggle;
//                             });
//                             // });
//                           },
//                           icon: Image.asset("assets/images/flashIcon.png"),
//                         )),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Container(
//                       height: 80,
//                       width: 80,
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.white70,
//                           width: 3,
//                         ),
//                       ),
//                       child: GestureDetector(
                      

                          
                         
//                         onTap: () async {
//                           try {
//                             final image = await controller!.takePicture();
                        
                         


//                             await Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => DisplayGroupChatImage(
//                                   imagePath: image.path,
//                                 ),
//                               ),
//                             );
//                           } catch (e) {
//                             print(e);
//                           }
//                         },
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Image.asset(
//                               "assets/images/chatcamera.png",
//                               height: 70,
//                               width: 70,
//                             ),
//                             if (onPress)
//                               const Positioned.fill(
//                                 child: CircularProgressIndicator(
//                                   valueColor:
//                                       AlwaysStoppedAnimation<Color>(Colors.red),
//                                   strokeWidth: 4.0,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     const Text(
//                       "Hold for video, tap for photo",
//                       style: TextStyle(color: Colors.white),
//                     )
//                   ],
//                 )),
//             Positioned(
//                 left: 30,
//                 bottom: 50 + 35,
//                 child: SizedBox(
//                     height: 45,
//                     width: 45,
//                     child: IconButton(
//                       onPressed: () {
//                         checkPermissions();
//                       },
//                       icon: Image.asset("assets/images/galleryIcon2.png"),
//                     ))),
//             Positioned(
//                 right: 25,
//                 bottom: 50 + 25,
//                 child: SizedBox(
//                     height: 60,
//                     width: 60,
//                     child: IconButton(
//                       onPressed: () {
//                         controller = CameraController(
//                             _cameras![toggle ? 1 : 0], ResolutionPreset.max);
//                         setState(() {
//                           toggle = !toggle;
//                         });

//                         controller!.initialize().then((_) {
//                           if (!mounted) {
//                             return;
//                           }
//                           setState(() {});
//                         }).catchError((Object e) {
//                           if (e is CameraException) {
//                             switch (e.code) {
//                               case 'CameraAccessDenied':
//                                 break;
//                               default:
//                                 break;
//                             }
//                           }
//                         });
//                       },
//                       icon: Image.asset("assets/images/flipCam.png"),
//                     )))
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> checkPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.camera,
//       Permission.storage,
//     ].request();

//     if (statuses[Permission.camera] != PermissionStatus.granted &&
//         statuses[Permission.storage] != PermissionStatus.granted) {
//       print("Camera or storage permission not granted.");
//     } else {
//       print("Permissions checked and granted.");
//     }
//     _pickProfile();
//   }

//   Future<void> _pickProfile() async {
//     final picker = ImagePicker();
//     XFile? pickedFile;
//     bool? isImage = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select media type'),
//           content: const Text('Do you want to pick an image or a video?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // Pick image
//               },
//               child: const Text('Image'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false); // Pick video
//               },
//               child: const Text('Video'),
//             ),
//           ],
//         );
//       },
//     );

//     if (isImage != null) {
//       if (isImage) {
//         pickedFile = await picker.pickImage(source: ImageSource.gallery);
//       } else {
//         pickedFile = await picker.pickVideo(source: ImageSource.gallery);
//       }

//       if (pickedFile != null) {
//         setState(() {
//           cameraModelController.addPostStoryDetails(
//             pickedFile!,
//           );
//         });

//         player.pause();
//         if (isImage) {
//           player.pause();
//           await Navigator.of(context).push(MaterialPageRoute(
//             builder: (context) => DisplayGroupChatImage(
//               imagePath: pickedFile!.path,
//             ),
//           ));
//         } else {
//           await Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => DisplayGroupChatVideoScreen(
//                 videoPath: pickedFile!,
//               ),
//             ),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _play(var audioUrl) async {
//     await player.play(UrlSource(audioUrl));
//   }

//   Future<void> _pause() async {
//     await player.pause();
//   }

//   Future<void> _startRecording() async {
//     // Start video recording
//     // final path = (await getTemporaryDirectory()).path+'${DateTime.now()}.mp4';
//     await controller!.startVideoRecording();
//     if (!context.mounted) return;
//   }
// }

