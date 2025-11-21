import 'package:flutter/material.dart';

/// Template for list-based screens with loading and error states
/// 
/// This template provides a consistent layout structure for list screens:
/// - App bar with title and actions
/// - List view with refresh capability
/// - Loading state handling
/// - Error state handling
/// - Empty state handling
/// - Optional floating action button
class ListTemplate extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final bool showAppBar;

  const ListTemplate({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              actions: actions,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
