import 'package:flutter/material.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class DraggableText extends StatelessWidget {
  final String text;
  final Offset initialPosition;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback onRemove;

  const DraggableText({
    Key? key,
    required this.text,
    required this.initialPosition,
    required this.onPositionChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: initialPosition.dx,
      top: initialPosition.dy,
      child: Stack(
        children: [
          // Draggable text
          Draggable<Offset>(
            data: initialPosition,
            feedback: Material(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColor.whiteColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColor.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              onPositionChanged(details.offset);
              
            },
          ),
          // Remove icon
          Positioned(
            left: 12,
            top: -20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}
