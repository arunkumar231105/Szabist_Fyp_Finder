import '../constants.dart';

String? validateSzabistEmail(String? value) {
  final String email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required';
  if (!email.endsWith(AppConstants.szabistDomain)) {
    return 'Use your SZABIST email (@szabist.pk)';
  }
  return null;
}
