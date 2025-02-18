import 'package:flutter/cupertino.dart';

import '../../../res/assets/icon_assets.dart';
import '../../../res/colors/app_color.dart';

class FriendRequestItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function(String id) onOk;
  final void Function(String id) onCancel;

  const FriendRequestItem(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.onOk,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Image.asset(IconAssets.imagePlaceholderIcon),
          ),
          const SizedBox(
            width: 10,
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "asdfasd",
                style: TextStyle(
                    color: AppColor.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              Text("American Actor",
                  style: TextStyle(
                      color: AppColor.greyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.normal)),
            ],
          )
        ],
      ),
    );
  }
}
