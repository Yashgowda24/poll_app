class Poll {
  final String id;
  final String userId;
  final String pollType;
  final String question;
  final String? optionA;
  final int? countA;
  final String? optionB;
  final int? countB;
  final String? optionC;
  final int? countC;
  final String? optionD;
  final int? countD;
  final String pollPhoto;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pin;

  Poll({
    required this.id,
    required this.userId,
    required this.pollType,
    required this.question,
    this.optionA,
    this.countA,
    this.optionB,
    this.countB,
    this.optionC,
    this.countC,
    this.optionD,
    this.countD,
    required this.pollPhoto,
    required this.likeCount,
    required this.dislikeCount,
    required this.commentCount,
    required this.shareCount,
    required this.createdAt,
    required this.updatedAt,
    required this.pin,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      pollType: json['pollType'] ?? '',
      question: json['question'] ?? '',
      optionA: json['optionA'],
      countA: json['countA'],
      optionB: json['optionB'],
      countB: json['countB'],
      optionC: json['optionC'],
      countC: json['countC'],
      optionD: json['optionD'],
      countD: json['countD'],
      pollPhoto: json['pollPhoto'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      dislikeCount: json['dislikeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      pin: json['pin'] ?? false,
    );
  }
}
