import 'package:flutter/material.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPollCard extends StatelessWidget {
  final int itemCount;

  const ShimmerPollCard({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(5),
          child: Card(
            elevation: 7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.3),
                highlightColor: AppColor.greyColor.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipPath(
                                clipper: OctagonClipper(),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 12,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 50,
                                    height: 10,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 20,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 50,
                                height: 20,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 22,
                                height: 24,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: double.infinity,
                            height: 18,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(5, 15, 5, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: 20,
                                  height: 12,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: 20,
                                  height: 12,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: 20,
                                  height: 12,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
