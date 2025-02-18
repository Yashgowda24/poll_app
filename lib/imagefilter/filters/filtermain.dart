import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image/image.dart' as imagelib;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:poll_chat/imagefilter/filters/filters.dart';
import 'package:poll_chat/imagefilter/filters/preset_filters.dart';
import 'package:poll_chat/imagefilter/widgets/photo_filter.dart';

class ImageFilterMain extends StatefulWidget {
  var imagePath;
  ImageFilterMain(this.imagePath, {super.key});

  @override
  ImageFilterMainState createState() => ImageFilterMainState();
}

class ImageFilterMainState extends State<ImageFilterMain> {
  String fileName = "";
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? imageFile;

  Future getImage(context) async {
    //final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (widget.imagePath != null) {
      imageFile = File(widget.imagePath!);
      fileName = basename(widget.imagePath!);
      var image = imagelib.decodeImage(await imageFile!.readAsBytes());
      image = imagelib.copyResize(image!, width: 600);
      Map imagefile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoFilterSelector(
            title: const Text("Photo Filter"),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Filter'),
      ),
      body: Center(
        child: Container(
          child: imageFile == null
              ? const Center(
                  child: Text('No image selected.'),
                )
              : Image.file(File(imageFile!.path)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getImage(context),
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
