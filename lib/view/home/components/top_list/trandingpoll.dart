import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/simmer/simmerpollcard.dart';
import 'package:poll_chat/view/home/components/poll_card/poll_card.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';

class TrandingPollScreen extends StatefulWidget {
  const TrandingPollScreen({super.key});

  @override
  State<TrandingPollScreen> createState() => _TrandingPollScreenState();
}

class _TrandingPollScreenState extends State<TrandingPollScreen> {
  final homeModelController = Get.put(HomeViewModelController());
  @override
  void initState() {
    homeModelController.tranding;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trending Polls",
          style: TextStyle(
              fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: homeModelController.tranding.isEmpty
          ? SizedBox(
              height: Get.height,
              width: Get.width,
              child: const Center(
                child: ShimmerPollCard(
                  itemCount: 3,
                ),
              ),
            )
          : ListView(
              children: [
                if (homeModelController.tranding.isNotEmpty)
                  ...homeModelController.tranding.map((poll) {
                    return PollCard(
                      isProfile: true,
                      isPinnedPolls: true,
                      pollModel: poll,
                      user: homeModelController.singleUser,
                    );
                  }),
              ],
            ),
    );
  }
}
