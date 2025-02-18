import 'package:poll_chat/data/network/network_api_services.dart';
import 'package:poll_chat/models/poll_model/poll_model.dart';
import 'package:poll_chat/res/app_url/app_url.dart';

class PollRepository {
  final _apiService = NetworkApiServices();
  Future<dynamic> createPollApi(var data) async {
    dynamic response = _apiService.postPollApi(data, AppUrl.createPoll);
    return response;
  }

  Future<dynamic> editPollApi(Map<String, String> data,String imagePath,String id) async {
    dynamic response = _apiService.editsPostPollApi(data, AppUrl.updatePoll+id,imagePath);
    return response;
  }

  Future<List> getUserAllPollApi() async {
    final response = await _apiService.getApi(AppUrl.allPollByUser);
    final List body = response;
    return body;
  }

  Future<PollModel> getPollByUserId(String id) async {
    final response = await _apiService.getApi(AppUrl.getPollByUserId(id: id));
    return response;
  }

  Future<dynamic> deletePollById(String pollId) async {
    dynamic response =
        _apiService.deleteApi(AppUrl.deletePollById(pollId: pollId));
    return response;
  }
}
