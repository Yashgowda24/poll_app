import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/simmer/simmerpollcard.dart';
import 'package:poll_chat/view/home/components/poll_card/poll_card.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';

class PinnedPollScreen extends StatefulWidget {
  const PinnedPollScreen({super.key});

  @override
  State<PinnedPollScreen> createState() => _PinnedPollScreenState();
}

class _PinnedPollScreenState extends State<PinnedPollScreen> {
  final homeModelController = Get.put(HomeViewModelController());

  @override
  void initState() {
    homeModelController.allPinnedPolls;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pinned Polls",
          style: TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: Obx(() {
        if (homeModelController.allPinnedPolls.isEmpty) {
          return SizedBox(
            height: Get.height,
            width: Get.width,
            child: const Center(
              child: ShimmerPollCard(
                itemCount: 3,
              ),
            ),
          );
        } else {
          return ListView(
            children: [
              if (homeModelController.allPinnedPolls.isNotEmpty)
                ...homeModelController.allPinnedPolls.map((poll) {
                  return PollCard(
                    isProfile: true,
                    isPinnedPolls: false,
                    pollModel: poll,
                    user: homeModelController.singleUser,
                  );
                }),
            ],
          );
        }
      }),
    );
  }
}
