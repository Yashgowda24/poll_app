import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/repository/poll_repository.dart';
import 'package:poll_chat/utils/utils.dart';

class CreatePollViewModel extends GetxController {
  final _api = PollRepository();
  final RxList<TextEditingController> textEditingControllers =
      <TextEditingController>[].obs;
  final Rx<TextEditingController> askQuestionController =
      TextEditingController().obs;
        final Rx<TextEditingController> tagController =
      TextEditingController().obs;
  Rx<String> img = ''.obs;
  Rx<String> pollType = 'everyone'.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
 var focusNodes = <FocusNode>[].obs;
  void addPollType(String val) {
    if (val != null) {
      String _pollType = val.toLowerCase();
      pollType.value = _pollType;
    }
  }

  void addImage(String val) {
    String _img = val;
    img.value = _img;
  }

  void clearImage() {
    img.value = '';
  }

  void addNewController() {
    TextEditingController textEditingController = TextEditingController();
    textEditingControllers.add(textEditingController);
      focusNodes.add(FocusNode());
       update(); 
  }

  void removeController({required int index}) {
    textEditingControllers.removeAt(index);
  }

  void clearTextEditingControllers() {
    for (var controller in textEditingControllers) {
      controller.clear();
    }
    askQuestionController.value.clear();
    tagController.value.clear();
  }

  List<Map<String, dynamic>> getOptions() {
    final List<Map<String, dynamic>> options = [];
    for (var controller in textEditingControllers) {
      final Map<String, dynamic> option = {};
      option["title"] = controller.value.text;
      option["count"] = 0;
      options.add(option);
    }
    return options;
  }

  void createPollApi() {
    print(img.obs);

    Map<String, dynamic> data = {
      "pollType": pollType.value,
      "question": askQuestionController.value.text,
      "hashtags": tagController.value.text,
      "endDate": selectedDate.value.toIso8601String(),
    };

    List<Map<String, dynamic>> options = getOptions();
    for (int i = 0; i < options.length; i++) {
      data['option${String.fromCharCode(65 + i)}'] = options[i]["title"];
    }

    if (img.value != null && img.value.isNotEmpty) {
      data["pollPhoto"] = img.value;
    }

    if (kDebugMode) {
      print(data);
    }

    _api.createPollApi(data).then((value) {
      print("$value");
      if (value["success"]) {
        Utils.snackBar("Success", "Poll Created Successfully");
      }
    }).onError((error, stackTrace) {
      Utils.snackBar("Error", error.toString());
    });
  }

  void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate.value) {
      selectedDate.value = pickedDate;
    }
  }

  @override
  void onInit() {
    super.onInit();
    //addNewController();
    addNewController();
  }
}
