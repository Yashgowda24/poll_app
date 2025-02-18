import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/comment_controller_view_model.dart';
class CommentScreen extends StatelessWidget {
  final String id;
  CommentScreen({
    required this.id}
      );
  final TextEditingController _commentController  = TextEditingController();

  CommentController commentController = Get.put(CommentController());


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body : SingleChildScrollView(
            child : SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      return ListView.builder(shrinkWrap: true,itemCount: 5,itemBuilder: (context , index){
                        // final comment  = commentController.comments[index];
                        return ListTile(
                          leading : CircleAvatar(
                            //backgroundImage: NetworkImage(comment.profilePic),
                          ),
                          title: Row(
                            children: [
                              /*Text(comment.username , style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent
                              ),),*/
                              SizedBox(
                                width: 5,
                              ),
                              /*Text(comment.comment,  style: TextStyle(
                                fontSize: 13,

                              ),)*/
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              /*Text(tago.format(comment.datePub.toDate()) , style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold
                              ),
                              ),*/
                              SizedBox(width: 5,),
                              /*Text("${comment.likes.length} Likes" , style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold
                              ), )*/
                            ],
                          ),
                          trailing: InkWell(
                              onTap: (){
                                //commentController.likeComment(comment.id);
                              },
                              child: Text("Hello"),
                              /*Icon(
                                  Icons.favorite ,
                                  color : comment.likes.contains(FirebaseAuth.instance.currentUser!.uid) ? Colors.red : Colors.white)*/
                          ),
                        );
                      });
                    }
                    ),
                  ),
                  Divider(),
                  /*ListTile(
                    title : TextInputField(controller: _commentController, myIcon: Icons.comment, myLabelText: "Comment"),
                    trailing: TextButton(
                      onPressed: (){
                        commentController.postComment(_commentController.text);
                      },
                      child: Text("Send"),
                    ),
                  )*/
                ],
              ),
            )
        )
    );
  }
}