import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The signed-in customer's details shown on Profile.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.memberSince,
  });

  final String name;
  final String phone;
  final String email;
  final DateTime memberSince;

  UserProfile copyWith({String? name, String? phone, String? email}) =>
      UserProfile(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        memberSince: memberSince,
      );
}

/// TEMPORARY in-memory profile seeded with the approved design's sample
/// customer; sign-up overwrites name and email. Replace with the account API.
class UserProfileController extends Notifier<UserProfile> {
  @override
  UserProfile build() => UserProfile(
    name: 'Anusha A',
    phone: '+91 98765 43210',
    email: 'anusha@example.com',
    memberSince: DateTime(2024, 8),
  );

  void update(UserProfile profile) => state = profile;

  void signedUp({required String name, required String email}) =>
      state = UserProfile(
        name: name,
        phone: '',
        email: email,
        memberSince: DateTime.now(),
      );
}

final userProfileProvider =
    NotifierProvider<UserProfileController, UserProfile>(
      UserProfileController.new,
    );
