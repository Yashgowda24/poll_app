import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomCameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;

  CustomCameraScreen({required this.onImageCaptured});

  @override
  _CustomCameraScreenState createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? controller;
  List<CameraDescription>? _cameras;
  bool flashToggle = false;
  bool toggle = false;
  Color flashIconColor = Colors.white; // Add this line

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras![0], ResolutionPreset.max);
    await controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
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
          "Take Picture",
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
              child: CameraPreview(controller!),
            ),
            Positioned(
              bottom: 40,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      onPressed: () {
                        controller!.setFlashMode(
                            flashToggle ? FlashMode.off : FlashMode.torch);
                        setState(() {
                          flashToggle = !flashToggle;
                          flashIconColor = flashToggle
                              ? Colors.purple
                              : Colors.white; // Update this line
                        });
                      },
                      icon: Image.asset(
                        "assets/images/flashIcon.png",
                        color: flashIconColor, // Update this line
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final image = await controller!.takePicture();
                        widget.onImageCaptured(image.path);
                        controller!.setFlashMode(FlashMode.off);
                        Navigator.pop(context);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Image.asset("assets/images/chatcamera.png",
                        height: 70, width: 70),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap for Image",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 30,
              bottom: 85,
              child: SizedBox(
                height: 45,
                width: 45,
                child: IconButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      widget.onImageCaptured(pickedFile.path);
                      Navigator.pop(context);
                    }
                  },
                  icon: Image.asset("assets/images/galleryIcon2.png"),
                ),
              ),
            ),
            Positioned(
              right: 25,
              bottom: 75,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
