import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../auth/domain/auth_validators.dart';
import '../../emergency_request/widgets/request_fields.dart';
import '../../emergency_request/widgets/request_step_scaffold.dart';
import '../user_profile.dart';
import '../widgets/profile_widgets.dart';

/// Update name, phone and email.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _profile = ref.read(userProfileProvider);
  late final _name = TextEditingController(text: _profile.name);
  late final _phone = TextEditingController(text: _profile.phone);
  late final _email = TextEditingController(text: _profile.email);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _validPhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length < 10) return 'Enter a 10-digit mobile number.';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(userProfileProvider.notifier)
        .update(
          _profile.copyWith(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
          ),
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.bodyLarge.copyWith(
      color: AppColors.textPrimary,
    );
    return RequestStepScaffold(
      title: 'Edit Profile',
      subtitle: 'Keep your contact details up to date.',
      bottom: GradientButton(label: 'Save Changes', onPressed: _save),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: InitialsAvatar(name: _profile.name, size: 88)),
            Gap.v24,
            const FieldLabel('Full Name'),
            TextFormField(
              controller: _name,
              style: style,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: requestFieldDecoration(hint: 'Your name'),
              validator: AuthValidators.name,
            ),
            Gap.v16,
            const FieldLabel('Mobile Number'),
            TextFormField(
              controller: _phone,
              style: style,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
              ],
              decoration: requestFieldDecoration(hint: '+91 98765 43210'),
              validator: _validPhone,
            ),
            Gap.v16,
            const FieldLabel('Email'),
            TextFormField(
              controller: _email,
              style: style,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: requestFieldDecoration(hint: 'you@example.com'),
              validator: AuthValidators.email,
            ),
          ],
        ),
      ),
    );
  }
}
