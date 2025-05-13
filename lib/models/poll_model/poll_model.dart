import 'dart:convert';
import 'dart:developer';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import '../../data/repository/profile_repository.dart';
import '../../utils/utils.dart';
import 'package:http/http.dart' as http;

class PollModel extends GetxController {
  final _api = ProfileRepository();
  Rx<String> pollType = 'Everyone'.obs;
  RxBool loading = false.obs;
  var someObservableValue = Rx<String>("");

  final RxList<dynamic> allComments = <dynamic>[].obs;
  final RxList<dynamic> allactionComments = <dynamic>[].obs;
  final RxList<dynamic> allacff = <dynamic>[].obs;
  UserPreference userPreference = UserPreference();
  List<Map<String, dynamic>> singledataList = [];
  RxString selectedOption = "".obs; // Stores the selected option

  Future<void> shareContent() async {
    await FlutterShare.share(
        title: 'Check out this poll',
        text: 'Check out this poll on PollChat!',
        linkUrl:
            'https://pollchat.example.com/poll/12345', // Replace with your poll URL
        chooserTitle: 'Share Poll');
  }

  addPollType(String val) {
    String _pollType = val.toLowerCase();
    pollType.value = _pollType;
  }

  void sendVote(String pollId, String option) async {
    try {
      print("Option: $option");
      final response = await _api.postSendVote({"$option": true}, pollId);
      print("Vote value-- ${response}");

      // ✅ Store selected option in the model
      // selectedOption.value = option;

      // update UI
      // update();
    } catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  void resetVote(String pollId) async {
    try {
      final response = await _api.resetVote(pollId);
      print("RESET VOTE-- $response");
      var newValue = response["newValue"];
      print("Type of newValue: ${newValue.runtimeType}");
      if (newValue != null) {
        someObservableValue.value = newValue;
      }
    } catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  void editPoll(String pollId, Map<String, dynamic> data) async {
    try {
      final requestData = {
        "pollType": data["pollType"],
        "question": data["question"],
        'optionA': data['optionA'],
        'optionB': data['optionB'],
      };

      final response = await _api.pollVisibility(pollId, requestData);

      print("Response-- $response");
      // Handle response if needed
    } catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  //IMPRESSIONS
  // 0- dislike; 1- like
  void likeDislike(String pollId, int val) async {
    try {
      print("likeDislike: $likeDislike");

      _api.postLikeDislike({"likeDislike": val}, pollId).then((value) {
        print("Vote value-- ${value}");
        // singleUser.value = value["user"];
      });
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> saveUnsave(String pollId, int val) async {
    try {
      print("likeDislike: $likeDislike");

      _api.postLikeDislike({"likeDislike": val}, pollId).then((value) {
        print("Vote value-- ${value}");
        // singleUser.value = value["user"];
      });
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> savePoll(String pollId, int val) async {
    try {
      print("likeDislike: $likeDislike");

      _api.postSavePoll({"likeDislike": val}, pollId).then((value) {
        print("Vote value-- ${value}");
      });
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> addComment(
    String pollId,
    String commentpoll,
  ) async {
    try {
      print("comment: $commentpoll");
      _api.postComment({"comment": commentpoll}, pollId).then((valuea) {
        print("Comment value-- ${valuea['message']}");
        if (valuea['status'] == false) {
          Utils.snackBar("Error", valuea['message']);
        }
        getAllCommentsPoll(pollId).then((_) {
          update();
        });
      });
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> addCommentAction(
    String actionId,
    String comment,
  ) async {
    try {
      print("comment: $comment");
      _api.postComment({"comment": comment}, actionId).then((value) {
        print("Comment value-- ${value['message']}");
        // singleUser.value = value["user"];
        if (value['status'] == false) {
          Utils.snackBar("Error", value['message']);
        }

        getActionComment(actionId).then((_) {
          update();
        });
      });
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> getAllCommentsPoll(String pollId) async {
    try {
      print("Fetching comments for pollId: $pollId");
      var value = await _api.getAllCommentApi(pollId);
      if (value != null && value.containsKey("comments")) {
        List<dynamic> list = value["comments"];
        allComments.value = list.reversed.toList();
      } else {
        throw FormatException("Invalid response format");
      }
    } catch (e) {
      print('Error fetching comments: $e');
      // Utils.snackBar(
      //     "Error", "Failed to load comments. Please try again later.");
    }
  }

  Future<void> getActionComment(actionId) async {
    try {
      print("Fetching comments for pollId: $actionId");
      var value = await _api.getActionCommentApi(actionId);
      loading.value = true;
      if (value != null && value.containsKey("comments")) {
        List<dynamic> list = value["comments"];
        allactionComments.value = list.reversed.toList();
        loading.value = false;
        //allactionComments.reversed.first(list.reversed.toList());
      } else {
        throw FormatException("Invalid response format");
      }
    } catch (e) {
      print('Error fetching comments: $e');
      Utils.snackBar(
          "Error", "Failed to load comments. Please try again later.");
    }
  }

  hidePoll(String pollId, String token) async {
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'PUT',
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/poll/hide/$pollId'));
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        Utils.snackBar('Success', "Poll hide successfully");
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void deletePoll(String pollId, var token) async {
    log("message ====>deletePoll API Call");
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'DELETE',
        Uri.parse(
            'http://pollchat.myappsdevelopment.co.in/api/v1/poll/deletepoll/$pollId'));
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        log("message ====> delete API Call success ");
        print(await response.stream.bytesToString());
        Utils.snackBar('Success', "Delete Poll successfully");
        allComments.removeWhere((comment) => comment['pollId'] == pollId);
        update();
      } else {
        log("message ====> Delete Poll API Call failed");
        print(response.reasonPhrase);
        Utils.snackBar('Poll', "Poll Delete Already");
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  updatesinglepoll(String pollId) async {
    final token = await userPreference.getAuthToken();

    if (token == null || token.isEmpty) {
      print('Token is null or empty');
      return;
    }

    final headers = {'Authorization': 'Bearer $token'};
    final url = 'https://pollchat.myappsdevelopment.co.in/api/v1/poll/$pollId';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          final pollData = jsonData['poll'];

          print('Poll data fetched successfully');
          Get.toNamed(RouteName.editCaptionScreen, arguments: pollData);
        } else {
          print('Failed to fetch poll data: ${jsonData['message']}');
        }
      } else {
        print('Request failed with status: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }
}
