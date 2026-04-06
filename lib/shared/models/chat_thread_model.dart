import 'message_model.dart';

class ChatThreadModel {
  const ChatThreadModel({
    required this.chatId,
    required this.partnerId,
    required this.partnerName,
    required this.messages,
    required this.unreadCount,
  });

  final String chatId;
  final String partnerId;
  final String partnerName;
  final List<MessageModel> messages;
  final int unreadCount;

  String get lastMessage => messages.isEmpty ? 'Start chatting...' : messages.last.text;

  DateTime? get lastSentAt => messages.isEmpty ? null : messages.last.sentAt;

  ChatThreadModel copyWith({
    String? chatId,
    String? partnerId,
    String? partnerName,
    List<MessageModel>? messages,
    int? unreadCount,
  }) {
    return ChatThreadModel(
      chatId: chatId ?? this.chatId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  static List<ChatThreadModel> dummyThreads() {
    return <ChatThreadModel>[
      ChatThreadModel(
        chatId: 'chat_001',
        partnerId: 'user_002',
        partnerName: 'Ayesha Khan',
        unreadCount: 2,
        messages: <MessageModel>[
          MessageModel(
            id: 'msg_001',
            senderId: 'user_002',
            text: 'I sketched two flow ideas for the app. Want to review them tonight?',
            sentAt: DateTime(2026, 4, 6, 22, 42),
            isRead: false,
          ),
        ],
      ),
      ChatThreadModel(
        chatId: 'chat_002',
        partnerId: 'user_004',
        partnerName: 'Maham Raza',
        unreadCount: 0,
        messages: <MessageModel>[
          MessageModel(
            id: 'msg_002',
            senderId: 'user_004',
            text: 'The model training is done. Next step is plugging results into the UI.',
            sentAt: DateTime(2026, 4, 6, 20, 15),
            isRead: true,
          ),
        ],
      ),
    ];
  }
}
