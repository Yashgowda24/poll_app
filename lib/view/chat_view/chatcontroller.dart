// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';

// class ChatController extends GetxController {
//   final TextEditingController controller = TextEditingController();
//   RxList<Map<String, dynamic>> globalMessages = <Map<String, dynamic>>[].obs;
//   var userProfilePhoto = ''.obs;
//   var userName = ''.obs;
//   String? selectedImagePath;
//   UserPreference userPreference = UserPreference();
//   dynamic user = Get.arguments;

//   var chatId;
//   void scrollToBottom(ScrollController _scrollController) {
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   Future<void> getMessage() async {
//     String? authToken = await userPreference.getAuthToken();
//     var headers = {
//       'Authorization': 'Bearer $authToken',
//       'Content-Type': 'application/json'
//     };

//     try {
//       http.Response response = await http.get(
//         Uri.parse(
//             'http://pollchat.myappsdevelopment.co.in/api/v1/message/get/$chatId'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         var jsonResponse = json.decode(response.body);
//         if (jsonResponse['status'] == true) {
//           List<Map<String, dynamic>> messages =
//               List<Map<String, dynamic>>.from(jsonResponse['messages']);
//           globalMessages.clear();
//           globalMessages.addAll(messages.map((message) {
//             return {
//               "message": message['message'],
//               "sent": message['sender'] == user['_id'],
//               "seen": true,
//               "time": message['createdAt'] != null
//                   ? DateTime.parse(message['createdAt'])
//                   : DateTime.now(),
//             };
//           }));
//         } else {
//           print(jsonResponse['message']);
//         }
//       } else {
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   Future<String> sendMessage(String message) async {
//     String? authToken = await userPreference.getAuthToken();
//     var headers = {
//       'Authorization': 'Bearer $authToken',
//       'Content-Type': 'application/json'
//     };

//     var url =
//         'http://pollchat.myappsdevelopment.co.in/api/v1/message/create/$chatId';

//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: jsonEncode({"message": message}),
//       );

//       if (response.statusCode == 201) {
//         return response.body;
//       } else {
//         throw Exception('Failed to send message: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       throw Exception('Failed to send message: $e');
//     }
//   }

//   void showOptions() {
//     Get.bottomSheet(
//       SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             ListTile(
//               leading: const Icon(Icons.location_on),
//               title: const Text('Get Location'),
//               onTap: () {
//                 _getCurrentLocation();
//                 Get.back();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.attach_file),
//               title: const Text('Share File'),
//               onTap: () {
//                 _selectFile();
//                 Get.back();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       globalMessages.add({
//         "message":
//             "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
//         "sent": true,
//         "seen": false,
//         "time": DateTime.now(),
//       });
//     } catch (e) {
//       print("Error getting current location: $e");
//     }
//   }

//   void _selectFile() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       selectedImagePath = pickedFile.path;
//     }
//   }

//   void chooseImage() {
//     Get.bottomSheet(
//       SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 _handleCameraClick();
//                 Get.back();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 _handleGalleryClick();
//                 Get.back();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleCameraClick() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.getImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       selectedImagePath = pickedFile.path;
//     }
//   }

//   void _handleGalleryClick() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       selectedImagePath = pickedFile.path;
//     }
//   }
// }
