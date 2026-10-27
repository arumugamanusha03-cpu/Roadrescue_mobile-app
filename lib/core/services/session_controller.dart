import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/user_role.dart';

/// App-wide session facts the router needs to decide where a user may go.
class Session {
  const Session({
    this.hasSeenOnboarding = false,
    this.hasHandledLocationPrompt = false,
    this.role,
  });

  final bool hasSeenOnboarding;

  /// True once the customer has answered the location prompt (either way).
  final bool hasHandledLocationPrompt;

  /// Null while signed out.
  final UserRole? role;

  bool get isSignedIn => role != null;

  Session copyWith({
    bool? hasSeenOnboarding,
    bool? hasHandledLocationPrompt,
    UserRole? role,
    bool clearRole = false,
  }) {
    return Session(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasHandledLocationPrompt:
          hasHandledLocationPrompt ?? this.hasHandledLocationPrompt,
      role: clearRole ? null : role ?? this.role,
    );
  }
}

/// In-memory session for now. When auth and persistence land, this keeps the
/// same public API and delegates to an AuthRepository + local storage, so
/// the router and screens don't change.
class SessionController extends Notifier<Session> {
  @override
  Session build() => const Session();

  void completeOnboarding() => state = state.copyWith(hasSeenOnboarding: true);

  void markLocationPromptHandled() =>
      state = state.copyWith(hasHandledLocationPrompt: true);

  void signIn(UserRole role) => state = state.copyWith(role: role);

  void signOut() => state = state.copyWith(clearRole: true);
}

final sessionProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);
