import 'package:get/get.dart';
import 'package:poll_chat/data/repository/poll_repository.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/utils/utils.dart';

class MyProfileViewModel extends GetxController {
  final _api = PollRepository();
  List<dynamic> userPollList = <PollModel>[];

  void getUserAllPollApi() async {
    userPollList = await _api.getUserAllPollApi();
  }

  void deletePollById(String pollId) async {
    try {
      await _api.deletePollById(pollId);
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }
}