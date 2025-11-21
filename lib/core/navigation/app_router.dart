import 'package:flutter/material.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/satellite_detail_screen.dart';
import '../../components/organisms/add_satellite_dialog.dart';
import '../../components/organisms/pass_prediction_dialog.dart';
import '../../models/satellite.dart';

class AppRouter {
  AppRouter._();

  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String satelliteDetail = '/satellite-detail';

  static void toLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  static void toRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  static void toDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ),
    );
  }

  static void toSatelliteDetail(BuildContext context, Satellite satellite) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SatelliteDetailScreen(satellite: satellite),
      ),
    );
  }

  static void goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static void popToFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
  }

  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required Widget content,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (_) => content,
    );
  }

  static Future<void> showAddSatelliteDialog(BuildContext context) {
    return showAppDialog(
      context: context,
      dialog: const AddSatelliteDialog(),
    );
  }

  static Future<void> showPassPredictionDialog(
    BuildContext context,
    Satellite satellite,
  ) {
    return showAppDialog(
      context: context,
      dialog: PassPredictionDialog(satellite: satellite),
      barrierDismissible: false,
    );
  }
}
