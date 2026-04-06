import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_thread_model.dart';
import '../models/message_model.dart';
import '../models/student_model.dart';

class ChatNotifier extends StateNotifier<List<ChatThreadModel>> {
  ChatNotifier() : super(ChatThreadModel.dummyThreads());

  String ensureChat(StudentModel student) {
    final ChatThreadModel? existing = _findByPartnerId(student.id);
    if (existing != null) {
      return existing.chatId;
    }

    final String chatId = 'chat_${student.id}';
    state = <ChatThreadModel>[
      ChatThreadModel(
        chatId: chatId,
        partnerId: student.id,
        partnerName: student.name,
        messages: <MessageModel>[],
        unreadCount: 0,
      ),
      ...state,
    ];
    return chatId;
  }

  void sendMessage(String chatId, String text, {String senderId = 'user_001'}) {
    state = state.map((ChatThreadModel thread) {
      if (thread.chatId != chatId) {
        return thread;
      }

      final List<MessageModel> messages = <MessageModel>[
        ...thread.messages,
        MessageModel(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: senderId,
          text: text,
          sentAt: DateTime.now(),
          isRead: true,
        ),
      ];

      return thread.copyWith(messages: messages, unreadCount: 0);
    }).toList()
      ..sort((ChatThreadModel a, ChatThreadModel b) {
        final DateTime aTime = a.lastSentAt ?? DateTime(2000);
        final DateTime bTime = b.lastSentAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
  }

  ChatThreadModel? findByChatId(String chatId) {
    try {
      return state.firstWhere((ChatThreadModel thread) => thread.chatId == chatId);
    } catch (_) {
      return null;
    }
  }

  ChatThreadModel? _findByPartnerId(String partnerId) {
    try {
      return state.firstWhere(
        (ChatThreadModel thread) => thread.partnerId == partnerId,
      );
    } catch (_) {
      return null;
    }
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatThreadModel>>((ref) {
  return ChatNotifier();
});
