import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/simmer/simmerpollcard.dart';
import 'package:poll_chat/view/home/components/poll_card/poll_card.dart';
import '../../../../view_models/controller/home_model.dart';
import '../../../../view_models/controller/user_preference_view_model.dart';

class SinglePollCard extends StatefulWidget {
  String? url;
  SinglePollCard({super.key, required this.url});

  @override
  State<SinglePollCard> createState() => _SinglePollCardState();
}

class _SinglePollCardState extends State<SinglePollCard> {
  final homeModelController = Get.put(HomeViewModelController());
  final pollmodel = Get.put(PollModel());
  UserPreference userPreference = UserPreference();
  bool isLoading = true;
  late String pollId;

  @override
  void initState() {
    getSinglePoll();
    pollId = _extractIdFromUrl(widget.url.toString());
    print(pollId);
    super.initState();
  }

  String _extractIdFromUrl(String url) {
    Uri uri = Uri.parse(url);
    List<String> segments = uri.pathSegments;
    String idWithPlus = segments.last;
    return idWithPlus.replaceAll('+', '').trim();
  }

  Future<void> getSinglePoll() async {
    String? id = await userPreference.getUserID();
    log("ID here: $id");
    await homeModelController.getSingleUser(id!);
    await homeModelController.singlePolls(pollId);
    homeModelController.singlePollCard;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll'),
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [],
          body: Obx(
            () {
              if (homeModelController.loading.isTrue) {
                return const Center(
                  child: ShimmerPollCard(
                    itemCount: 3,
                  ),
                );
              }
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (homeModelController.singlePollCard.isNotEmpty)
                    ...homeModelController.singlePollCard.map((poll) {
                      if (poll == 'advertisement') {
                        return const SizedBox.shrink();
                      }
                      return PollCard(
                        isProfile: true,
                        isPinnedPolls: false,
                        pollModel: poll,
                        user: homeModelController.singleUser,
                      );
                    }),
                  const Divider(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
