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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref
        .read(authControllerProvider)
        .signUp(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
    if (mounted) setState(() => _loading = false);
  }

  void _toLogin() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create your Account',
      subtitle: 'Join RoadRescue and get roadside help anytime.',
      onBack: _toLogin,
      children: [
        AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  hint: 'Full Name',
                  icon: AppIcons.profile,
                  controller: _name,
                  keyboardType: TextInputType.name,
                  autofillHints: const [AutofillHints.name],
                  validator: AuthValidators.name,
                ),
                Gap.v16,
                AuthTextField(
                  hint: 'Email',
                  icon: AppIcons.email,
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
                  autofillHints: const [AutofillHints.newPassword],
                  validator: AuthValidators.newPassword,
                ),
                Gap.v16,
                AuthTextField(
                  hint: 'Confirm Password',
                  icon: AppIcons.lock,
                  controller: _confirm,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.confirmPassword(
                    () => _password.text,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        Gap.v32,
        GradientButton(
          label: 'Sign Up',
          showArrow: true,
          isLoading: _loading,
          onPressed: _submit,
        ),
        Gap.v32,
        SocialAuthSection(
          dividerLabel: 'Or sign up with',
          onSelected: (p) => showSocialAuthUnavailable(context, p),
        ),
        Gap.v24,
        AuthFooterLink(
          prompt: 'Already have an account?',
          action: 'Sign In',
          onPressed: _toLogin,
        ),
      ],
    );
  }
}
