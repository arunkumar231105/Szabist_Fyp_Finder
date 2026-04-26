import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/utils/string_utils.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../shared/providers/request_provider.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';

class SendRequestScreen extends ConsumerStatefulWidget {
  const SendRequestScreen({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends ConsumerState<SendRequestScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  late final StudentModel _targetStudent;

  @override
  void initState() {
    super.initState();
    final List<StudentModel> students = StudentModel.dummyList();
    _targetStudent = students.firstWhere(
      (StudentModel student) => student.id == widget.userId,
      orElse: () => students.length > 1 ? students[1] : students.first,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StudentModel currentStudent = ref.watch(profileProvider);
    final RequestsState requestsState = ref.watch(requestsProvider);
    final bool canSendRequest = currentStudent.isProfilePublic;
    final bool canCreateNewRequest = requestsState.canCreateNewRequest;

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: const GradientAppBar(title: 'Send Request \u{1F91D}'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!canSendRequest || !canCreateNewRequest) ...<Widget>[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.lock_rounded, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        !canSendRequest
                            ? 'Make your profile public first. Private profiles cannot send partner requests.'
                            : 'You already have a pending or accepted partner request. Withdraw or resolve it before sending another one.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _TargetStudentCard(student: _targetStudent),
            const SizedBox(height: 20),
            Text(
              'Add a message (optional)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Hi! I think we would make a great team...',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Send Request',
              isLoading: _isSending,
              onPressed: () => _sendRequest(
                canSendRequest: canSendRequest,
                canCreateNewRequest: canCreateNewRequest,
                currentStudent: currentStudent,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _isSending ? null : () => context.pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendRequest({
    required bool canSendRequest,
    required bool canCreateNewRequest,
    required StudentModel currentStudent,
  }) async {
    FocusScope.of(context).unfocus();
    if (!canSendRequest) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Make your profile public to send a request.',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!canCreateNewRequest) {
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

    setState(() => _isSending = true);
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    final bool added = ref.read(requestsProvider.notifier).addOutgoingRequest(
          currentStudent: currentStudent,
          targetStudent: _targetStudent,
          message: _messageController.text,
        );
    setState(() => _isSending = false);
    if (!added) {
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
          'Request sent! \u2728',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }
}

class _TargetStudentCard extends StatelessWidget {
  const _TargetStudentCard({required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Text(
                getInitials(student.name),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  student.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.department,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: student.skills
                      .take(AppConstants.maxSkillsShown)
                      .map(
                        (String skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightPurple,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            skill,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
