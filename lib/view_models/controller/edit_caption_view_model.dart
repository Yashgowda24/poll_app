import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/repository/poll_repository.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class EditCaptionViewModel extends GetxController {
  final _api = PollRepository();
  final RxList<TextEditingController> textEditingControllers =
      <TextEditingController>[].obs;
  final Rx<TextEditingController> askQuestionController =
      TextEditingController().obs;
  final Rx<TextEditingController> hashtagController =
      TextEditingController().obs;
  late PollModel pollModel;
  String? id = "";

  // Add a new TextEditingController
  void addNewController() {
    TextEditingController textEditingController = TextEditingController();
    textEditingControllers.add(textEditingController);
  }

  // Remove a TextEditingController at a specific index
  void removeController({required int index}) {
    if (index >= 0 && index < textEditingControllers.length) {
      textEditingControllers[index].dispose(); // Dispose the controller
      textEditingControllers.removeAt(index);
    }
  }

  // Fetch user ID and poll data
  void userID() async {
    UserPreference userPreference = UserPreference();
    id = await userPreference.getUserID();
    if (id != null) {
      pollModel = await _api.getPollByUserId(id!);
      print("All Polls By UserID: ${pollModel}");
      // Update controllers with fetched data if needed
    } else {
      print("User ID is null");
    }
  }

  // Initialize and fetch data when the controller is created
  @override
  void onInit() {
    super.onInit();
    userID();
  }

  // Clean up controllers when the controller is disposed
  @override
  void onClose() {
    for (var controller in textEditingControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
