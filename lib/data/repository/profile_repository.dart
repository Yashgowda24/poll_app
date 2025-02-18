import 'package:poll_chat/data/network/network_api_services.dart';
import 'package:poll_chat/res/app_url/app_url.dart';

class ProfileRepository {
  final _apiService = NetworkApiServices();
  Future<dynamic> updateProfileApi(var data) async {
    dynamic response =
        _apiService.putEditProfileApi(data, AppUrl.updateProfile);
    return response;
  }

  Future<dynamic> updateProfilePhoto(var data) async {
    dynamic response = _apiService.putEditProfileApi(
      data,
      AppUrl.editProfilePhoto,
    );
    return response;
  }

  Future<dynamic> postCreatePost(var data) async {
    dynamic response = _apiService.postCreatePostApi1(data, AppUrl.createPost);
    return response;
  }

  Future<dynamic> postStoryPost(var data) async {
    dynamic response = _apiService.postStory(data, AppUrl.createStoryPost);
    return response;
  }

  Future<dynamic> postSendVote(Map<String, bool> data, var pollId) async {
    dynamic response =
        _apiService.postSendVoteApi(data, AppUrl.pollSendVote(id: pollId));
    return response;
  }

  Future<dynamic> postLikeDislike(var data, var pollId) async {
    dynamic response =
        _apiService.postLikeDislikeApi(data, "${AppUrl.likeDislike}$pollId");
    return response;
  }

  Future<dynamic> postSavePoll(var data, var pollId) async {
    dynamic response =
        _apiService.postLikeDislikeApi(data, "${AppUrl.savepoll}$pollId");
    return response;
  }

  Future<dynamic> postComment(var data, var pollId) async {
    dynamic response =
        _apiService.postCommentApi(data, "${AppUrl.comment}$pollId");
    return response;
  }

  Future<dynamic> resetVote(var pollId) async {
    dynamic response = _apiService.resetVoteApi("${AppUrl.resetPoll}$pollId");
    return response;
  }

  Future<dynamic> pollVisibility(var pollId, var data) async {
    dynamic response =
        _apiService.putVisibilityApi(data, "${AppUrl.updatePoll}$pollId");
    return response;
  }

  // Future<dynamic> getUserProfileApi() async {
  //   dynamic response = _apiService.getApi(AppUrl.userProfile);
  //   return response;
  // }

  Future<dynamic> getUserApi(String? id) async {
    dynamic response = _apiService.getApi(AppUrl.getUser(id: id!));
    return response;
  }

  Future<dynamic> getallUsersApi() async {
    dynamic response = _apiService.getApi(AppUrl.getallusers);
    return response;
  }

  Future<dynamic> getallMusicApi() async {
    dynamic response = _apiService.getMusicApi(AppUrl.allMusic);
    return response;
  }

  Future<dynamic> getAllPollsApi(String? id) async {
    dynamic response = _apiService.getPollApi(AppUrl.allPolls + id!);
    return response;
  }
   Future<dynamic> getAllUserPollsApi(String? id) async {
    dynamic response = _apiService.getAllUserApi(AppUrl.allPolls + id!);
    return response;
  }

  Future<dynamic> getAllPollsFor() async {
    dynamic response = _apiService.getAllPollsNew(AppUrl.everyonepolls);
    return response;
  }

  Future<dynamic> getSavedPolls() async {
    dynamic response = _apiService.getsavedPolls(AppUrl.savedpolls);
    return response;
  }

  Future<dynamic> getAllCommentApi(String id) async {
    dynamic response = _apiService.getCommentPollApi(AppUrl.comment + id);
    return response;
  }

  Future<dynamic> getActionCommentApi(String id) async {
    dynamic response = _apiService.getCommentPollApi(AppUrl.actioncomment + id);
    return response;
  }
}
