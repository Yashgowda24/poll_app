import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view/action_view/components/createPost.dart';
import 'package:poll_chat/view/action_view/storycreate/createstory.dart';

class ImageOverlayPage extends StatefulWidget {
  final String imagePath;
  final String type;
  const ImageOverlayPage(
      {required this.imagePath, required this.type, Key? key})
      : super(key: key);

  @override
  _ImageOverlayPageState createState() => _ImageOverlayPageState();
}

class _ImageOverlayPageState extends State<ImageOverlayPage> {
  ui.Image? _backgroundImage;
  ui.Image? _overlayImage;
  Offset _overlayPosition = const Offset(50, 50);
  Offset _textPosition = const Offset(100, 100);
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey(); // Add a key for the Stack

  String _text = "";
  bool _isTextVisible = false;
  Color _textColor = Colors.black; // Add a variable for text color

  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;

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
    _loadImage(File(widget.imagePath), isBackground: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stickers'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              color: AppColor.purpleColor,
            ),
            onPressed: () async {
              _saveImage();
            },
          ),
          if (_overlayImage != null || _isTextVisible)
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: _removeOverlay,
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _backgroundImage == null
                ? const CircularProgressIndicator()
                : Flexible(
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Stack(
                        key: _stackKey, // Assign the key to the Stack
                        children: [
                          CustomPaint(
                            painter: ImagePainter(_backgroundImage!),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width,
                                maxHeight: MediaQuery.of(context).size.height *
                                    0.7, // adjust as needed
                              ),
                            ),
                          ),
                          if (_overlayImage != null)
                            Positioned(
                              left: _overlayPosition.dx,
                              top: _overlayPosition.dy,
                              child: Draggable(
                                feedback: CustomPaint(
                                  painter: OverlayImagePainter(_overlayImage!),
                                  child: const SizedBox(
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                childWhenDragging: Container(),
                                onDragEnd: (details) {
                                  setState(() {
                                    _overlayPosition =
                                        _getLocalPosition(details.offset);
                                  });
                                },
                                child: CustomPaint(
                                  painter: OverlayImagePainter(_overlayImage!),
                                  child: const SizedBox(
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                            ),
                          if (_isTextVisible)
                            Positioned(
                              left: _textPosition.dx,
                              top: _textPosition.dy,
                              child: Draggable(
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    _text,
                                    style: _getTextStyle(),
                                  ),
                                ),
                                childWhenDragging: Container(),
                                onDragEnd: (details) {
                                  setState(() {
                                    _textPosition =
                                        _getLocalPosition(details.offset);
                                  });
                                },
                                child: Text(
                                  _text,
                                  style: _getTextStyle(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showStickerBottomSheet,
              child: const Text('Select Sticker'),
            ),
            const SizedBox(height: 20),
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 16),
            //   child: TextField(
            //     decoration: const InputDecoration(
            //       hintText: 'Enter text',
            //       border: OutlineInputBorder(),
            //     ),
            //     onChanged: (value) {
            //       setState(() {
            //         _text = value;
            //         _isTextVisible = true;
            //       });
            //     },
            //   ),
            // ),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _selectTextColor,
            //   child: const Text('Select Text Color'),
            // ),
            // const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     _buildTextStyleButton('B', _isBold, () {
            //       setState(() {
            //         _isBold = !_isBold;
            //       });
            //     }),
            //     _buildTextStyleButton('I', _isItalic, () {
            //       setState(() {
            //         _isItalic = !_isItalic;
            //       });
            //     }),
            //     _buildTextStyleButton('U', _isUnderline, () {
            //       setState(() {
            //         _isUnderline = !_isUnderline;
            //       });
            //     }),
            //     _buildTextStyleButton('S', _isStrikethrough, () {
            //       setState(() {
            //         _isStrikethrough = !_isStrikethrough;
            //       });
            //     }),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStyleButton(
      String label, bool isActive, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : Colors.grey,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: 24,
      color: _textColor,
      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: TextDecoration.combine([
        if (_isUnderline) TextDecoration.underline,
        if (_isStrikethrough) TextDecoration.lineThrough,
      ]),
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
              onTap: () async {
                Navigator.pop(context);
                await _loadOverlayImageFromAsset(stickerUrls[index]);
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

  Future<void> _loadOverlayImageFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      _overlayImage = frameInfo.image;
    });
  }

  void _loadImage(File? imageFile, {required bool isBackground}) async {
    final Uint8List bytes = await imageFile!.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    setState(() {
      if (isBackground) {
        _backgroundImage = frameInfo.image;
      } else {
        _overlayImage = frameInfo.image;
      }
    });
  }

  void _removeOverlay() {
    setState(() {
      _overlayImage = null;
      _isTextVisible = false;
      _text = "";
    });
  }

  Future<void> _saveImage() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final directory = (await getApplicationDocumentsDirectory()).path;
      final String filePath = '$directory/final_image.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      if (widget.type == 'action') {
        Get.to(() => DisplayPictureScreen(imagePath: file.path));
      } else {
        Get.to(() => DisplayImageStory(imagePath: file.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  // Add a method to select text color
  void _selectTextColor() async {
    final Color? selectedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Text Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _textColor,
              onColorChanged: (color) {
                setState(() {
                  _textColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_textColor);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (selectedColor != null) {
      setState(() {
        _textColor = selectedColor;
      });
    }
  }

  Offset _getLocalPosition(Offset globalPosition) {
    final RenderBox stackRenderBox =
        _stackKey.currentContext!.findRenderObject() as RenderBox;
    return stackRenderBox.globalToLocal(globalPosition);
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final imageRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint();
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        imageRect,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OverlayImagePainter extends CustomPainter {
  final ui.Image image;

  OverlayImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final imageRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint();
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        imageRect,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
