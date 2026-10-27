import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/user_role.dart';
import '../../../core/services/session_controller.dart';
import '../../profile/user_profile.dart';

/// Outcome of a password-reset request, mapped from the auth backend's
/// errors so the screen can explain what happened.
enum PasswordResetResult {
  /// Email sent (only reported when a backend actually sent it).
  sent,

  /// No auth backend is connected yet.
  unavailable,
  userNotFound,
  tooManyRequests,
  network,
}

/// Sign-in / sign-up actions used by the auth screens.
///
/// TEMPORARY: there is no backend yet, so any valid form signs in after a
/// short delay. When the API exists, only this class changes.
class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  static const _latency = Duration(milliseconds: 700);

  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(_latency);
    _ref.read(sessionProvider.notifier).signIn(_roleFor(email));
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    _ref.read(userProfileProvider.notifier).signedUp(name: name, email: email);
    _ref.read(sessionProvider.notifier).signIn(UserRole.customer);
  }

  /// Sends a password-reset link to [email].
  ///
  /// Integration point: once Firebase Auth is added, call
  /// `FirebaseAuth.instance.sendPasswordResetEmail(email: email)` here and
  /// map `FirebaseAuthException.code` ('user-not-found',
  /// 'too-many-requests', 'network-request-failed') to the results below.
  /// Until then this never pretends an email went out.
  Future<PasswordResetResult> sendPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
    return PasswordResetResult.unavailable;
  }

  /// Debug-only shortcut so every role can be reached without a backend:
  /// emails starting with "provider" or "admin" sign in as that role.
  UserRole _roleFor(String email) {
    if (kDebugMode) {
      final e = email.trim().toLowerCase();
      if (e.startsWith('provider')) return UserRole.provider;
      if (e.startsWith('admin')) return UserRole.admin;
    }
    return UserRole.customer;
  }
}

final authControllerProvider = Provider(AuthController.new);
