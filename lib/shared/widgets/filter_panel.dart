import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../models/filter_model.dart';
import 'gradient_button.dart';
import 'multi_select_chip.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({
    required this.onApply,
    this.initialFilters = FilterModel.empty,
    super.key,
  });

  final FilterModel initialFilters;
  final ValueChanged<FilterModel> onApply;

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  static const String _allDepartments = 'All';
  static const String _allBatches = 'All';

  late String _selectedDepartment;
  late String _selectedBatch;
  late List<String> _selectedSkills;
  late List<String> _selectedTechnologies;

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.initialFilters.department ?? _allDepartments;
    _selectedBatch = widget.initialFilters.batch ?? _allBatches;
    _selectedSkills = List<String>.from(widget.initialFilters.skills);
    _selectedTechnologies = List<String>.from(widget.initialFilters.technologies);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Filters \u{1F3AF}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Label(text: 'Department'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDepartment,
                decoration: _inputDecoration(),
                borderRadius: BorderRadius.circular(16),
                items: <String>[_allDepartments, ...AppConstants.departments]
                    .map(
                      (String department) => DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedDepartment = value);
                },
              ),
              const SizedBox(height: 16),
              _Label(text: 'Batch'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBatch,
                decoration: _inputDecoration(),
                borderRadius: BorderRadius.circular(16),
                items: <String>[_allBatches, ...AppConstants.batches]
                    .map(
                      (String batch) => DropdownMenuItem<String>(
                        value: batch,
                        child: Text(batch),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedBatch = value);
                },
              ),
              const SizedBox(height: 16),
              _Label(text: 'Skills'),
              const SizedBox(height: 8),
              MultiSelectChip(
                options: AppConstants.skills,
                selected: _selectedSkills,
                onChanged: (List<String> values) {
                  setState(() => _selectedSkills = values);
                },
              ),
              const SizedBox(height: 16),
              _Label(text: 'Technologies'),
              const SizedBox(height: 8),
              MultiSelectChip(
                options: AppConstants.technologies,
                selected: _selectedTechnologies,
                onChanged: (List<String> values) {
                  setState(() => _selectedTechnologies = values);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      label: 'Apply Filters',
                      onPressed: _applyFilters,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedDepartment = _allDepartments;
      _selectedBatch = _allBatches;
      _selectedSkills = <String>[];
      _selectedTechnologies = <String>[];
    });
  }

  void _applyFilters() {
    final FilterModel filters = FilterModel(
      department:
          _selectedDepartment == _allDepartments ? null : _selectedDepartment,
      batch: _selectedBatch == _allBatches ? null : _selectedBatch,
      skills: _selectedSkills,
      technologies: _selectedTechnologies,
    );

    widget.onApply(filters);
    Navigator.of(context).pop();
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}
