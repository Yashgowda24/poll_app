// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class ButtonWithIcon extends StatefulWidget {
//   final String label;
//   final String icon;
//   final String pollId;
//   final void Function(String id) callback;

//   const ButtonWithIcon(
//       {super.key,
//       required this.label,
//       required this.icon,
//       required this.pollId,
//       required this.callback});
//   @override
//   State<StatefulWidget> createState() => _ButtonWithIcon();
// }

// class _ButtonWithIcon extends State<ButtonWithIcon> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 8),
//       child: InkWell(
//         onTap: () {
//           widget.callback(widget.pollId);
//         },
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 16,
//               height: 16,
//               child: SvgPicture.asset(widget.icon),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 5),
//               child: Text(
//                 widget.label,
//                 style: const TextStyle(fontSize: 12),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonWithIcon extends StatefulWidget {
  final String label;
  final String icon;
  final String pollId;
  bool? isLiked;
  final void Function(String id) callback;

  ButtonWithIcon(
      {super.key,
      required this.label,
      required this.icon,
      required this.pollId,
      this.isLiked,
      required this.callback});

  @override
  State<StatefulWidget> createState() => _ButtonWithIconState();
}

class _ButtonWithIconState extends State<ButtonWithIcon> {
  bool _isLiked = false;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = int.parse(widget.label);
    // _isLiked = widget.isLiked!;
  }

  void handleLike() {
    setState(() {
      if (!_isLiked) {
        likeCount++;
      } else {
        likeCount--;
      }
      _isLiked = !_isLiked;
      widget.callback(widget.pollId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          handleLike();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                widget.icon,
                color: _isLiked
                    ? Colors.purple
                    : Colors.grey, // Change icon color based on like state
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                '$likeCount', // Update the like count text
                style: TextStyle(
                  fontSize: 12,
                  color: _isLiked
                      ? Colors.purple
                      : Colors.black, // Optionally change text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
