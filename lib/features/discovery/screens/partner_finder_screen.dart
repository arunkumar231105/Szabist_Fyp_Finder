import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../../../shared/models/filter_model.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_panel.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/student_card.dart';

class PartnerFinderScreen extends ConsumerStatefulWidget {
  const PartnerFinderScreen({
    this.showAppBar = true,
    super.key,
  });

  final bool showAppBar;

  @override
  ConsumerState<PartnerFinderScreen> createState() =>
      _PartnerFinderScreenState();
}

class _PartnerFinderScreenState extends ConsumerState<PartnerFinderScreen> {
  final TextEditingController _searchController = TextEditingController();

  FilterModel _activeFilters = FilterModel.empty;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileProvider);
    final List<StudentModel> visibleStudents = _filteredStudents();

    final Widget body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _searchController,
            onChanged: (String value) {
              setState(() => _searchQuery = value.trim());
            },
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          if (_hasActiveFilters) ...<Widget>[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActiveFilterChips(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Text(
                '${visibleStudents.length} students found',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visibleStudents.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No students found',
                    message: 'Try different filters',
                  )
                : ListView.separated(
                    itemCount: visibleStudents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final StudentModel student = visibleStudents[index];
                      return StudentCard(
                        student: student,
                        onTap: () => student.id == ref.read(profileProvider).id
                            ? context.push('/profile/me')
                            : context.push('/profile/${student.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return ColoredBox(color: AppColors.grey, child: body);
    }

    return Scaffold(
      backgroundColor: AppColors.grey,
      appBar: GradientAppBar(
        title: 'Find a Partner \u{1F50D}',
        actions: <Widget>[
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: body,
    );
  }

  bool get _hasActiveFilters => _searchQuery.isNotEmpty || !_activeFilters.isEmpty;

  List<StudentModel> _filteredStudents() {
    final StudentModel currentStudent = ref.read(profileProvider);
    final String query = _searchQuery.toLowerCase();
    final List<StudentModel> allStudents = <StudentModel>[
      currentStudent,
      ...StudentModel.dummyList().where(
        (StudentModel student) => student.id != currentStudent.id,
      ),
    ];

    final List<StudentModel> filtered = allStudents.where((StudentModel student) {
      final bool matchesName =
          query.isEmpty || student.name.toLowerCase().contains(query);
      final bool matchesDepartment = _activeFilters.department == null ||
          student.department == _activeFilters.department;
      final bool matchesBatch =
          _activeFilters.batch == null || student.batch == _activeFilters.batch;
      final bool matchesSkills = _activeFilters.skills.isEmpty ||
          _activeFilters.skills.every(student.skills.contains);
      final bool matchesTechnologies = _activeFilters.technologies.isEmpty ||
          _activeFilters.technologies.every(student.technologies.contains);
      final bool isVisibleOnDiscover = student.isProfilePublic;

      return isVisibleOnDiscover &&
          matchesName &&
          matchesDepartment &&
          matchesBatch &&
          matchesSkills &&
          matchesTechnologies;
    }).toList();

    filtered.sort((StudentModel a, StudentModel b) {
      if (a.isLocked == b.isLocked) {
        return a.name.compareTo(b.name);
      }
      return a.isLocked ? 1 : -1;
    });

    return filtered;
  }

  List<Widget> _buildActiveFilterChips() {
    final List<Widget> chips = <Widget>[];

    if (_searchQuery.isNotEmpty) {
      chips.add(
        _ActiveFilterChip(
          label: 'Search: $_searchQuery',
          onDeleted: () {
            setState(() {
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
      );
    }

    if (_activeFilters.department != null) {
      chips.add(
        _ActiveFilterChip(
          label: _activeFilters.department!,
          onDeleted: () {
            setState(() {
              _activeFilters = _activeFilters.copyWith(clearDepartment: true);
            });
          },
        ),
      );
    }

    if (_activeFilters.batch != null) {
      chips.add(
        _ActiveFilterChip(
          label: 'Batch ${_activeFilters.batch!}',
          onDeleted: () {
            setState(() {
              _activeFilters = _activeFilters.copyWith(clearBatch: true);
            });
          },
        ),
      );
    }

    for (final String skill in _activeFilters.skills) {
      chips.add(
        _ActiveFilterChip(
          label: skill,
          onDeleted: () {
            setState(() {
              _activeFilters = _activeFilters.copyWith(
                skills: _activeFilters.skills
                    .where((String item) => item != skill)
                    .toList(),
              );
            });
          },
        ),
      );
    }

    for (final String technology in _activeFilters.technologies) {
      chips.add(
        _ActiveFilterChip(
          label: technology,
          onDeleted: () {
            setState(() {
              _activeFilters = _activeFilters.copyWith(
                technologies: _activeFilters.technologies
                    .where((String item) => item != technology)
                    .toList(),
              );
            });
          },
        ),
      );
    }

    return chips;
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return FilterPanel(
          initialFilters: _activeFilters,
          onApply: (FilterModel filters) {
            setState(() => _activeFilters = filters);
          },
        );
      },
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onDeleted,
  });

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: true,
      showCheckmark: false,
      selectedColor: AppColors.lightPurple,
      backgroundColor: AppColors.lightPurple,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      deleteIcon: const Icon(
        Icons.close_rounded,
        size: 18,
        color: AppColors.primary,
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      onSelected: (_) {},
      onDeleted: onDeleted,
    );
  }
}
