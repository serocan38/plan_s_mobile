import 'package:flutter/material.dart';

/// Template for screens with app bar
/// 
/// This template provides a consistent layout structure for screens with:
/// - App bar with title and actions
/// - Scrollable body content
/// - Optional floating action button
/// - Optional bottom navigation
class AppBarTemplate extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  const AppBarTemplate({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.centerTitle = false,
    this.bottom,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: centerTitle,
        actions: actions,
        bottom: bottom,
        leading: leading,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
