import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../shared/models/idea_model.dart';
import '../../../shared/providers/idea_provider.dart';
import '../../../shared/providers/request_provider.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';

class IdeaDetailScreen extends ConsumerWidget {
  const IdeaDetailScreen({
    required this.ideaId,
    super.key,
  });

  final String ideaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<IdeaModel> ideas = ref.watch(ideaProvider);
    final RequestsState requestsState = ref.watch(requestsProvider);
    final IdeaModel idea = ideas.firstWhere(
      (IdeaModel item) => item.id == ideaId,
      orElse: () => ideas.first,
    );

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: GradientAppBar(
        title: idea.title.length > 24
            ? '${idea.title.substring(0, 24)}...'
            : idea.title,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push('/profile/${idea.ownerId}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Center(
                        child: Text(
                          _initials(idea.ownerName),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
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
                          Text(
                            idea.ownerName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            idea.ownerDept,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              idea.title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              idea.description,
              style: GoogleFonts.poppins(
                fontSize: 15,
                height: 1.6,
                color: AppColors.dark.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            const _SectionLabel(text: 'Technologies Required'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: idea.technologiesRequired
                  .map(
                    (String technology) => _SoftChip(
                      label: technology,
                      backgroundColor: const Color(0xFFCFFAFE),
                      textColor: const Color(0xFF0F766E),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            const _SectionLabel(text: 'Skills Required'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: idea.skillsRequired
                  .map(
                    (String skill) => _SoftChip(
                      label: skill,
                      backgroundColor: AppColors.lightPurple,
                      textColor: AppColors.primary,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Posted: ${_formatDate(idea.createdAt)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: 'Apply to this Idea \u{1F91D}',
              onPressed: () {
                if (!requestsState.canCreateNewRequest) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You already have a pending or accepted partner request.',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Request sent to owner!',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'NA';
    }
    return parts.length == 1
        ? parts.first[0].toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _formatDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
