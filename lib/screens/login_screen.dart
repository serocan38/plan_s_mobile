import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../design_system/colors.dart';
import '../components/atoms/auth_header.dart';
import '../components/molecules/login_form.dart';
import '../components/templates/auth_template.dart';
import '../providers/auth_state_provider.dart';
import '../core/navigation/app_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      child: Consumer<AuthStateProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppRouter.toDashboard(context);
            });
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                icon: Icons.satellite_alt,
                title: 'Plan-S',
                subtitle: 'Satellite Tracking System',
              ),
              const SizedBox(height: 48),

              LoginForm(
                onSubmit: (email, password) {
                  authProvider.login(email, password);
                },
                isLoading: authProvider.isLoading,
                error: authProvider.error,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => AppRouter.toRegister(context),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
