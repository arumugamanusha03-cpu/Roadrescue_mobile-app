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
import '../widgets/social_auth_row.dart';
import '../widgets/social_auth_snack.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // On success the router redirects to the role's home.
    await ref
        .read(authControllerProvider)
        .signIn(email: _email.text, password: _password.text);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Login to your Account',
      subtitle: 'Welcome back! Please login to continue.',
      children: [
        AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  hint: 'Email',
                  icon: AppIcons.profile,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: AuthValidators.email,
                ),
                Gap.v16,
                AuthTextField(
                  hint: 'Password',
                  icon: AppIcons.lock,
                  controller: _password,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: AuthValidators.passwordRequired,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () =>
                context.push(AppRoutes.forgotPasswordFor(_email.text)),
            style: TextButton.styleFrom(
              foregroundColor: AppColorsDark.brandCyan,
              padding: EdgeInsets.zero,
              textStyle: AppTypographyDark.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Forgot Password?'),
          ),
        ),
        Gap.v8,
        GradientButton(
          label: 'Sign In',
          isLoading: _loading,
          onPressed: _submit,
        ),
        Gap.v32,
        SocialAuthSection(
          dividerLabel: 'Or sign in with',
          onSelected: (p) => showSocialAuthUnavailable(context, p),
        ),
        Gap.v24,
        AuthFooterLink(
          prompt: 'Don’t have an account?',
          action: 'Sign Up',
          onPressed: () => context.go(AppRoutes.signup),
        ),
      ],
    );
  }
}
