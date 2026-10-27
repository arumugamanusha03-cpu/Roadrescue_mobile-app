import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/buttons/gradient_button.dart';
import '../../application/auth_controller.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

/// Request a password-reset link. Reports exactly what the auth backend
/// said; with no backend connected yet it says so instead of claiming an
/// email was sent.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _loading = false;
  PasswordResetResult? _result;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });
    final result = await ref
        .read(authControllerProvider)
        .sendPasswordReset(_email.text.trim());
    if (mounted) {
      setState(() {
        _loading = false;
        _result = result;
      });
    }
  }

  void _toLogin() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final sent = _result == PasswordResetResult.sent;

    return AuthScaffold(
      title: 'Forgot Password?',
      subtitle: sent
          ? 'Check your inbox for the reset link.'
          : 'Enter the email you signed up with and we’ll send you a link '
                'to reset your password.',
      onBack: _toLogin,
      children: [
        Form(
          key: _formKey,
          child: AuthTextField(
            hint: 'Email',
            icon: AppIcons.email,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofillHints: const [AutofillHints.email],
            validator: AuthValidators.email,
            onSubmitted: (_) => _submit(),
          ),
        ),
        Gap.v24,
        GradientButton(
          label: sent ? 'Resend Link' : 'Send Reset Link',
          isLoading: _loading,
          onPressed: _submit,
        ),
        if (_result != null) ...[
          Gap.v20,
          _ResultCard(result: _result!, email: _email.text.trim()),
        ],
        Gap.v32,
        AuthFooterLink(
          prompt: 'Remember your password?',
          action: 'Sign In',
          onPressed: _toLogin,
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.email});

  final PasswordResetResult result;
  final String email;

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, body) = switch (result) {
      PasswordResetResult.sent => (
        Icons.mark_email_read_outlined,
        AppPalette.dark.success,
        'Reset link sent',
        'We sent a link to $email. It may take a few minutes; check spam too.',
      ),
      PasswordResetResult.unavailable => (
        Icons.info_outline,
        AppPalette.dark.warning,
        'Password reset isn’t available yet',
        'Accounts aren’t connected to a server in this version, so no email '
            'was sent.',
      ),
      PasswordResetResult.userNotFound => (
        Icons.person_off_outlined,
        AppPalette.dark.error,
        'No account found',
        'Check the email address, or create a new account.',
      ),
      PasswordResetResult.tooManyRequests => (
        Icons.hourglass_empty,
        AppPalette.dark.warning,
        'Too many attempts',
        'Please wait a few minutes and try again.',
      ),
      PasswordResetResult.network => (
        Icons.wifi_off,
        AppPalette.dark.error,
        'No connection',
        'Check your internet connection and try again.',
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            Gap.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypographyDark.cardTitle),
                  Gap.v4,
                  Text(body, style: AppTypographyDark.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
