// // ignore_for_file: avoid_print

// import 'package:get/get.dart';
// import '../../data/repository/profile_repository.dart';
// import '../../utils/utils.dart';

// class MusicViewModel extends GetxController {
//   final _api = ProfileRepository();
//   final RxList<dynamic> allMusic = <dynamic>[].obs;
//   Rx<String> musicId = ''.obs;

//   Future<void> getallMusic() async {
//     try {
//       var value = await _api.getallMusicApi();
//       if (value["message"] != null) {
//         print("Music-- ${value["message"]}");
//         allMusic.value = value["musics"] ?? "";
//       } else {
//         Utils.snackBar("Error", "Failed to fetch music data");
//       }
//     } catch (e) {
//       Utils.snackBar("Error", e.toString());
//     }
//   }
// }

import 'package:get/get.dart';
import '../../data/repository/profile_repository.dart';
import '../../utils/utils.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicViewModel extends GetxController {
  final _api = ProfileRepository();
  final RxList<dynamic> allMusic = <dynamic>[].obs;
  Rx<String> musicId = ''.obs;
  AudioPlayer player = AudioPlayer();

  Future<void> getallMusic() async {
    try {
      var value = await _api.getallMusicApi();
      if (value["message"] != null) {
        print("Music-- ${value["message"]}");
        allMusic.value = value["musics"] ?? [];
      } else {
        Utils.snackBar("Error", "Failed to fetch music data");
      }
    } catch (e) {
      Utils.snackBar("Error", e.toString());
    }
  }

  Future<void> playMusic(var audioUrl) async {
    await player.play(UrlSource(audioUrl));
  }

  Future<void> pause() async {
    await player.pause();
  }
}
