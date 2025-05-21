import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/simmer/simmerpollcard.dart';
import 'package:poll_chat/view/home/components/poll_card/poll_card.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class PollSaveCard extends StatefulWidget {
  const PollSaveCard({super.key});

  @override
  State<StatefulWidget> createState() => _PollSaveCardState();
}

class _PollSaveCardState extends State<PollSaveCard> {
  final pollviewModel = Get.put(PollModel());
  final homeViewModelController = Get.put(HomeViewModelController());
  var click = false;
  UserPreference userPreference = UserPreference();
  @override
  void initState() {
    getPolls();
    super.initState();
  }

  bool isLoading = true;
  Future<void> getPolls() async {
    String? id = await userPreference.getUserID();
    log("ID here: $id");
    await homeViewModelController.getSavedPolls();
    homeViewModelController.savedPollCard;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          if (homeViewModelController.loading.isTrue) {
            return const Center(
              child: ShimmerPollCard(
                itemCount: 3,
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (homeViewModelController.savedPollCard.isNotEmpty)
                ...homeViewModelController.savedPollCard.map((poll) {
                  return PollCard(
                    isProfile: true,
                    isPinnedPolls: false,
                    pollModel: poll,
                    user: homeViewModelController.singleUser,
                  );
                }),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
