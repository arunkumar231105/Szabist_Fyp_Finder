import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/multi_select_chip.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _registrationIdController;
  late final TextEditingController _sectionController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _resumeController;
  late final TextEditingController _bioController;
  late final TextEditingController _customSkillController;
  late final TextEditingController _customInterestController;

  late String _department;
  late String _batch;
  late List<String> _selectedSkills;
  late List<String> _selectedTechnologies;
  late List<String> _selectedInterests;
  late bool _isProfilePublic;

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _registrationIdController.dispose();
    _sectionController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _resumeController.dispose();
    _bioController.dispose();
    _customSkillController.dispose();
    _customInterestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StudentModel student = ref.watch(profileProvider);

    if (!_initialized) {
      _initialize(student);
    }

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: const GradientAppBar(title: 'Edit Profile \u270f\ufe0f'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _SectionHeader(title: 'Basic Info'),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Name'),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _registrationIdController,
                  readOnly: true,
                  decoration: _decoration(
                    'Registration ID',
                    hintText: 'Cannot be changed',
                    fillColor: const Color(0xFFE2E8F0),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _department,
                  decoration: _decoration('Department'),
                  borderRadius: BorderRadius.circular(16),
                  items: AppConstants.departments
                      .map(
                        (String department) => DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _department = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _sectionController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Section'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _batch,
                  decoration: _decoration('Batch'),
                  borderRadius: BorderRadius.circular(16),
                  items: AppConstants.batches
                      .map(
                        (String batch) => DropdownMenuItem<String>(
                          value: batch,
                          child: Text(batch),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _batch = value);
                    }
                  },
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.lightPurple,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _isProfilePublic
                              ? Icons.public_rounded
                              : Icons.lock_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Profile Visibility',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isProfilePublic
                                  ? 'Public profiles appear in Discover and can receive requests.'
                                  : 'Private profiles stay hidden from Discover and cannot send requests.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isProfilePublic,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.lightPurple,
                        onChanged: (bool value) {
                          setState(() => _isProfilePublic = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Skills & Tech \u{1F6E0}\uFE0F'),
                const SizedBox(height: 14),
                const _LabelText(text: 'Skills'),
                const SizedBox(height: 10),
                MultiSelectChip(
                  options: <String>[
                    ...AppConstants.skills,
                    ..._selectedSkills.where(
                      (String skill) => !AppConstants.skills.contains(skill),
                    ),
                  ],
                  selected: _selectedSkills,
                  onChanged: (List<String> values) {
                    setState(() => _selectedSkills = values);
                  },
                ),
                const SizedBox(height: 10),
                _AddCustomField(
                  controller: _customSkillController,
                  hintText: 'Add custom skill',
                  onAdd: () => _addCustomValue(
                    controller: _customSkillController,
                    target: _selectedSkills,
                  ),
                ),
                const SizedBox(height: 16),
                const _LabelText(text: 'Technologies'),
                const SizedBox(height: 10),
                MultiSelectChip(
                  options: AppConstants.technologies,
                  selected: _selectedTechnologies,
                  onChanged: (List<String> values) {
                    setState(() => _selectedTechnologies = values);
                  },
                ),
                const SizedBox(height: 16),
                const _LabelText(text: 'Interests'),
                const SizedBox(height: 10),
                MultiSelectChip(
                  options: <String>[
                    ...AppConstants.interests,
                    ..._selectedInterests.where(
                      (String interest) =>
                          !AppConstants.interests.contains(interest),
                    ),
                  ],
                  selected: _selectedInterests,
                  onChanged: (List<String> values) {
                    setState(() => _selectedInterests = values);
                  },
                ),
                const SizedBox(height: 10),
                _AddCustomField(
                  controller: _customInterestController,
                  hintText: 'Add custom interest',
                  onAdd: () => _addCustomValue(
                    controller: _customInterestController,
                    target: _selectedInterests,
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(title: 'Links & Bio \u{1F517}'),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _githubController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'GitHub URL',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _linkedinController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'LinkedIn URL',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _portfolioController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'Portfolio Link (Optional)',
                    prefixIcon: Icons.web_asset_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _resumeController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'Google Drive Resume Link',
                    hintText: 'Paste Google Drive shareable link',
                    prefixIcon: Icons.description_outlined,
                  ),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return null;
                    }
                    if (!text.startsWith('https://drive.google.com')) {
                      return 'Use a Google Drive shareable link';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bioController,
                  minLines: 4,
                  maxLines: 4,
                  maxLength: AppConstants.maxBioLength,
                  decoration: _decoration('Bio'),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Save Changes',
                  isLoading: _isSaving,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _initialize(StudentModel student) {
    _nameController = TextEditingController(text: student.name);
    _registrationIdController = TextEditingController(
      text: student.registrationId,
    );
    _sectionController = TextEditingController(text: student.section);
    _githubController = TextEditingController(text: student.githubUrl ?? '');
    _linkedinController = TextEditingController(text: student.linkedinUrl ?? '');
    _portfolioController = TextEditingController(
      text: student.portfolioLink ?? '',
    );
    _resumeController = TextEditingController(text: student.resumeLink ?? '');
    _bioController = TextEditingController(text: student.bio ?? '');
    _customSkillController = TextEditingController();
    _customInterestController = TextEditingController();

    _department = student.department;
    _batch = student.batch;
    _selectedSkills = List<String>.from(student.skills);
    _selectedTechnologies = List<String>.from(student.technologies);
    _selectedInterests = List<String>.from(student.interests);
    _isProfilePublic = student.isProfilePublic;
    _initialized = true;
  }

  InputDecoration _decoration(
    String label, {
    String? hintText,
    IconData? prefixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      fillColor: fillColor ?? Colors.white,
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: AppColors.primary),
    );
  }

  void _addCustomValue({
    required TextEditingController controller,
    required List<String> target,
  }) {
    final String value = controller.text.trim();
    if (value.isEmpty || target.contains(value)) {
      controller.clear();
      return;
    }
    setState(() {
      target.add(value);
      controller.clear();
    });
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    final StudentModel updated = ref.read(profileProvider).copyWith(
          name: _nameController.text.trim(),
          department: _department,
          section: _sectionController.text.trim(),
          batch: _batch,
          skills: _selectedSkills,
          technologies: _selectedTechnologies,
          interests: _selectedInterests,
          githubUrl: _normalizeOptional(_githubController.text),
          linkedinUrl: _normalizeOptional(_linkedinController.text),
          portfolioLink: _normalizeOptional(_portfolioController.text),
          resumeLink: _normalizeOptional(_resumeController.text),
          bio: _normalizeOptional(_bioController.text),
          clearGithubUrl: _githubController.text.trim().isEmpty,
          clearLinkedinUrl: _linkedinController.text.trim().isEmpty,
          clearPortfolioLink: _portfolioController.text.trim().isEmpty,
          clearResumeLink: _resumeController.text.trim().isEmpty,
          clearBio: _bioController.text.trim().isEmpty,
          isProfilePublic: _isProfilePublic,
        );

    ref.read(profileProvider.notifier).updateProfile(updated);
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  String? _normalizeOptional(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  const _LabelText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    );
  }
}

class _AddCustomField extends StatelessWidget {
  const _AddCustomField({
    required this.controller,
    required this.hintText,
    required this.onAdd,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
