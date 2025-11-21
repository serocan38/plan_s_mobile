import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'design_system/colors.dart';
import 'providers/auth_state_provider.dart';
import 'providers/satellite_state_provider.dart';
import 'providers/pass_state_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('en', null);
  
  runApp(const PlanSApp());
}

class PlanSApp extends StatelessWidget {
  const PlanSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStateProvider()),
        ChangeNotifierProvider(create: (_) => SatelliteStateProvider()),
        ChangeNotifierProvider(create: (_) => PassStateProvider()),
      ],
      child: Consumer<AuthStateProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Plan-S Satellite Tracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.background,
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.primary,
                surface: AppColors.surface,
                error: AppColors.error,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                centerTitle: false,
                elevation: 0,
                backgroundColor: AppColors.surface.withValues(alpha: 0.7),
                foregroundColor: AppColors.textPrimary,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            home: authProvider.isAuthenticated 
              ? const DashboardScreen() 
              : const LoginScreen(),
          );
        },
      ),
    );
  }
}
