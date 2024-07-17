class MessageModel {
  final String message;
  final String sender;
  final String receiver;
  final String? messageID;
  final DateTime timestamp;
  final bool isSeen;
  final bool? isImage;

  MessageModel({
    required this.message,
    required this.sender,
    required this.receiver,
    this.messageID,
    required this.timestamp,
    required this.isSeen,
    this.isImage,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      message: map["message"],
      sender: map["senderId"],
      receiver: map["receiverId"],
      timestamp: DateTime.parse(map["timestamp"]),
      isSeen: map["isSeenbyReceiver"],
      isImage: map["isImage"] ?? false,
      messageID: map["\$id"],  // Ensure this key is correct
    );
  }
}
