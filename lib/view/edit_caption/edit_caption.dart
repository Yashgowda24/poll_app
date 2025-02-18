// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:poll_chat/res/assets/icon_assets.dart';
// import 'package:poll_chat/res/colors/app_color.dart';
// import 'package:poll_chat/view_models/controller/edit_caption_view_model.dart';
// import '../../models/poll_model/poll_model.dart';
// import '../../view_models/controller/create_poll_view_model.dart';
// import '../../view_models/controller/home_model.dart';
// import '../../view_models/controller/user_preference_view_model.dart';

// class EditCaptionView extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _EditCaptionView();
// }

// class _EditCaptionView extends State<EditCaptionView> {
//   final editPollViewModel = Get.put(PollModel());
//   final homeViewModel = Get.put(HomeViewModelController());
//   final createPollViewModel = Get.put(CreatePollViewModel());

//   final pollviewModel = Get.put(PollModel());

//   final _formKey = GlobalKey<FormState>();

//   var _selectedItem = "Everyone";

//   @override
//   void initState() {
//     super.initState();
//     fetchPollData();
//   }

//   Future<void> fetchPollData() async {
//     final pollId = Get.arguments['pollId']; // Pass pollId as an argument
//     if (pollId != null) {
//       var token = await userPreference.getAuthToken();

//       if (token == null || token.isEmpty) {
//         print('Token is null or empty');
//         return;
//       }

//       var headers = {'Authorization': 'Bearer $token'};
//       var url = 'https://pollchat.myappsdevelopment.co.in/api/v1/poll/$pollId';

//       var request = http.Request('GET', Uri.parse(url));
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();
//       String responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         Map<String, dynamic> jsonData = json.decode(responseBody);

//         if (jsonData['status'] == true) {
//           Map<String, dynamic> pollData = jsonData['poll'];
//           editPollViewModel.textEditingControllers(pollData['question']);
//           _selectedItem = pollData['pollType'] ?? 'Everyone';
//           setState(() {});
//         } else {
//           print('Failed to fetch poll data: ${jsonData['message']}');
//         }
//       } else {
//         print('Request failed with status: ${response.reasonPhrase}');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Caption"),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: UnconstrainedBox(
//               child: InkWell(
//                 onTap: () {
//                   if (editPollViewModel
//                           .textEditingControllers[0].text.isNotEmpty &&
//                       editPollViewModel
//                           .textEditingControllers[1].text.isNotEmpty) {
//                     Map<String, String> data = {
//                       'pollType': _selectedItem,
//                       'question':
//                           editPollViewModel.askQuestionController.value.text ??
//                               '',
//                       'optionA':
//                           editPollViewModel.textEditingControllers[0].text ??
//                               "",
//                       'optionB':
//                           editPollViewModel.textEditingControllers[1].text ??
//                               "",
//                     };

//                     updatePoll(data: data);

//                     Get.back();
//                   } else {
//                     Get.snackbar("Failed", "Please Enter Choice");
//                   }
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: AppColor.purpleColor,
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                     child: Text(
//                       "Done",
//                       style:
//                           TextStyle(color: AppColor.whiteColor, fontSize: 12),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       height: 35,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                             color: AppColor.purpleColor, width: 1.18),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         child: DropdownButton<String>(
//                           alignment: Alignment.center,
//                           padding: const EdgeInsets.all(0),
//                           icon: Padding(
//                             padding: const EdgeInsets.all(4),
//                             child: SizedBox(
//                               width: 6,
//                               height: 10,
//                               child:
//                                   SvgPicture.asset(IconAssets.chevronRightIcon),
//                             ),
//                           ),
//                           underline: Container(),
//                           value: _selectedItem,
//                           onChanged: (String? newValue) {
//                             setState(() {
//                               _selectedItem = newValue!;
//                               editPollViewModel.pollType(_selectedItem);
//                             });
//                           },
//                           items: <String>['Everyone', 'Friends', 'None']
//                               .map<DropdownMenuItem<String>>((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(
//                                 value,
//                                 style: const TextStyle(
//                                     color: AppColor.purpleColor, fontSize: 12),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 35,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                             color: AppColor.purpleColor, width: 1.18),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: SvgPicture.asset(IconAssets.globeIcon),
//                             ),
//                             const SizedBox(width: 2),
//                             const Text(
//                               'Every one can comment',
//                               style: TextStyle(color: AppColor.purpleColor),
//                             ),
//                             const SizedBox(width: 2),
//                             SizedBox(
//                               width: 6,
//                               height: 10,
//                               child:
//                                   SvgPicture.asset(IconAssets.chevronRightIcon),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: TextFormField(
//                     controller: editPollViewModel.askQuestionController.value,
//                     decoration: const InputDecoration(
//                       labelText: "Ask your question",
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Container(
//                   height: 1,
//                   color: AppColor.greyLight3Color,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Card(
//                   elevation: 5,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 10),
//                           child: Form(
//                             key: _formKey,
//                             child: Obx(() => ListView.builder(
//                                   itemCount: 2,
//                                   shrinkWrap: true,
//                                   itemBuilder: (context, index) {
//                                     var choiceNo = index + 1;
//                                     return Padding(
//                                       padding: const EdgeInsets.only(bottom: 8),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Flexible(
//                                             flex: 9,
//                                             child: Container(
//                                               width: double.infinity,
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                   color: AppColor.purpleColor,
//                                                   width: 1,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(5),
//                                               ),
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                   vertical: 2,
//                                                   horizontal: 10,
//                                                 ),
//                                                 child: TextFormField(
//                                                   controller: editPollViewModel
//                                                           .textEditingControllers[
//                                                       index],
//                                                   decoration: InputDecoration(
//                                                     border: InputBorder.none,
//                                                     hintText:
//                                                         "Choice $choiceNo",
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 )),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border:
//                         Border.all(color: AppColor.greyLight3Color, width: 1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 16),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: SvgPicture.asset(
//                               IconAssets.pollImagePlaceholderIcon),
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           child: Text('Upload Poll Background'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Text(
//                         'You can upload up to 4 backgrounds',
//                         style: TextStyle(color: AppColor.greyLight4Color),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   UserPreference userPreference = UserPreference();

//   Future<void> updatePoll({required Map<String, String> data}) async {
//     var headers = {
//       'Authorization': 'Bearer ${await userPreference.getAuthToken()}',
//     };
//     var request = http.MultipartRequest(
//       'PUT',
//       Uri.parse(
//           'http://pollchat.myappsdevelopment.co.in/api/v1/poll/update/${Get.arguments['pollId']}'),
//     );
//     request.fields.addAll(data);
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       log("success ===> ");
//       print(await response.stream.bytesToString());
//     } else {
//       log("failed ===> ");
//       print(response.reasonPhrase);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/view_models/controller/edit_caption_view_model.dart';

import '../../models/poll_model/poll_model.dart';
import '../../view_models/controller/create_poll_view_model.dart';
import '../../view_models/controller/home_model.dart';

class EditCaptionView extends StatefulWidget {
  const EditCaptionView({super.key});

  @override
  State<StatefulWidget> createState() => _EditCaptionView();
}

class _EditCaptionView extends State<EditCaptionView> {
  final editPollViewModel = Get.put(EditCaptionViewModel());
  final homeViewModel = Get.put(HomeViewModelController());
  final createPollViewModel = Get.put(CreatePollViewModel());
  final pollviewModel = Get.put(PollModel());
  final _formKey = GlobalKey<FormState>();
  var _selectedItem = "Everyone";
  final arguments = Get.arguments as Map<String, dynamic>;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Caption"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: UnconstrainedBox(
              child: InkWell(
                onTap: () async {
                  final String? id = arguments["_id"] as String?;

                  if (id != null) {
                    pollviewModel.editPoll(id, {
                      'pollType': _selectedItem,
                      'question':
                          editPollViewModel.askQuestionController.value.text,
                            'hashtags':
                          editPollViewModel.hashtagController.value.text,
                      'optionA': editPollViewModel
                              .textEditingControllers.isNotEmpty
                          ? editPollViewModel.textEditingControllers[0].text
                          : '', 
                      'optionB': editPollViewModel
                                  .textEditingControllers.length >
                              1
                          ? editPollViewModel.textEditingControllers[1].text
                          : '',
                    });
                  } else {
                    print("ID is null or not found");
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColor.purpleColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text(
                      "Done",
                      style:
                          TextStyle(color: AppColor.whiteColor, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Image.network(homeViewModel
                        .singleUser["profilePhoto"]
                        .toString()
                        .trim()),
                  ),
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: AppColor.purpleColor, width: 1.18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: DropdownButton<String>(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(0),
                        icon: Padding(
                          padding: const EdgeInsets.all(4),
                          child: SizedBox(
                            width: 6,
                            height: 10,
                            child:
                                SvgPicture.asset(IconAssets.chevronRightIcon),
                          ),
                        ),
                        underline: Container(),
                        value: _selectedItem,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedItem = newValue!;
                            pollviewModel.addPollType(newValue);
                          });
                        },
                        items: <String>['Everyone', 'Friends', 'None']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                  color: AppColor.purpleColor, fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: AppColor.purpleColor, width: 1.18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: SvgPicture.asset(IconAssets.globeIcon),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          const Text(
                            'Every one can comment',
                            style: TextStyle(color: AppColor.purpleColor),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                            width: 6,
                            height: 10,
                            child:
                                SvgPicture.asset(IconAssets.chevronRightIcon),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextFormField(
                  controller: editPollViewModel.askQuestionController.value,
                  decoration: InputDecoration(
                    labelText: arguments["question"],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextFormField(
                  controller: editPollViewModel.hashtagController.value,
                  decoration: InputDecoration(
                    labelText: arguments["hashtags"][0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 1,
                color: AppColor.greyLight3Color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Form(
                            key: _formKey,
                            child: ListView.builder(
                                itemCount: 2,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  var choiceNo = index + 1;
                                  editPollViewModel.addNewController();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            flex: 9,
                                            child: Container(
                                              width: double.infinity,
                                              // height: 40,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          AppColor.purpleColor,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 10),
                                                child: TextFormField(
                                                    controller: editPollViewModel
                                                            .textEditingControllers[
                                                        index],
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          "${arguments['optionA']} ${arguments['optionB']} $choiceNo",
                                                    )),
                                              ),
                                            )),
                                        /*Flexible(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                // editPollViewModel.removeController(index: index);
                                              },
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: SvgPicture.asset(
                                                    IconAssets.removeIcon),
                                              ),
                                            )),*/
                                      ],
                                    ),
                                  );
                                })),
                      ),
                      /* Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                editPollViewModel.addNewController();
                              },
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: SvgPicture.asset(IconAssets.plusIcon),
                              ),
                            ),
                          ],
                        ),
                      )*/
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: AppColor.greyLight3Color, width: 1),
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: SvgPicture.asset(
                            IconAssets.pollImagePlaceholderIcon),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('Upload Poll Background'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'You can upload up to 4 backgrounds',
                      style: TextStyle(color: AppColor.greyLight4Color),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
