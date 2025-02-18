import 'package:flutter/material.dart';

class WatermarkText {
  final String text;
  final TextStyle textStyle;
  final WatermarkAlignmenta alignment;

  WatermarkText({
    required this.text,
    required this.textStyle,
    required this.alignment,
  });
}

enum WatermarkAlignmenta {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

extension WatermarkAlignmentExtension on WatermarkAlignmenta {
  Alignment get toAlignment {
    switch (this) {
      case WatermarkAlignmenta.topLeft:
        return Alignment.topLeft;
      case WatermarkAlignmenta.topRight:
        return Alignment.topRight;
      case WatermarkAlignmenta.bottomLeft:
        return Alignment.bottomLeft;
      case WatermarkAlignmenta.bottomRight:
        return Alignment.bottomRight;
      case WatermarkAlignmenta.center:
        return Alignment.center;
    }
  }
}
