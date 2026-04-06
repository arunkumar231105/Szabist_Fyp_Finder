import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../shared/models/chat_thread_model.dart';
import '../../../shared/models/message_model.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/widgets/gradient_app_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.chatId,
    super.key,
  });

  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const String _currentUserId = 'user_001';

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatThreadModel thread = ref.watch(chatProvider).firstWhere(
          (ChatThreadModel item) => item.chatId == widget.chatId,
          orElse: () => ChatThreadModel(
            chatId: widget.chatId,
            partnerId: 'unknown',
            partnerName: 'Chat',
            messages: const <MessageModel>[],
            unreadCount: 0,
          ),
        );
    final List<MessageModel> messages = thread.messages;

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: GradientAppBar(
        title: thread.partnerName,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final MessageModel message = messages[index];
                final bool isSent = message.senderId == _currentUserId;
                final bool showTimestamp = index == 0 ||
                    messages[index - 1].sentAt.minute != message.sentAt.minute ||
                    messages[index - 1].sentAt.hour != message.sentAt.hour;

                return Column(
                  children: <Widget>[
                    if (showTimestamp)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _formatTime(message.sentAt),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    Align(
                      alignment:
                          isSent ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSent ? AppColors.primaryGradient : null,
                            color: isSent ? null : AppColors.lightPurple,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isSent ? 20 : 4),
                              bottomRight: Radius.circular(isSent ? 4 : 20),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: GoogleFonts.poppins(
                              color: isSent ? Colors.white : AppColors.dark,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Material(
            elevation: 4,
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(
                            color: const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    ref.read(chatProvider.notifier).sendMessage(
          widget.chatId,
          text,
          senderId: _currentUserId,
        );
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  static String _formatTime(DateTime time) {
    final int hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final String minute = time.minute.toString().padLeft(2, '0');
    final String suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
