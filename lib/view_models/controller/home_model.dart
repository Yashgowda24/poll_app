// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/models/user_model/user_model.dart';
import 'package:poll_chat/res/app_url/app_url.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import '../../data/repository/profile_repository.dart';
import '../../utils/utils.dart';

class HomeViewModelController extends GetxController {
  final _api = ProfileRepository();
  UserPreference userPreference = UserPreference();
  UserModel? userModel;
  final RxMap<String, dynamic> singleUser = <String, dynamic>{}.obs;
  final RxList<dynamic> allPolls = <dynamic>[].obs;
  final RxList<dynamic> allPinnedPolls = <dynamic>[].obs;
  final RxList<dynamic> allPollsUser = <dynamic>[].obs;
  final RxList<dynamic> tranding = <dynamic>[].obs;
  final RxList<dynamic> sentRequests = <dynamic>[].obs;
  final RxList<dynamic> otheruserpoll = <dynamic>[].obs;

  final RxList<dynamic> singlePollCard = <dynamic>[].obs;
  final RxList<dynamic> savedPollCard = <dynamic>[].obs;
  RxBool loading = false.obs;
  @override
  void onInit() {
    sendRequest();
    super.onInit();
  }

  Future<void> singlePolls(String? pollId) async {
    String? authToken = await userPreference.getAuthToken();
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    loading.value = true;
    final response = await http.get(Uri.parse('${AppUrl.baseUrl}/$pollId'),
        // "https://poll-chat.onrender.com$pollId"),
        // "https://pollchat.myappsdevelopment.co.in/api/v1/poll/$pollId"),
        headers: headers);
    if (response.statusCode == 200) {
      singlePollCard.clear();
      final jsonData = jsonDecode(response.body);
      log("all Pinned Polls ====> ${jsonDecode(response.body)}");
      var poll = jsonData['poll'];
      singlePollCard.value = [poll];
      log("all Pinned Polls length ====> ${singlePollCard.length}");
      loading.value = false;
    } else {
      loading.value = false;
      throw Exception(
          'Failed to fetch poll search results: ${response.reasonPhrase}');
    }
  }

  Future<void> pinPoll(String pollId, String token) async {
    log("message ====> pinPoll API Call");
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'PUT', Uri.parse("${AppUrl.baseUrl}/api/v1/poll/pin/$pollId"));
    // 'https://pollchat.myappsdevelopment.co.in/api/v1/poll/pin/$pollId'));
    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        log("message ====> pinPoll API Call success ");
        print(await response.stream.bytesToString());
        Utils.snackBar('Success', "Poll Pined successfully");
      } else {
        log("message ====> pinPoll API Call failed");
        print(response.reasonPhrase);
        Utils.snackBar('Poll', "Poll Hided Already");
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> sendRequest() async {
    loading.value = true;
    print("Loading started");
    try {
      var token = await userPreference.getAuthToken();
      var headers = {'Authorization': 'Bearer $token'};
      var request = http.Request(
          'GET', Uri.parse('${AppUrl.baseUrl}/api/v1/friend/sent/'));
      // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/sent/'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonData = jsonDecode(responseBody);

        if (jsonData['status'] == true) {
          if (jsonData['sentRequests'] is List) {
            sentRequests.value = jsonData['sentRequests'];
          } else {
            sentRequests.value = [jsonData['sentRequests']];
          }
          print("Requests fetched successfully");
        } else {
          print(jsonData['message']);
          sentRequests.value = []; // Clear the list if there's no data
        }
      } else {
        print(response.reasonPhrase);
        sentRequests.value = []; // Clear the list if the request fails
      }
    } catch (e) {
      print("Error: $e");
      sentRequests.value = []; // Clear the list if there's an error
    } finally {
      loading.value = false;
      print("Loading ended");
    }
  }

  Future<void> unfriend(String id) async {
    var token = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $token'};
    var request = http.Request(
        'GET', Uri.parse('${AppUrl.baseUrl}/api/v1/friend/remove/$id'));
    // 'https://pollchat.myappsdevelopment.co.in/api/v1/friend/remove/$id'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Get.snackbar('Cancel', 'Request Cancel Successfully');
      print(await response.stream.bytesToString());
      sendRequest(); // Refresh the list after unfriend
    } else {
      print(response.reasonPhrase);
    }
  }
  // Future<void> suggetionsApiRequest() async {
  //   var token = await userPreference.getAuthToken();
  //   var headers = {'Authorization': 'Bearer $token'};
  //   var request = http.Request(
  //       'GET',
  //       Uri.parse(
  //           'https://pollchat.myappsdevelopment.co.in/api/v1/friend/suggestion'));
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     String responseBody = await response.stream.bytesToString();
  //     Map<String, dynamic> jsonData = jsonDecode(responseBody);
  //     if (jsonData['status'] == true) {
  //       suggestRequests.add(jsonData['suggestedFriends']);
  //       //suggestRequests.addAll(iterable) = jsonData['suggestedFriends'];
  //       // loading.value = false;
  //     } else {
  //       // loading.value = false;

  //       print(jsonData['message']);
  //     }
  //   } else {
  //     // loading.value = false;

  //     print(response.reasonPhrase);
  //   }
  // }

  Future<void> getUser() async {
    try {
      String? username = await userPreference.getUsername();
      String? id = await userPreference.getUserID();
      print(id);
      if (username != null) {
        _api.getUserApi(id!).then((value) {
          print("User - $value");
          userModel = UserModel.fromJson(value);
          print(userModel);
        });
      } else {
        Utils.snackBar("Error", "User Not Found");
      }
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> getSingleUser(String id) async {
    try {
      _api.getUserApi(id).then((value) {
        // print("Single User-- ${value}");
        singleUser.value = value["user"];
        //callBack();
      });
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> getAllPolls() async {
    try {
      String? id = await userPreference.getUserID();
      loading.value = true;
      _api.getAllPollsApi(id!).then((value) {
        log("polls-- $value");

        List<dynamic> list = value["polls"];
        allPollsUser.value = list.reversed.toList();
        loading.value = false;
        update();
      });
    } on Exception catch (e) {
      loading.value = false;
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> getuserPolls(String? id) async {
    try {
      loading.value = true;
      final response = await _api.getAllPollsApi(id!);
      log("polls-- $response");
      List<dynamic> list = response["polls"];
      otheruserpoll
          .assignAll(list.reversed.toList()); // Correctly update the RxList
    } catch (e) {
      Utils.snackBar("Error", e.toString());
    } finally {
      loading.value =
          false; // Ensure this is called in both success and error cases
    }
  }

  Future<void> getAllPollsEveryOne() async {
    try {
      loading.value = true;
      _api.getAllPollsFor().then((value) {
        log("polls-- $value");
        List<dynamic> list = value["polls"];

        allPolls.value = list.reversed.toList();
        loading.value = false;

        update();
      });
    } on Exception catch (e) {
      loading.value = false;
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> getSavedPolls() async {
    try {
      loading.value = true;
      _api.getSavedPolls().then((value) {
        log("polls-- $value");
        List<dynamic> list = value["polls"];

        savedPollCard.value = list.reversed.toList();
        loading.value = false;
      });
    } on Exception catch (e) {
      loading.value = false;
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> getallUser() async {
    try {
      String? username = await userPreference.getUsername();
      if (username != null) {
        _api.getallUsersApi().then((value) {});
      } else {
        Utils.snackBar("Error", "User Not Found");
      }
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }
}
