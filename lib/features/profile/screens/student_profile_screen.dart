import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/colors.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/widgets/gradient_button.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  late final StudentModel _student;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    final List<StudentModel> students = StudentModel.dummyList();
    _student = students.firstWhere(
      (StudentModel student) => student.id == widget.userId,
      orElse: () => students.length > 1 ? students[1] : students.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initials = _buildInitials(_student.name);

    return Scaffold(
      backgroundColor: AppColors.grey,
      bottomNavigationBar: _student.isLocked
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _startChat,
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Start Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Send Partner Request',
                        onPressed: () => context.push('/send-request/${_student.id}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() => _isBookmarked = !_isBookmarked);
                },
                icon: Icon(
                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border,
                ),
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
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 2,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
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
                          _student.name,
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
                              label: _student.department,
                              backgroundColor: Colors.white,
                              textColor: AppColors.primary,
                            ),
                            _InfoChip(
                              label: _student.batch,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.16,
                              ),
                              textColor: Colors.white,
                              borderColor: Colors.white.withValues(alpha: 0.22),
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
          if (_student.isLocked)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFEF4444), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.lock_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This student has a partner',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
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
                  padding: EdgeInsets.fromLTRB(
                    20,
                    _student.isLocked ? 32 : 24,
                    20,
                    _student.isLocked ? 32 : 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if ((_student.bio ?? '').trim().isNotEmpty) ...<Widget>[
                        const _SectionTitle(title: 'About Me'),
                        const SizedBox(height: 10),
                        Text(
                          _student.bio!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.dark.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const _LinedSectionHeader(title: 'Skills \u26a1'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _student.skills
                            .map(
                              (String skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  skill,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
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
                        children: _student.technologies
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
                        children: _student.interests
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
                      _LinkTile(
                        icon: Icons.code_rounded,
                        title: 'GitHub',
                        subtitle: _student.githubUrl ?? '',
                        onTap: () => _launchLink(_student.githubUrl),
                      ),
                      _LinkTile(
                        icon: Icons.business_center_outlined,
                        title: 'LinkedIn',
                        subtitle: _student.linkedinUrl ?? '',
                        onTap: () => _launchLink(_student.linkedinUrl),
                      ),
                      _ResumeTile(
                        onTap: () => _launchLink(_student.resumeLink),
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

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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

  void _startChat() {
    final String chatId = ref.read(chatProvider.notifier).ensureChat(_student);
    context.push('/chat/$chatId');
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
      ),
    );
  }
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
          color: const Color(0xFFCFFAFE),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.description_outlined, color: AppColors.accent),
      ),
      title: Text(
        'Resume (Drive)',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
      ),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(
          'View Resume',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
