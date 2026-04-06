class FilterModel {
  const FilterModel({
    this.department,
    this.batch,
    this.skills = const <String>[],
    this.technologies = const <String>[],
  });

  final String? department;
  final String? batch;
  final List<String> skills;
  final List<String> technologies;

  bool get isEmpty =>
      department == null &&
      batch == null &&
      skills.isEmpty &&
      technologies.isEmpty;

  FilterModel copyWith({
    String? department,
    String? batch,
    List<String>? skills,
    List<String>? technologies,
    bool clearDepartment = false,
    bool clearBatch = false,
  }) {
    return FilterModel(
      department: clearDepartment ? null : (department ?? this.department),
      batch: clearBatch ? null : (batch ?? this.batch),
      skills: skills ?? this.skills,
      technologies: technologies ?? this.technologies,
    );
  }

  static const FilterModel empty = FilterModel();
}
