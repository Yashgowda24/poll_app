import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/app_exception.dart';
import 'package:poll_chat/data/network/base_api_services.dart';
import 'package:http/http.dart' as http;
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/utils/utils.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

class NetworkApiServices extends BaseApiServices {
  UserPreference userPreference = UserPreference();

  @override
  Future getLoginApi(String url, String phone, String password) async {
    String? authToken = await userPreference.getAuthToken();
    print("AUTH $authToken");
    dynamic responseJson;
    Map<String, String> headers = {'phone': phone, 'password': password};
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }
    return responseJson;
  }

  @override
  Future getApi(String url) async {
    String? authToken = await userPreference.getAuthToken();

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    };

    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      // .timeout(const Duration(seconds: 10)
      //);
      if (response.statusCode == 200) {
        final dynamic responseJson = jsonDecode(response.body);
        print("Response Body: $responseJson");
        return responseJson;
      }
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }

    return responseJson;
  }

  Future<void> getMusicApi(String url) async {
    String? authToken = await userPreference.getAuthToken();
    if (kDebugMode) {
      // print("URL-- $url");
      // print("Access Token: ${authToken}");
    }
    Map<String, String> headers = {};
    if (authToken != null) {
      headers['Authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      //.timeout(const Duration(seconds: 10));
      // print("response.body music ${response.body}");

      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }

    return responseJson;
  }

  getPollApi(String url) async {
    String? authToken = await userPreference.getAuthToken();
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: authToken.toString().trim()
    };
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }
    print(responseJson);
    return responseJson;
  }

  getAllUserApi(String url) async {
    String? authToken = await userPreference.getAuthToken();
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: authToken.toString().trim()
    };
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }
    print(responseJson);
    return responseJson;
  }

  getAllPollsNew(String url) async {
    String? authToken = await userPreference.getAuthToken();
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: authToken.toString().trim()
    };
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }
    print(responseJson);
    return responseJson;
  }

  getsavedPolls(String url) async {
    String? authToken = await userPreference.getAuthToken();
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: authToken.toString().trim()
    };
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }
    print(responseJson);
    return responseJson;
  }

  // getAllPollsNew(String url) async {
  //   String? authToken = await userPreference.getAuthToken();
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer ${authToken?.trim()}'
  //   };
  //   dynamic responseJson;
  //   try {
  //     final response = await http
  //         .get(Uri.parse(url), headers: headers)
  //         .timeout(const Duration(seconds: 10));
  //     responseJson = jsonDecode(response.body);
  //     print(
  //         "==========>  sucess API calldi  <===================== ===${responseJson.toJson()}");
  //   } on SocketException {
  //     print("==========>  SocketException  <=====================");

  //     throw InternetException('');
  //   } on RequestTimeout {
  //     print("==========>  RequestTimeout <=====================");

  //     throw RequestTimeout('');
  //   }
  //   return responseJson;
  // }

  Future<void> getCommentPollApi(String url) async {
    String? authToken = await userPreference.getAuthToken();
    if (kDebugMode) {
      // print("POLLURL-- $url");
      // print("Access Token: ${authToken}");
    }
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: authToken.toString().trim()
    };
    // print("Access Token: $authToken");
    // if(authToken != null) {
    // headers['Authorization'] = "Bearer $authToken";
    // }
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      // print("POLL response.body ${response.body}");
      responseJson = jsonDecode(response.body);
      print(responseJson);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }

    return responseJson;
  }

  @override
  postApi(data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    Map<String, String> headers = {
      "accept": "application/json",
      "content-type": "application/json"
    };

    String? authToken = await userPreference.getAuthToken();

    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      // headers['Authorization'] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NWY3Y2Q2NzVmZjRjOGNmODBmODY2MjgiLCJpYXQiOjE3MTA3MzkwMzEsImV4cCI6MTcxMzMzMTAzMX0.AiNnVnLEA0Ux5oyhx2Com8FTRCwuFpyoQZrUw2TBA-0";//"Bearer $authToken";
    }
    dynamic responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode(data), headers: headers);
      // if (kDebugMode) {
      //   print(response.body);
      //   return jsonDecode(response.body);
      // }
      responseJson = jsonDecode(response.body);

      if (responseJson.containsKey('authToken') &&
          responseJson['authToken'] != null) {
        String newToken = responseJson['authToken'];
        await userPreference.setAuthToken(newToken);
        print("Token saved successfully: $newToken");
      }
      if (responseJson['user']['_id'] != null) {
        String _id = responseJson['user']['_id'];
        await userPreference.setUserID(_id);
        print("id saved successfully: $_id");
      }
      if (responseJson['user']['username'] != null) {
        String username = responseJson['user']['username'];
        await userPreference.setUsername(username);
        print("username saved successfully: $username");
      }
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  @override
  Future putApi(data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    Map<String, String> headers = {
      "accept": "application/json",
      "content-type": "application/json"
    };
    String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      // headers['Authorization'] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NWY3Y2Q2NzVmZjRjOGNmODBmODY2MjgiLCJpYXQiOjE3MTA3MzkwMzEsImV4cCI6MTcxMzMzMTAzMX0.AiNnVnLEA0Ux5oyhx2Com8FTRCwuFpyoQZrUw2TBA-0";//"Bearer $authToken";
    }
    dynamic responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode(data), headers: headers);
      if (kDebugMode) {
        print(response.body);
        return jsonDecode(response.body);
      }
      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  Future postSendVoteApi(Map<String, bool> data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      headers['Authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      print("response ---");
      final response = await http.post(Uri.parse(url),
          body: json.encode(data), headers: headers);

      responseJson = jsonDecode(response.body);
      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  Future postLikeDislikeApi(var data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      headers['Authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      print("response ---");
      final response = await http.post(Uri.parse(url),
          body: json.encode(data), headers: headers);

      responseJson = jsonDecode(response.body);
      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  Future postCommentApi(var data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      headers['Authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      print("response ---");
      final response = await http.post(Uri.parse(url),
          body: json.encode(data), headers: headers);

      responseJson = jsonDecode(response.body);

      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  Future resetVoteApi(String url) async {
    if (kDebugMode) {
      print(url);
    }
    Map<String, String> headers = {
      // "accept": "application/json",
      // "content-type": "application/json"
    };
    String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      headers['Authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      final response = await http.delete(Uri.parse(url),
          // body: json.encode({}),
          headers: headers);
      if (kDebugMode) {
        print(response.body);
        // return jsonDecode(response.body);
      }
      responseJson = jsonDecode(response.body);
      Utils.snackBar("Reset", responseJson['message']);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  Future putVisibilityApi(var data, String url) async {
    if (kDebugMode) {
      print(data);
      print(url);
    }
    Map<String, String> headers = {
      "accept": "application/json",
      "content-type": "application/json"
    };
    String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      headers['Authorization'] = "$authToken";
    }
    dynamic responseJson;
    try {
      final response = await http.put(Uri.parse(url),
          body: jsonEncode(data), headers: headers);
      // if (kDebugMode) {
      //   // print(response.body);
      //   return jsonDecode(response.body);
      // }
      responseJson = jsonDecode(response.body);
      Utils.snackBar("Success", "Poll Updated Success");
      Get.toNamed(RouteName.myProfileScreen);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  @override
  Future postCreatePostApi(data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    Map<String, String> headers = {
      // "accept": "application/json",
      // "content-type": "application/json"
    };
    String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      headers['Authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode(data), headers: headers);
      if (kDebugMode) {
        // print(response.body);
        return jsonDecode(response.body);
      }
      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    } catch (e) {
      print("232 ${e.toString()}");
    }

    return responseJson;
  }

  Future<dynamic> postStory(Map<String, dynamic> data, String url) async {
    var authToken = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $authToken'};

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    request.fields.addAll({
      'momentType': data['momentType'],
      'momentText': data['momentText'],
      // 'momentmedia': data['momentmedia'],
      // 'musicId': data['musicId'] ?? "",
    });

    var actionFile =
        await http.MultipartFile.fromPath('momentmedia', data['momentmedia']);
    request.files.add(actionFile);
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        Get.offAllNamed(RouteName.dashboardScreen);
        Get.snackbar('Success', 'Story Created Successfully');
        return json.decode(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');

        return null;
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw InternetException(e.message);
    } on HttpException catch (e) {
      print('HttpException: $e');
      throw InternetException(e.message);
    } on FormatException catch (e) {
      print('FormatException: $e');
      throw FormatException(e.message);
    } catch (e) {
      print('Exception: $e');
      throw Exception(e.toString());
    }
  }

  Future<dynamic> postCreatePostApi1(
      Map<String, dynamic> data, String url) async {
    var authToken = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $authToken'};

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    // request.fields.addAll({
    //   'actionType': data['actionType'],
    //   'musicId': data['musicId'] ?? "",
    //   'actionCaption': data['actionCaption'],
    // });
    request.fields.addAll({
      'actionType': data['actionType'],
      'actionCaption': data['actionCaption'],
    });

    if (data['musicId'] != null) {
      request.fields['musicId'] = data['musicId'];
    } else {
      // request.fields['musicId'] = "";
    }

    var actionFile =
        await http.MultipartFile.fromPath('action', data['action']);
    request.files.add(actionFile);
    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        Get.offAllNamed(RouteName.dashboardScreen);
        Get.snackbar('Success', 'Action Created Successfully');
        return json.decode(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');

        return null;
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw InternetException(e.message);
    } on HttpException catch (e) {
      print('HttpException: $e');
      throw InternetException(e.message);
    } on FormatException catch (e) {
      print('FormatException: $e');
      throw FormatException(e.message);
    } catch (e) {
      print('Exception: $e');
      throw Exception(e.toString());
    }
  }

  // @override
  // postPollApi(data, String url) async {
  //   if (kDebugMode) {
  //     print(url);
  //     print(data);
  //   }
  //   Map<String, String> headers = {
  //     //"accept": "application/json",
  //     //"content-type": "application/json"
  //   };
  //   String? authToken = await userPreference.getAuthToken();
  //   // userPreference.getAuthToken();
  //   // if (kDebugMode) {
  //   //   print("authToken--$authToken");
  //   // }
  //   if (authToken != null) {
  //     headers['Authorization'] = "Bearer $authToken";
  //   }
  //   dynamic responseJson;
  //   try {
  //     final response = await http.post(Uri.parse(url),
  //         body: jsonEncode(data), headers: headers);
  //     // if (kDebugMode) {
  //     //   // print(response.body);
  //     //   return jsonDecode(response.body);
  //     // }
  //     responseJson = jsonDecode(response.body);
  //   } on SocketException {
  //     throw InternetException('');
  //   } on RequestTimeout {
  //     throw RequestTimeout('');
  //   } catch (e) {
  //     print("232 ${e.toString()}");
  //   }

  //   return responseJson;
  // }

  Future<Map<String, dynamic>> postPollApi(
      Map<String, dynamic> data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    Map<String, String> headers = {
      "Authorization":
          "Bearer ${await userPreference.getAuthToken()}", // Add authorization token
    };

    dynamic responseJson;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll({
        'pollType': data['pollType'],
        'question': data['question'],
        'hashtags': data['hashtags'] ?? "",
      });
      for (var option in ['A', 'B', 'C', 'D']) {
        if (data.containsKey('option$option')) {
          request.fields.addAll({'option$option': data['option$option']});
        }
      }

      if (data.containsKey('pollPhoto')) {
        var file =
            await http.MultipartFile.fromPath('pollPhoto', data['pollPhoto']);
        request.files.add(file);
      }
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        Get.offAllNamed('${RouteName.dashboardScreen}/dashboard_view');
        if (kDebugMode) {
          print(response.body);
        }
      } else {
        Utils.snackBar("Error", responseJson['message']);
        // throw Exception(responseJson['message']);
      }
    } on SocketException {
      throw InternetException('No Internet Connection');
    } on TimeoutException {
      throw RequestTimeout('Request Timeout');
    } catch (e) {
      throw Exception('Error: $e');
    }

    return responseJson;
  }

  Future<Map<String, dynamic>> editsPostPollApi(
      Map<String, String> data, String url, String imagePath) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    Map<String, String> headers = {
      "Authorization":
          "Bearer ${await userPreference.getAuthToken()}", // Add authorization token
    };

    dynamic responseJson;
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields.addAll(data);

      // var file = await http.MultipartFile.fromPath('pollPhoto', imagePath);
      // request.files.add(file);
      request.headers.addAll(headers);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      responseJson = jsonDecode(response.body);
    } on SocketException {
      throw InternetException('No Internet Connection');
    } on TimeoutException {
      throw RequestTimeout('Request Timeout');
    } catch (e) {
      throw Exception('Error: $e');
    }

    return responseJson;
  }

  @override
  Future postLoginApi(String url, String phone, String password) async {
    if (kDebugMode) {
      print(url);
      print(phone);
    }
    Map<String, String> headers = {
      "accept": "application/json",
      "content-Type": "application/json"
    };
    // String? authToken = await userPreference.getAuthToken();
    // userPreference.getAuthToken();
    if (kDebugMode) {
      // print("authToken--$authToken");
    }
    // if(authToken != null) {
    //   headers['Authorization'] = "Bearer $authToken";
    // }
    dynamic responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode({"phone": phone, "password": password}),
          headers: headers);
      if (kDebugMode) {
        // print(response.body);
        return jsonDecode(response.body);
      }
      responseJson = jsonDecode(response.body);
      return responseJson;
    } on SocketException {
      throw InternetException('No Internet Connection!');
    } on RequestTimeout {
      throw RequestTimeout('Request Timed Out');
    } catch (e) {
      print("API Error: ${e.toString()}");
      print("232 ${e.toString()}");
    }
    return responseJson;
  }

  @override
  Future postApi1(data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    dynamic responseJson;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );
      if (kDebugMode) {
        print(response);
      }
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }

    return responseJson;
  }

  @override
  Future deleteApi(String url) async {
    String? authToken = await userPreference.getAuthToken();
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    };
    // print(authToken);
    if (authToken != null) {
      headers['authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }

    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw InvalidUrlException;
      default:
        throw FetchDataException(
            'Error occurred while communicating with Server');
    }
  }

  @override
  Future putEditProfileApi(data, String url) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String? authToken = await userPreference.getAuthToken();
    if (kDebugMode) {
      print("authToken--$authToken");
    }
    if (authToken != null) {
      headers['Authorization'] = "Bearer $authToken";
    }
    dynamic responseJson;
    try {
      final response = await http.put(Uri.parse(url),
          body: jsonEncode(data), headers: headers);
      if (kDebugMode) {
        print(response.body);
      }
      responseJson = response.body;
    } on SocketException {
      throw InternetException('');
    } on RequestTimeout {
      throw RequestTimeout('');
    }

    return responseJson;
  }

//@override
// Future putEditProfileOnly(data, String url) async {
//   if (kDebugMode) {
//     print(url);
//     print(data);
//   }

//   var headers = {
//     'Authorization': 'Bearer ${await userPreference.getAuthToken()}'
//   };

//   var request = http.MultipartRequest('PUT', Uri.parse(url));
//   data.forEach((key, value) {
//     request.fields[key] = value.toString();
//   });

//   if (data.isNotEmpty) {
//     request.files
//         .add(await http.MultipartFile.fromPath('profilePhoto', data));
//   }
//   request.headers.addAll(headers);
//   try {
//     final response = await request.send();
//     if (response.statusCode == 201) {
//       print(await response.stream.bytesToString());
//     } else {
//       print('Failed: ${response.reasonPhrase}');
//     }
//   } on SocketException {
//     throw InternetException('');
//   } on RequestTimeout {
//     throw RequestTimeout('');
//   }
// }
}
