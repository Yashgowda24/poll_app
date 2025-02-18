import 'dart:convert';

ChatMessageModel chatMessageModelFromJson(String str) =>
    ChatMessageModel.fromJson(json.decode(str));

String chatMessageModelToJson(ChatMessageModel data) =>
    json.encode(data.toJson());

class ChatMessageModel {
  int? chatId;
  int? to;
  int? from;
  String? message;
  String? chatType;
  bool? toUserOnlineStatus;
  DateTime? time;
  String? imagePath; // New field to store the path of the image

  ChatMessageModel({
    this.chatId,
    this.to,
    this.from,
    this.message,
    this.chatType,
    this.toUserOnlineStatus,
    this.time,
    this.imagePath, // Initialize the new field in the constructor
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        chatId: json["chat_id"],
        to: json["to"],
        from: json["from"],
        message: json["message"],
        chatType: json["chat_type"],
        toUserOnlineStatus: json['to_user_online_status'],
        time: json['time'] != null ? DateTime.parse(json['time']) : null,
        imagePath: json['imagePath'], // Parse the image path from JSON
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "to": to,
        "from": from,
        "message": message,
        "chat_type": chatType,
        'time': time?.toIso8601String(),
        'imagePath': imagePath,
      };
}
