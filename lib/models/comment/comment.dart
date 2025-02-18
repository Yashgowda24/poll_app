class Comment{

  String username;
  String comment;
  final datePub;
  List likes;
  String profilePic;
  String id;


  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        username = json['username'] as String,
        datePub  = json['datePub'] as String,
        comment = json['comment'] as String,
        likes = List<String>.from(json['hobbies'] as List),
        profilePic = json['profilePic'] ?? "NA";

}