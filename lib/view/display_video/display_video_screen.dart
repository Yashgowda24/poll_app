import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/video_controller_view_model.dart';

class DisplayVideo_Screen extends StatelessWidget {
  DisplayVideo_Screen({Key? key}) : super(key: key);

  final VideoController videoController = Get.put(VideoController());

  /*Future<void> share(String vidId) async {
    await FlutterShare.share(
      title: 'Download My TikTok Clone App',
      text: 'Watch Intresting short videos On TikTok Clone',
    );
    videoController.shareVideo(vidId);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            itemCount: videoController.videoList.length,
            itemBuilder: (context, index) {
              final data = videoController.videoList[index];
              return InkWell(
                onDoubleTap: () {
                  //ideoController.likedVideo(data.id);
                },
                child: Stack(
                  children: [
                    /*TikTokVideoPlayer(
                      videoUrl: data.videoUrl,
                    ),*/
                    Container(
                      margin: EdgeInsets.only(bottom: 10, left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.username,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                          Text(
                            data.caption,
                          ),
                          Text(
                            data.songName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        height: MediaQuery.of(context).size.height - 400,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3,
                            right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                                onTap: () {
                                  //Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: data.uid,)));
                                },
                                child: Text(
                                    "Hello") /*ProfileButton(
                                profilePhotoUrl: data.profilePic,
                              ),*/
                                ),
                            InkWell(
                              onTap: () {
                                //videoController.likedVideo(data.id);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    data.likes.length.toString(),
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                //share(data.id);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.reply,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    data.shareCount.toString(),
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                //Navigator.push(context, MaterialPageRoute(builder: (context)=>CommentScreen(id : data.id)));
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.comment,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    data.commentsCount.toString(),
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    children: [
                                      //AlbumRotator(profilePicUrl: data.profilePic)
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
      }),
    );
  }
}
