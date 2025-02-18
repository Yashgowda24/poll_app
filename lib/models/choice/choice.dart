

class Choice {
  String? title;
  int count = 0;

  Choice.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    count = json["count"];
  }
}