// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:poll_chat/res/assets/icon_assets.dart';
// import 'package:poll_chat/res/routes/routes_name.dart';
// import 'package:poll_chat/view_models/controller/music_view_model.dart';

// class MusicScreen extends StatefulWidget {
//   const MusicScreen({super.key});

//   @override
//   State<MusicScreen> createState() => _MusicScreenState();
// }

// class _MusicScreenState extends State<MusicScreen> {
//   final musicModelController = Get.put(MusicViewModel());
//   final player = AudioPlayer();

//   PlayerState playerState = PlayerState.stopped;
//   List musiclist = [
//     "StaySolidRocky",
//     "Giveon",
//     "The Weeknd",
//     "Demi Lovato, Sam..."
//   ];
//   // List subtitlelist = ["party", "Heartbreak Anniversary","Blinding Lights","What Other People Say"];
//   List musicimg = [
//     "assets/images/music1.png",
//     "assets/images/music2.png",
//     "assets/images/music3.png",
//     "assets/images/music4.png"
//   ];

//   TextEditingController _searchController = TextEditingController();

//   callIn() {
//     // musicModelController.getallMusic();

//     player.onPlayerStateChanged.listen((PlayerState s) {
//       setState(() {
//         playerState = s;
//       });
//     });
//   }

//   @override
//   void initState() {
//     callIn();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var musicModel = musicModelController.allMusic;
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Music",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(
//           color: Colors.black,
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.all(20),
//               child: TextField(
//                 onChanged: (val) {
//                   setState(() {
//                     _searchController.text = val;
//                   });
//                 },
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   prefixIcon: const Icon(Icons.search),
//                   hintText: 'Search',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(32.0),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 12.0),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             const Divider(
//               color: Colors.grey,
//               thickness: 1,
//             ),
//             Container(
//               height: 500,
//               child: ListView.builder(
//                 itemCount: musicModelController.allMusic.length,
//                 itemBuilder: (context, index) {
//                   print(_searchController.text);
//                   return musicModelController.allMusic[index]["musicName"]
//                           .toString()
//                           .toLowerCase()
//                           .contains(_searchController.text.toLowerCase())
//                       ? GestureDetector(
//                           onTap: () {
//                             if (playerState != PlayerState.playing) {
//                               print("Current Music: " +
//                                   musicModelController.allMusic[index]
//                                       ["music"]);
//                               setState(() {
//                                 _play(musicModelController.allMusic[index]
//                                         ["music"]
//                                     .toString()
//                                     .trim());
//                               });
//                             }
//                             if (playerState == PlayerState.playing) {
//                               _pause();
//                             }

//                             print(musicModelController.allMusic[index]["_id"]);
//                             // Get.toNamed(RouteName.camera);
//                           },
//                           child: ListTile(
//                             title: Text(
//                               musicModelController.allMusic[index]["musicName"],
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             subtitle: Text(
//                                 musicModelController.allMusic[index]["singer"]),
//                             leading:
//                                 Image.asset(musicimg[index % musiclist.length]),
//                             trailing: Container(
//                               alignment: Alignment.center,
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                     color: const Color(0xFF781069), width: 2),
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: IconButton(
//                                 icon: const Icon(
//                                   Icons.add,
//                                   size: 20,
//                                   color: Color(0xFF781069),
//                                 ),
//                                 onPressed: () {
//                                   musicModelController.musicId.value =
//                                       musicModelController.allMusic[index]
//                                           ["_id"];
//                                   Get.toNamed(RouteName.camera, arguments: {
//                                     "musicId": musicModelController
//                                         .allMusic[index]["_id"],
//                                     "music": musicModelController
//                                         .allMusic[index]["music"]
//                                   });
//                                   // await player.play(UrlSource(musicModelController.allMusic[index]["music"]));
//                                   // Perform your action here when the plus icon is pressed
//                                 },
//                               ),
//                             ),
//                           ),
//                         )
//                       : Container();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _play(var audioUrl) async {
//     await player.play(UrlSource(audioUrl));
//   }

//   void _pause() async {
//     await player.pause();
//   }

//   void _stop() async {
//     await player.stop();
//   }
// }
// /*

// class AudioPlayerWidget extends StatefulWidget {
//   final String audioUrl;

//   const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

//   @override
//   _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
// }

// class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
//   late AudioPlayer audioPlayer;
//   AudioPlayerState audioPlayerState = AudioPlayerState.STOPPED;

//   @override
//   void initState() {
//     super.initState();
//     audioPlayer = AudioPlayer();
//     audioPlayer.onPlayerStateChanged.listen((state) {
//       setState(() {
//         audioPlayerState = state;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }

//   void _play() async {
//     await audioPlayer.play(widget.audioUrl);
//   }

//   void _pause() async {
//     await audioPlayer.pause();
//   }

//   void _stop() async {
//     await audioPlayer.stop();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(Icons.play_arrow),
//           onPressed: () {
//             if (audioPlayerState != AudioPlayerState.PLAYING) {
//               _play();
//             }
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.pause),
//           onPressed: () {
//             if (audioPlayerState == AudioPlayerState.PLAYING) {
//               _pause();
//             }
//           },
//         ),
//         IconButton(
//           icon: Icon(Icons.stop),
//           onPressed: _stop,
//         ),
//       ],
//     );
//   }
// }
// */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poll_chat/view_models/controller/music_view_model.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final musicModelController = Get.put(MusicViewModel());
  //final player = AudioPlayer();

  // PlayerState playerState = PlayerState.stopped;
  List musiclist = [
    "StaySolidRocky",
    "Giveon",
    "The Weeknd",
    "Demi Lovato, Sam..."
  ];
  List musicimg = [
    "assets/images/music1.png",
    "assets/images/music2.png",
    "assets/images/music3.png",
    "assets/images/music4.png"
  ];

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Music",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: FutureBuilder(
        future: musicModelController.getallMusic(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching music data'),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchController.text = val;
                        });
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Container(
                    height: 500,
                    child: ListView.builder(
                      itemCount: musicModelController.allMusic.length,
                      itemBuilder: (context, index) {
                        if (musicModelController.allMusic[index]["musicName"]
                            .toString()
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase())) {
                          return GestureDetector(
                            onTap: () {
                              // Your onTap logic here
                            },
                            child: ListTile(
                              title: Text(
                                musicModelController.allMusic[index]
                                    ["musicName"],
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(musicModelController
                                  .allMusic[index]["singer"]),
                              leading: Image.asset(
                                  musicimg[index % musiclist.length]),
                              trailing: Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF781069), width: 2),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Color(0xFF781069),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, {
                                      "musicId": musicModelController
                                          .allMusic[index]["_id"],
                                      "music": musicModelController
                                          .allMusic[index]["music"]
                                    });

                                    // musicModelController.musicId.value =
                                    //     musicModelController.allMusic[index]
                                    //         ["_id"];
                                    // Get.toNamed(RouteName.camera, arguments: {
                                    //   "musicId": musicModelController
                                    //       .allMusic[index]["_id"],
                                    //   "music": musicModelController
                                    //       .allMusic[index]["music"]
                                    // });
                                  },
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
           
           
            );
          }
        },
      ),
    );
  }
}
