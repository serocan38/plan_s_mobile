import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

/// Template for authentication screens (login, register)
/// 
/// This template provides a consistent layout structure for auth screens:
/// - Centered content with scrollable area
/// - Optional app bar
/// - Safe area handling
/// - Responsive padding
class AuthTemplate extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  const AuthTemplate({
    super.key,
    required this.child,
    this.appBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}
