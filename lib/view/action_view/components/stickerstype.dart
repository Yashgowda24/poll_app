import 'package:flutter/material.dart';

class Sticker {
  final String imageUrl;
  Offset position;

  Sticker({
    required this.imageUrl,
    this.position = const Offset(0, 0), // Default position
  });
}

// import 'package:flutter/material.dart';

// class Sticker {
//   final String imageUrl;
//   Offset position; // Position property for sticker

//   Sticker({required this.imageUrl, this.position = Offset.zero});
// }
