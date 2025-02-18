import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../../data/repository/profile_repository.dart';
import '../../utils/utils.dart';

class CameraViewModel extends GetxController {
  final _api = ProfileRepository();
  final Rx<XFile> videoFile = XFile('').obs;
  final RxString imgFile = ''.obs;
  RxBool loading = false.obs;

  //final Rx<XFile> videoFile = Rx<XFile>(XFile(''));
  final Rx<String> musicId = ''.obs;
  addPostDetails(XFile vF, String mId) {
    videoFile.value = vF;
    musicId.value = mId;
    loading.value = true;
  }

  addPostDetailsImage(RxString iF, String mId) {
    imgFile.value = iF.string;
    musicId.value = mId;
  }

  // Future<void> createPost(String pathdata) async {
  //   print("vF-- ${videoFile.value} \n ");
  //   try {
  //     Map<String, dynamic> data = {
  //       'actionType': 'everyone',
  //       'action': pathdata.isEmpty ? videoFile.value.path : pathdata,
  //       // 'musicId': musicId.isEmpty ? musicId.value : '',

  //       'actionCaption': 'Reading the Introduction '
  //     };
  //     if (musicId.value.isNotEmpty) {
  //       data['musicId'] = musicId.value;
  //     }
  //     _api.postCreatePost(data).then((value) {
  //       print("Create Post-- ${value}");
  //     });
  //   } on Exception catch (e) {
  //     Utils.snackBar("Error", e.toString());
  //   }
  // }

  // Future<void> createPost(String pathdata) async {
  //   print("vF-- ${videoFile.value} \n ");
  //   try {
  //     Map<String, dynamic> data = {
  //       'actionType': 'everyone',
  //       'action': pathdata.isEmpty ? videoFile.value.path : pathdata,
  //       'actionCaption': 'Reading the Introduction'
  //     };

  //     if (musicId.value.isNotEmpty) {
  //       data['musicId'] = musicId.value;
  //     }

  //     _api.postCreatePost(data).then((value) {
  //       print("Create Post-- $value");
  //     });
  //   } on Exception catch (e) {
  //     Utils.snackBar("Error", e.toString());
  //   }
  // }
  Future<void> createPost(String pathdata) async {
    print("vF-- ${videoFile.value} \n ");
    loading.value = true; // Start loading

    try {
      Map<String, dynamic> data = {
        'actionType': 'everyone',
        'action': pathdata.isEmpty ? videoFile.value.path : pathdata,
        'actionCaption': 'Reading the Introduction'
      };

      if (musicId.value.isNotEmpty) {
        data['musicId'] = musicId.value;
      }

      await _api.postCreatePost(data).then((value) {
        print("Create Post-- $value");
      });
    } on Exception catch (e) {
      Utils.snackBar("Error", e.toString());
    } finally {
      loading.value = false; // Stop loading
    }
  }
}
