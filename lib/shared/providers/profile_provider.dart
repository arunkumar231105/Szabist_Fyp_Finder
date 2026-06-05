import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';

class ProfileNotifier extends StateNotifier<StudentModel> {
  ProfileNotifier() : super(StudentModel.dummyStudent()) {
    loadFromApi();
  }

  // API se logged-in student load karo (id=1 = current user)
  Future<void> loadFromApi() async {
    try {
      final raw = await StudentsApi.getById(1);
      state = StudentModel.fromJson(raw);
    } catch (_) {
      // API nahi mili to dummy data rehne do
    }
  }

  // Profile update karo
  void updateProfile(StudentModel student) {
    state = student;
    _syncToApi(student);
  }

  Future<void> _syncToApi(StudentModel s) async {
    try {
      await StudentsApi.update(int.parse(s.id.isEmpty ? '1' : s.id), s.toJson());
    } catch (_) {}
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, StudentModel>((ref) {
  return ProfileNotifier();
});
