/// Form rules for sign-in and sign-up. Messages say how to fix the input.
abstract final class AuthValidators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    if ((value ?? '').trim().length < 2) return 'Enter your full name.';
    return null;
  }

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your email address.';
    if (!_email.hasMatch(v)) {
      return 'Enter a valid email, like name@example.com.';
    }
    return null;
  }

  /// Sign-in only checks presence; strength rules apply at sign-up.
  static String? passwordRequired(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password.';
    return null;
  }

  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include at least one letter and one number.';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
    String Function() original,
  ) =>
      (value) => value != original() ? 'Passwords don’t match.' : null;
}
