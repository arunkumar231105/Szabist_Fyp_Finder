import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_model.dart';
import '../services/api_service.dart';

const _emptyStudent = StudentModel(
  id: '',
  name: '',
  email: '',
  registrationId: '',
  department: '',
  section: '',
  batch: '',
  skills: <String>[],
  technologies: <String>[],
  interests: <String>[],
  completionPercentage: 0,
  isLocked: false,
  isProfilePublic: true,
);

class ProfileNotifier extends StateNotifier<StudentModel> {
  ProfileNotifier() : super(_emptyStudent) {
    loadFromApi();
  }

  Future<void> loadFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentId = prefs.getInt('student_id') ?? 1;
      final raw = await StudentsApi.getById(studentId);
      state = StudentModel.fromJson(raw);
    } catch (_) {}
  }

  Future<void> updateProfile(StudentModel student) async {
    state = student;
    try {
      await StudentsApi.update(int.parse(student.id), student.toJson());
    } catch (_) {}
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, StudentModel>((
  ref,
) {
  return ProfileNotifier();
});
