import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../shared/models/idea_model.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/idea_provider.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/multi_select_chip.dart';

class PostIdeaScreen extends ConsumerStatefulWidget {
  const PostIdeaScreen({super.key});

  @override
  ConsumerState<PostIdeaScreen> createState() => _PostIdeaScreenState();
}

class _PostIdeaScreenState extends ConsumerState<PostIdeaScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customTechnologyController =
      TextEditingController();
  final TextEditingController _customSkillController = TextEditingController();

  List<String> _selectedTechnologies = <String>[];
  List<String> _selectedSkills = <String>[];
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customTechnologyController.dispose();
    _customSkillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: const GradientAppBar(title: 'Post an Idea \u{1F4A1}'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Share your project idea \u2728',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find the right partner for your FYP',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                maxLength: AppConstants.maxIdeaTitle,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLength: AppConstants.maxIdeaDesc,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text(
                'Technologies Required',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              MultiSelectChip(
                options: <String>[
                  ...AppConstants.technologies,
                  ..._selectedTechnologies.where(
                    (String item) => !AppConstants.technologies.contains(item),
                  ),
                ],
                selected: _selectedTechnologies,
                onChanged: (List<String> values) {
                  setState(() => _selectedTechnologies = values);
                },
              ),
              const SizedBox(height: 10),
              _AddCustomField(
                controller: _customTechnologyController,
                hintText: 'Add custom technology',
                onAdd: () => _addCustomValue(
                  controller: _customTechnologyController,
                  target: _selectedTechnologies,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Skills Required',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              MultiSelectChip(
                options: <String>[
                  ...AppConstants.skills,
                  ..._selectedSkills.where(
                    (String item) => !AppConstants.skills.contains(item),
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
              const SizedBox(height: 24),
              GradientButton(
                label: 'Post Idea \u{1F680}',
                isLoading: _isPosting,
                onPressed: _postIdea,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _postIdea() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isPosting = true);
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    final StudentModel owner = ref.read(profileProvider);
    ref.read(ideaProvider.notifier).addIdea(
          IdeaModel(
            id: 'idea_${DateTime.now().millisecondsSinceEpoch}',
            ownerName: owner.name,
            ownerId: owner.id,
            ownerDept: owner.department,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            technologiesRequired: List<String>.from(_selectedTechnologies),
            skillsRequired: List<String>.from(_selectedSkills),
            status: 'open',
            createdAt: DateTime.now(),
          ),
        );

    setState(() => _isPosting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Idea posted!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  void _addCustomValue({
    required TextEditingController controller,
    required List<String> target,
  }) {
    final String value = controller.text.trim();
    if (value.isEmpty ||
        target.any(
          (String item) => item.toLowerCase() == value.toLowerCase(),
        )) {
      controller.clear();
      return;
    }

    setState(() {
      target.add(value);
      controller.clear();
    });
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
