import 'package:get/get.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PollModel());
    Get.put(HomeViewModelController());
  }
}
