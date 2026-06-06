import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('auth_token') != null;
  }

  Future<void> login(String email, String password) async {
    final data = await AuthApi.login(email, password);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', data['token'] as String);
    await prefs.setInt('student_id', data['studentId'] as int);

    if (data['name'] != null) {
      await prefs.setString('student_name', data['name'] as String);
    }

    state = true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    await prefs.remove('student_id');
    await prefs.remove('student_name');

    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
