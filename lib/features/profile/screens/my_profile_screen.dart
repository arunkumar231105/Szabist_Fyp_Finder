import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/colors.dart';
import '../../../core/router.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/profile_provider.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudentModel student = ref.watch(profileProvider);
    final String initials = _buildInitials(student.name);

    return Scaffold(
      backgroundColor: AppColors.grey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: <Widget>[
              IconButton(
                onPressed: () => context.push('/edit-profile'),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _confirmLogout(context, ref),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF9F67FF),
                                Color(0xFFFF6CAB),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          student.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            _InfoChip(
                              label: student.department,
                              backgroundColor: Colors.white,
                              textColor: AppColors.primary,
                            ),
                            _InfoChip(
                              label: student.batch,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.16,
                              ),
                              textColor: Colors.white,
                              borderColor: Colors.white.withValues(alpha: 0.22),
                            ),
                            _InfoChip(
                              label: student.isProfilePublic
                                  ? 'Public'
                                  : 'Private',
                              backgroundColor: student.isProfilePublic
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : const Color(0xFFFFE4E6),
                              textColor: student.isProfilePublic
                                  ? Colors.white
                                  : AppColors.error,
                              borderColor: student.isProfilePublic
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _CompletionCard(
                        completionPercentage: student.completionPercentage,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: student.isProfilePublic
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              student.isProfilePublic
                                  ? Icons.public_rounded
                                  : Icons.lock_rounded,
                              color: student.isProfilePublic
                                  ? const Color(0xFF059669)
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                student.isProfilePublic
                                    ? 'Your profile is public. Other students can discover you and send requests.'
                                    : 'Your profile is private. You are hidden from Discover and cannot send partner requests.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((student.bio ?? '').trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 20),
                        const _SectionTitle(title: 'About Me'),
                        const SizedBox(height: 10),
                        Text(
                          student.bio!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.dark.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _LinedSectionHeader(title: 'Skills \u26a1'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: student.skills
                            .map((String skill) => _GradientChip(label: skill))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const _LinedSectionHeader(
                        title: 'Technologies \u{1F6E0}\uFE0F',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: student.technologies
                            .map(
                              (String technology) => _SoftChip(
                                label: technology,
                                backgroundColor: const Color(0xFFCFFAFE),
                                textColor: const Color(0xFF0F766E),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const _LinedSectionHeader(title: 'Interests \u{1F3AF}'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: student.interests
                            .map(
                              (String interest) => _SoftChip(
                                label: interest,
                                backgroundColor: const Color(0xFFFCE7F3),
                                textColor: const Color(0xFFDB2777),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const _LinedSectionHeader(title: 'Links \u{1F517}'),
                      const SizedBox(height: 10),
                      if ((student.githubUrl ?? '').trim().isNotEmpty)
                        _LinkTile(
                          icon: Icons.code_rounded,
                          title: 'GitHub',
                          subtitle: student.githubUrl ?? '',
                          onTap: () => _launchLink(student.githubUrl),
                        ),
                      if ((student.linkedinUrl ?? '').trim().isNotEmpty)
                        _LinkTile(
                          icon: Icons.business_center_outlined,
                          title: 'LinkedIn',
                          subtitle: student.linkedinUrl ?? '',
                          onTap: () => _launchLink(student.linkedinUrl),
                        ),
                      if ((student.portfolioLink ?? '').trim().isNotEmpty)
                        _LinkTile(
                          icon: Icons.web_asset_rounded,
                          title: 'Portfolio',
                          subtitle: student.portfolioLink ?? '',
                          onTap: () => _launchLink(student.portfolioLink),
                        ),
                      if ((student.resumeLink ?? '').trim().isNotEmpty)
                        _ResumeTile(
                          onTap: () => _launchLink(student.resumeLink),
                        ),
                      if ((student.githubUrl ?? '').trim().isEmpty &&
                          (student.linkedinUrl ?? '').trim().isEmpty &&
                          (student.portfolioLink ?? '').trim().isEmpty &&
                          (student.resumeLink ?? '').trim().isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No links added yet',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmLogout(context, ref),
                          icon: const Icon(Icons.logout_rounded),
                          label: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _buildInitials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'NA';
    }
    return parts.length == 1
        ? parts.first.substring(0, 1).toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static Future<void> _launchLink(String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  static Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Logout?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'You will be taken back to the login page.',
            style: GoogleFonts.poppins(height: 1.5),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    ref.read(mockAuthProvider.notifier).state = false;
    context.go('/login');
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.completionPercentage});

  final int completionPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profile Completion',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Text(
                  '$completionPercentage%',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: completionPercentage / 100,
                      backgroundColor: AppColors.lightPurple,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
      );
}

class _LinedSectionHeader extends StatelessWidget {
  const _LinedSectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              color: AppColors.dark.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientChip extends StatelessWidget {
  const _GradientChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.lightPurple,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.accent,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.accent),
      onTap: onTap,
    );
  }
}

class _ResumeTile extends StatelessWidget {
  const _ResumeTile({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFCE7F3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.description_outlined, color: AppColors.secondary),
      ),
      title: Text(
        'Resume (Drive)',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
      ),
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                'View Resume',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
