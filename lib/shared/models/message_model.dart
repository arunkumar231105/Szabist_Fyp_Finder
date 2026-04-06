class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.isRead,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isRead;
}
