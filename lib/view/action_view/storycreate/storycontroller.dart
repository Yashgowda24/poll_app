// import 'package:camera/camera.dart';
// import 'package:get/get.dart';
// import 'package:poll_chat/data/repository/profile_repository.dart';
// import 'package:poll_chat/utils/utils.dart';

// class StoryViewModel extends GetxController {
//   final _api = ProfileRepository();
//   final Rx<XFile> videoFile = XFile('').obs;

//   final Rx<String> musicId = ''.obs;

//   addPostStoryDetails(XFile vF, String mId) {
//     videoFile.value = vF;
//     musicId.value = mId;
//   }

// ignore_for_file: avoid_print

//   Future<void> createStoryPost(String pathdata) async {
//     print("vF-- ${videoFile.value} \n ");
//     try {
//       Map<String, dynamic> data = {
//         'momentType': 'everyone',
//         'momentText': 'this is the sample text',
//         'momentmedia': pathdata.isEmpty ? videoFile.value.path : pathdata,
//         'musicId': musicId.value.isEmpty ? '' : musicId.value
//       };
//       _api.postStoryPost(data).then((value) {
//         print("Create Post-- ${value}");
//       });
//     } on Exception catch (e) {
//       Utils.snackBar("Error", e.toString());
//     }
//   }
// }
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:poll_chat/data/repository/profile_repository.dart';
import 'package:poll_chat/utils/utils.dart';

class StoryViewModel extends GetxController {
  final _api = ProfileRepository();
  final Rx<XFile> videoFile = XFile('').obs;
  RxBool loading = false.obs;
  final Rx<String> musicId = ''.obs;

  void addPostStoryDetails(
    XFile vF,
  ) {
    videoFile.value = vF;
    //musicId.value = mId;
  }

  void addPostchate(
    XFile vF,
  ) {
    videoFile.value = vF;
    //musicId.value = mId;
    loading.value = true;
  }

  Future<void> createStoryPost(String pathdata) async {
  print("vF-- ${videoFile.value} \n ");
  loading.value = true; // Set loading to true
  try {
    Map<String, dynamic> data = {
      'momentType': 'everyone',
      'momentText': 'this is the sample text',
      'momentmedia': pathdata.isEmpty ? videoFile.value.path : pathdata,
    };

    if (musicId.value.isNotEmpty) {
      data['musicId'] = musicId.value;
    }

    await _api.postStoryPost(data).then((value) {
      print("Create Post-- ${value}");
    });
  } on Exception catch (e) {
    Utils.snackBar("Error", e.toString());
  } finally {
    loading.value = false; // Stop loading
  }
}

}
