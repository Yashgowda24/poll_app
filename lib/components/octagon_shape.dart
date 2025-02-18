import 'dart:math';
import 'package:flutter/material.dart';

class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double shortSide =
        size.width < size.height ? size.width : size.height;
    final double radius = shortSide / 2.0;
    final double sideLength = radius / sqrt(2);

    final double centerX = size.width / 2.0;
    final double centerY = size.height / 2.0;

    Path path = Path();
    path.moveTo(centerX + sideLength / 2.0, centerY - radius);
    path.lineTo(centerX + radius, centerY - sideLength / 2.0);
    path.lineTo(centerX + radius, centerY + sideLength / 2.0);
    path.lineTo(centerX + sideLength / 2.0, centerY + radius);
    path.lineTo(centerX - sideLength / 2.0, centerY + radius);
    path.lineTo(centerX - radius, centerY + sideLength / 2.0);
    path.lineTo(centerX - radius, centerY - sideLength / 2.0);
    path.lineTo(centerX - sideLength / 2.0, centerY - radius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
