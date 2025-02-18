class Video{
  String username;
  String id;
  List likes;
  List dislikes;
  int commentsCount;
  int shareCount;
  String songName;
  String caption;
  String videoUrl;
  String thumbnail;
  String profilePic;


  Video.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        username = json['username'] as String,
        videoUrl  = json['videoUrl'] as String,
        thumbnail= json['thumbnail'] as String,
        commentsCount = json['city'] as int,
        shareCount = json['shareCount'] ?? "NA",
        songName = json['songName'] as String,
        caption = json['caption'] ?? "NA",
        likes = List<String>.from(json['hobbies'] as List),
        profilePic = json['profilePic'] ?? "NA",
        dislikes = List<String>.from(json['interests'] as List);

}