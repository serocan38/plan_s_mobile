import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../atoms/text_fields.dart';
import '../atoms/buttons.dart';
import '../atoms/error_message.dart';

class RegisterForm extends StatefulWidget {
  final Function(String email, String password) onSubmit;
  final bool isLoading;
  final String? error;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.error,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'your@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'At least ${ApiConstants.passwordMinLength} characters',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < ApiConstants.passwordMinLength) {
                return 'Password must be at least ${ApiConstants.passwordMinLength} characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match. Please try again';
              }
              return null;
            },
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 16),
            ErrorMessage(message: widget.error!),
          ],
          const SizedBox(height: 24),
          AppPrimaryButton(
            onPressed: _handleSubmit,
            label: widget.isLoading ? 'Creating account...' : 'Sign Up',
            icon: Icons.person_add,
            isLoading: widget.isLoading,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ],
      ),
    );
  }
}
