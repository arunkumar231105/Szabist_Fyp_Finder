import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student_model.dart';

class ProfileNotifier extends StateNotifier<StudentModel> {
  ProfileNotifier() : super(StudentModel.dummyStudent());

  void updateProfile(StudentModel student) {
    state = student;
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, StudentModel>((ref) {
  return ProfileNotifier();
});
