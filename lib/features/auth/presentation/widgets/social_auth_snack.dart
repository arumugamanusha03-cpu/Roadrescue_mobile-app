import 'package:flutter/material.dart';

import 'social_auth_row.dart';

/// Social sign-in needs Firebase / OAuth setup that doesn't exist yet. Say so
/// plainly instead of a button that silently does nothing.
void showSocialAuthUnavailable(BuildContext context, SocialProvider provider) {
  final name = switch (provider) {
    SocialProvider.google => 'Google',
    SocialProvider.apple => 'Apple',
    SocialProvider.facebook => 'Facebook',
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$name sign-in isn’t available yet. Use email for now.'),
      ),
    );
}
