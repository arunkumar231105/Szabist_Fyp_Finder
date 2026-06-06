import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student_model.dart';
import '../services/api_service.dart';

class StudentsNotifier extends StateNotifier<List<StudentModel>> {
  StudentsNotifier() : super([]) {
    loadFromApi();
  }

  Future<void> loadFromApi() async {
    try {
      final raw = await StudentsApi.getAll();
      state = raw.map(StudentModel.fromJson).toList();
    } catch (_) {}
  }

  StudentModel? findById(String id) {
    try {
      return state.firstWhere((student) => student.id == id);
    } catch (_) {
      return null;
    }
  }
}

final studentsProvider =
    StateNotifierProvider<StudentsNotifier, List<StudentModel>>((ref) {
      return StudentsNotifier();
    });
