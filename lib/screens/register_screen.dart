import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';
import '../core/navigation/app_router.dart';
import '../components/atoms/auth_header.dart';
import '../components/molecules/register_form.dart';
import '../components/templates/auth_template.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: Consumer<AuthStateProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppRouter.toDashboard(context);
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                icon: Icons.person_add,
                title: 'Create Account',
              ),
              const SizedBox(height: 32),

              RegisterForm(
                onSubmit: (email, password) {
                  authProvider.register(email, password);
                },
                isLoading: authProvider.isLoading,
                error: authProvider.error,
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: authProvider.isLoading 
                    ? null 
                    : () => AppRouter.goBack(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Login'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
