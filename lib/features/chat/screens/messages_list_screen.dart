import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/string_utils.dart';
import '../../../shared/models/chat_thread_model.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/gradient_app_bar.dart';

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({
    this.showAppBar = true,
    super.key,
  });

  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ChatThreadModel> chats = ref.watch(chatProvider);

    final Widget body = Padding(
      padding: const EdgeInsets.all(16),
      child: chats.isEmpty
          ? const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No messages yet \u{1F4AC}',
              message: 'Start a conversation once you find your teammate.',
            )
          : ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final ChatThreadModel chat = chats[index];
                return _ChatItem(chat: chat);
              },
            ),
    );

    if (!showAppBar) {
      return ColoredBox(color: AppColors.grey, child: body);
    }

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: const GradientAppBar(title: 'Messages \u{1F4AC}'),
      body: body,
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem({required this.chat});

  final ChatThreadModel chat;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/chat/${chat.chatId}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Text(
                    getInitials(chat.partnerName),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            chat.partnerName,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                        Text(
                          formatTime(chat.lastSentAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (chat.unreadCount > 0) ...<Widget>[
                const SizedBox(width: 12),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${chat.unreadCount}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

