import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class addVideoScreen extends StatelessWidget {
  const addVideoScreen({Key? key}) : super(key: key);
  videoPick(ImageSource src , BuildContext context) async{
    final video  = await ImagePicker().pickVideo(source: src);
    if(video != null){
      Get.snackbar("Video Selected", video.path);
      //Navigator.push(context, MaterialPageRoute(builder: (context)=> addCaption_Screen(videoFile: File(video.path), videoPath: video.path)));

    }else{
      Get.snackbar("Error In Selecting Video", "Please Choose A Different Video File");
    }
  }
  showDialogOpt(BuildContext context){
    return showDialog(context: context, builder: (context)=>
        SimpleDialog(
          children: [
            SimpleDialogOption(
              onPressed: ()=>videoPick(ImageSource.gallery , context),
              child: const Text("Gallery"),
            ),
            SimpleDialogOption(
              onPressed: ()=>videoPick(ImageSource.camera , context),
              child: const Text("Camera"),
            ),
            SimpleDialogOption(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Close"),
            )
          ],
        ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () => showDialogOpt(context),
          child: Container(
            width: 190,
            height: 50,
            decoration: const BoxDecoration(
                color: Colors.black
            ),
            child: const Center(
              child: Text("Add Video" , style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
            ),
          ),
        ),
      ),
    );
  }
}