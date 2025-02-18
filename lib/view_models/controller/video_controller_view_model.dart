import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../models/video/video.dart';

class VideoController extends GetxController{
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);
  List<Video> get videoList => _videoList.value;


 /* shareVideo(String vidId) async{
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("videos").doc(vidId).get();

    int newShareCount  =  (doc.data() as dynamic)["shareCount"] + 1;
    await FirebaseFirestore.instance.collection("videos").doc(vidId).update(
        {
          "shareCount" : newShareCount
        });
  }
  likedVideo(String id) async{

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("videos").doc(id).get();
    var uid = AuthController.instance.user.uid;
    if((doc.data() as dynamic)['likes'].contains(uid)){
      await FirebaseFirestore.instance.collection("videos").doc(id).update({
        'likes' : FieldValue.arrayRemove([uid]),
      });
    }else{
      await FirebaseFirestore.instance.collection("videos").doc(id).update(
          {
            'likes' : FieldValue.arrayUnion([uid]),
          });
    }
  }*/
}