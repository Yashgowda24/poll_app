import 'package:flutter/material.dart';
import 'package:poll_chat/view/action_view/components/stickerstype.dart';

class DraggableSticker extends StatefulWidget {
  final Sticker sticker;
  final VoidCallback onDelete;

  const DraggableSticker(
      {Key? key, required this.sticker, required this.onDelete})
      : super(key: key);

  @override
  _DraggableStickerState createState() => _DraggableStickerState();
}

class _DraggableStickerState extends State<DraggableSticker> {
  Offset position = const Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        child: Draggable(
          feedback: Stack(
            children: [
              Image.asset(
                widget.sticker.imageUrl,
                width: 100,
                height: 100,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: widget.onDelete,
                ),
              ),
            ],
          ),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            setState(() {
              position = details.offset;
            });
          },
          child: Stack(
            children: [
              Image.asset(
                widget.sticker.imageUrl,
                width: 100,
                height: 100,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: widget.onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// class DraggableSticker extends StatefulWidget {
//   final Sticker sticker;
//   final VoidCallback onDelete;

//   const DraggableSticker({
//     Key? key,
//     required this.sticker,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   _DraggableStickerState createState() => _DraggableStickerState();
// }

// class _DraggableStickerState extends State<DraggableSticker> {
//   Offset position = const Offset(100, 100);

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: position.dx,
//       top: position.dy,
//       child: GestureDetector(
//         child: Draggable(
//           feedback: Stack(
//             children: [
//               Image.asset(
//                 widget.sticker.imageUrl,
//                 width: 100,
//                 height: 100,
//               ),
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: widget.onDelete,
//                 ),
//               ),
//             ],
//           ),
//           childWhenDragging: Container(),
//           onDragEnd: (details) {
//             setState(() {
//               position = details.offset;
//             });
//           },
//           child: Stack(
//             children: [
//               Image.asset(
//                 widget.sticker.imageUrl,
//                 width: 100,
//                 height: 100,
//               ),
//               Positioned(
//                 top: 0,
//                 right: 0,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.close,
//                     color: Colors.red,
//                   ),
//                   onPressed: widget.onDelete,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
