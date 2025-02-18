import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:poll_chat/res/colors/app_color.dart';

class ShimmerListView extends StatelessWidget {
  final int itemCount;

  const ShimmerListView({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColor.lightpp, // Base color for shimmer effect
      highlightColor: AppColor.purpleColor
          .withOpacity(0.2), // Highlight color for shimmer effect
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    backgroundColor: AppColor.lightpp,
                    child: Icon(Icons.person, color: AppColor.purpleColor),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        color: AppColor.lightpp,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        color: AppColor.lightpp,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
