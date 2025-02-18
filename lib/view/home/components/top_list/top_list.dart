// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:poll_chat/view/home/components/top_list/viewstatus.dart';
// import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
// import 'package:story_view/controller/story_controller.dart';
// import 'package:story_view/widgets/story_view.dart';
// import 'package:http/http.dart' as http;
// import 'package:video_thumbnail/video_thumbnail.dart';

// class TopList extends StatefulWidget {
//   const TopList({Key? key}) : super(key: key);

//   @override
//   State<TopList> createState() => _TopListState();
// }

// class _TopListState extends State<TopList> {
//   final controller = StoryController();
//   List<StoryItem> storyItems = [];
//   UserPreference userPreference = UserPreference();
//   List<Map<String, dynamic>> mediaThumbnails = [];

//   List<Map<String, dynamic>> moments = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchUserStory();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     String? authToken = await userPreference.getAuthToken();
//     var headers = {'Authorization': 'Bearer $authToken'};

//     try {
//       var response = await http.get(
//         Uri.parse(
//             'https://pollchat.myappsdevelopment.co.in/api/v1/moment/friends'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> jsonResponse = jsonDecode(response.body);

//         if (jsonResponse['status'] == true) {
//           List<dynamic>? friendMoments = jsonResponse['friendMoments'];

//           if (friendMoments != null) {
//             for (var friendMoment in friendMoments) {
//               List<dynamic>? moments = friendMoment['moments'];
//               if (moments != null && moments.isNotEmpty) {
//                 for (var moment in moments) {
//                   String? momentMediaUrl = moment['momentmedia'];
//                   if (momentMediaUrl != null) {
//                     Uint8List? thumbnailBytes;

//                     if (momentMediaUrl.endsWith('.jpg') ||
//                         momentMediaUrl.endsWith('.jpeg') ||
//                         momentMediaUrl.endsWith('.png')) {
//                       thumbnailBytes =
//                           await fetchImageThumbnail(momentMediaUrl);
//                     } else {
//                       thumbnailBytes = await generateThumbnail(momentMediaUrl);
//                     }

//                     if (thumbnailBytes != null) {
//                       mediaThumbnails.add({
//                         'friendId': moment['userId']['_id'],
//                         'thumbnailBytes': thumbnailBytes,
//                         'momentmedia': momentMediaUrl,
//                         'isVideo': !momentMediaUrl.endsWith('.jpg') &&
//                             !momentMediaUrl.endsWith('.jpeg') &&
//                             !momentMediaUrl.endsWith('.png'),
//                       });

//                       setState(() {});
//                     }
//                   }
//                 }
//               }
//             }
//           } else {
//             print('Friend moments data is null');
//           }
//         } else {
//           print('Failed to fetch moments: ${jsonResponse['message']}');
//         }
//       } else {
//         print('Request failed with status: ${response.statusCode}');
//         print('Response: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }

//   var action = '';
//   List<Map<String, dynamic>> storyThumbnails =
//       []; // Define storyThumbnails list

//   Future<void> fetchUserStory() async {
//     try {
//       String? authToken = await userPreference.getAuthToken();
//       String? userid = await userPreference.getUserID();
//       var headers = {'Authorization': 'Bearer $authToken'};
//       var url =
//           'https://pollchat.myappsdevelopment.co.in/api/v1/moment/$userid';
//       var response = await http.get(Uri.parse(url), headers: headers);

//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         List<dynamic> moments = jsonResponse['moments'];
//         print('Fetched ${moments.length} moments.');

//         for (var moment in moments) {
//           print(moment['action']['action']);
//           String action = moment['action']['action'];

//           Uint8List? thumbnailBytes;
//           if (action.endsWith('.jpg') ||
//               action.endsWith('.jpeg') ||
//               action.endsWith('.png')) {
//             thumbnailBytes = await fetchImageThumbnail(action);
//           } else {
//             thumbnailBytes = await generateThumbnail(action);
//           }

//           if (thumbnailBytes != null) {
//             setState(() {
//               storyThumbnails.add({
//                 'thumbnailBytes': thumbnailBytes,
//                 'action': action,
//               });
//             });
//           }
//         }

//         setState(() {}); // Update the UI after adding thumbnails
//       } else {
//         print('Request failed with status: ${response.statusCode}');
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       print('Error fetching user story: $e');
//     }
//   }

//   Future<Uint8List?> generateThumbnail(String videoUrl) async {
//     try {
//       print('Generating thumbnail for: $videoUrl');
//       final uint8List = await VideoThumbnail.thumbnailData(
//         video: videoUrl,
//         imageFormat: ImageFormat.JPEG,
//         maxWidth: 200,
//         quality: 75,
//       );
//       print('Thumbnail generated successfully');
//       return uint8List;
//     } catch (e) {
//       print('Error generating thumbnail: $e');
//       return null;
//     }
//   }

//   Future<Uint8List?> fetchImageThumbnail(String imageUrl) async {
//     try {
//       print('Fetching image thumbnail for: $imageUrl');
//       final response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         return response.bodyBytes;
//       } else {
//         print('Failed to fetch image: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Error fetching image thumbnail: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final itemWidth = MediaQuery.of(context).size.width * 0.3;
//     return Row(
//       children: [
//         SizedBox(
//           height: 150,
//           width: 150,
//           child: mediaThumbnails.isEmpty
//               ? Center(
//                   child: Image.asset(
//                     'assets/images/logo.png',
//                     height: 50,
//                     width: 50,
//                   ),
//                 )
//               : ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount:
//                       storyThumbnails.length, // Use storyThumbnails.length here
//                   itemBuilder: (BuildContext context, int index1) {
//                     return Container(
//                       margin: const EdgeInsets.only(left: 5, right: 5, top: 15),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: Colors.purple, width: 2),
//                       ),
//                       width: 150,
//                       height: 150,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(15),
//                         child: InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => StatusView(
//                                   storyThumbnails[index1]['action'],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Image.memory(
//                             storyThumbnails[index1]['thumbnailBytes'],
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         Expanded(
//           child: SizedBox(
//             height: 150,
//             child: mediaThumbnails.isEmpty
//                 ? Center(
//                     child: Image.asset(
//                       'assets/images/logo.png',
//                       height: 50,
//                       width: 50,
//                     ),
//                   )
//                 : ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: mediaThumbnails.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       return Container(
//                         margin:
//                             const EdgeInsets.only(left: 5, right: 5, top: 15),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(color: Colors.purple, width: 2),
//                         ),
//                         width: itemWidth,
//                         height: 150,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(15),
//                           child: InkWell(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StatusView(
//                                     mediaThumbnails[index]['action'],
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Image.memory(
//                               mediaThumbnails[index]['thumbnailBytes'],
//                               fit: BoxFit.fill,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexagon/hexagon.dart';
import 'package:poll_chat/components/octagon_shape.dart';
import 'package:poll_chat/res/assets/icon_assets.dart';
import 'package:poll_chat/res/assets/image_assets.dart';
import 'package:poll_chat/res/colors/app_color.dart';
import 'package:poll_chat/res/routes/routes_name.dart';
import 'package:poll_chat/view/home/components/top_list/selfstatus.dart';
import 'package:poll_chat/view/home/components/top_list/viewstatus.dart';
import 'package:poll_chat/view_models/controller/home_model.dart';
import 'package:poll_chat/view_models/controller/user_preference_view_model.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:http/http.dart' as http;
import 'package:story_view/widgets/story_view.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class TopList extends StatefulWidget {
  const TopList({Key? key}) : super(key: key);

  @override
  State<TopList> createState() => _TopListState();
}

class _TopListState extends State<TopList> {
  final controller = StoryController();
  List<StoryItem> storyItems = [];
  UserPreference userPreference = UserPreference();
  List<Map<String, dynamic>> mediaThumbnails = [];
  List<Map<String, dynamic>> storyThumbnails = [];
  List<Map<String, dynamic>> moments = [];
  List<Map<String, dynamic>> storymoments = [];
  final homeViewController = Get.put(HomeViewModelController());
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getProfile();
    fetchUserStory();

    fetchData().then((value) {
      setState(() {});
    });
  }

  Widget _buildProfileAvatar() {
    String? profilePhotoUrl =
        homeViewController.singleUser["profilePhoto"]?.toString().trim() ?? "";

    if (profilePhotoUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CachedNetworkImage(
                          imageUrl: profilePhotoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        homeViewController.singleUser["name"] ?? "",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: CachedNetworkImage(
          imageUrl: profilePhotoUrl,
          fit: BoxFit.cover,
          width: 80,
          height: 80,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('assets/images/logo.png'),
      );
    }
  }

  Future<void> getProfile() async {
    String? id = await userPreference.getUserID();
    log("ID here: $id");
    await homeViewController.getSingleUser(id!);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchUserStory() async {
    try {
      String? authToken = await userPreference.getAuthToken();
      String? userid = await userPreference.getUserID();
      var headers = {'Authorization': 'Bearer $authToken'};
      var url =
          'https://pollchat.myappsdevelopment.co.in/api/v1/moment/$userid';
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List<dynamic> storymoments = jsonResponse['moments'];
        print('Fetched ${storymoments.length} moments.');

        for (var moment in storymoments) {
          print(moment['momentmedia']);
          String? action = moment['momentmedia'];

          Uint8List? thumbnailBytes;
          if (action!.endsWith('.jpg') ||
              action.endsWith('.jpeg') ||
              action.endsWith('.png')) {
            thumbnailBytes = await fetchImageThumbnail(action);
          } else {
            thumbnailBytes = await generateThumbnail(action);
          }

          if (thumbnailBytes != null) {
            setState(() {
              storyThumbnails.add({
                'thumbnailBytes': thumbnailBytes,
                'momentmedia': action,
              });
            });
          }
          // storyThumbnails.insert(
          //   0,
          //   {
          //     'thumbnailBytes': mediaThumbnails[0]["thumbnailBytes"],
          //     'momentmedia': mediaThumbnails[0]["momentmedia"],
          //   },
          // );
        }

        setState(() {});
      } else {
        print('Request failed with status: ${response.statusCode}');
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error fetching user story: $e');
    }
  }

  Future<void> fetchData() async {
    String? authToken = await userPreference.getAuthToken();
    var headers = {'Authorization': 'Bearer $authToken'};

    try {
      var response = await http.get(
        Uri.parse(
            'https://pollchat.myappsdevelopment.co.in/api/v1/moment/friends'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true) {
          List<dynamic>? friendMoments = jsonResponse['friendMoments'];

          if (friendMoments != null) {
            for (var friendMoment in friendMoments) {
              List<dynamic>? moments = friendMoment['moments'];
              if (moments != null && moments.isNotEmpty) {
                for (var moment in moments) {
                  String? momentMediaUrl = moment['momentmedia'];
                  if (momentMediaUrl != null) {
                    Uint8List? thumbnailBytes;

                    if (momentMediaUrl.endsWith('.jpg') ||
                        momentMediaUrl.endsWith('.jpeg') ||
                        momentMediaUrl.endsWith('.png')) {
                      thumbnailBytes =
                          await fetchImageThumbnail(momentMediaUrl);
                    } else {
                      thumbnailBytes = await generateThumbnail(momentMediaUrl);
                    }

                    if (thumbnailBytes != null) {
                      mediaThumbnails.add({
                        'friendId': moment['userId'],
                        'thumbnailBytes': thumbnailBytes,
                        'momentmedia': momentMediaUrl,
                        'isVideo': !momentMediaUrl.endsWith('.jpg') &&
                            !momentMediaUrl.endsWith('.jpeg') &&
                            !momentMediaUrl.endsWith('.png'),
                      });

                      setState(() {});
                    }
                  }
                }
              }
            }
          } else {
            print('Friend moments data is null');
          }
        } else {
          print('Failed to fetch moments: ${jsonResponse['message']}');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      print('Generating thumbnail for: $videoUrl');
      final uint8List = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 75,
      );
      print('Thumbnail generated successfully');
      return uint8List;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<Uint8List?> fetchImageThumbnail(String imageUrl) async {
    try {
      print('Fetching image thumbnail for: $imageUrl');
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to fetch image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching image thumbnail: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width * 0.3;
    return Row(
      children: [
        SizedBox(
          height: 88,
          width: 90,
          child: storyThumbnails.isEmpty
              ? Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      HexagonWidget.pointy(
                        width: itemWidth,
                        color: AppColor.purpleColor,
                        cornerRadius: 20,
                        elevation: 2,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(RouteName.createstory);
                          },
                          child: Image.network(
                            homeViewController.singleUser["profilePhoto"]
                                    ?.toString()
                                    .trim() ??
                                "",
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 60,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.purple,
                              width: 2,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteName.createstory);
                            },
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: storyThumbnails.length,
                  itemBuilder: (BuildContext context, int index1) {
                    return Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      width: itemWidth,
                      height: 90,
                      child: Stack(
                        children: [
                          HexagonWidget.pointy(
                            width: itemWidth,
                            color: AppColor.purpleColor,
                            cornerRadius: 20,
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelfStatusView(
                                      [storyThumbnails[index1]],
                                    ),
                                  ),
                                );
                              },
                              child: Image.memory(
                                storyThumbnails[index1]['thumbnailBytes'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            left: 50,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(RouteName.createstory);
                                },
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Expanded(
            child: SizedBox(
          height: 90,
          child: mediaThumbnails.isEmpty
              ? Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 50,
                    width: 50,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mediaThumbnails.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: itemWidth,
                      height: 90,
                      child: HexagonWidget.pointy(
                        width: itemWidth,
                        color: AppColor.purpleColor,
                        cornerRadius: 20,
                        elevation: 2,

                        // borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatusView(
                                  mediaThumbnails,
                                ),
                              ),
                            );
                          },
                          child: Image.memory(
                            mediaThumbnails[index]['thumbnailBytes'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        )),
      ],
    );
  }
}
