import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/colors.dart';
import '../../../core/utils/string_utils.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/profile_widgets.dart';

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
    final String initials = getInitials(_student.name);

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
                        onPressed: () =>
                            context.push('/send-request/${_student.id}'),
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
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border,
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
                                Color(0xFF818CF8),
                                Color(0xFF60A5FA),
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
                            ProfileInfoChip(
                              label: _student.department,
                              backgroundColor: Colors.white,
                              textColor: AppColors.primary,
                            ),
                            ProfileInfoChip(
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
                        const ProfileSectionTitle(title: 'About Me'),
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
                      const ProfileLinedSectionHeader(title: 'Skills ⚡'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _student.skills
                            .map(
                              (String skill) => ProfileGradientChip(label: skill),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const ProfileLinedSectionHeader(
                        title: 'Technologies 🛠️',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _student.technologies
                            .map(
                              (String technology) => ProfileSoftChip(
                                label: technology,
                                backgroundColor: const Color(0xFFCFFAFE),
                                textColor: const Color(0xFF0F766E),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const ProfileLinedSectionHeader(title: 'Interests 🎯'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _student.interests
                            .map(
                              (String interest) => ProfileSoftChip(
                                label: interest,
                                backgroundColor: const Color(0xFFDBEAFE),
                                textColor: const Color(0xFF1D4ED8),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const ProfileLinedSectionHeader(title: 'Links 🔗'),
                      const SizedBox(height: 10),
                      ProfileLinkTile(
                        icon: Icons.code_rounded,
                        title: 'GitHub',
                        subtitle: _student.githubUrl ?? '',
                        onTap: () => _launchLink(_student.githubUrl),
                      ),
                      ProfileLinkTile(
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

  static Future<void> _launchLink(String? url) async {
    if (url == null || url.isEmpty) return;
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
