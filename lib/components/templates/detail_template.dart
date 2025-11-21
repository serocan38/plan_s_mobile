import 'package:flutter/material.dart';

/// Template for detail screens with scrollable content
/// 
/// This template provides a consistent layout structure for detail screens:
/// - App bar with title and optional actions
/// - Scrollable single child body
/// - Support for hero images or headers
/// - Flexible content area
class DetailTemplate extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? header;
  final List<Widget> children;
  final EdgeInsets? padding;
  final Widget? floatingActionButton;

  const DetailTemplate({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.header,
    this.padding,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) header!,
            Padding(
              padding: padding ?? const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
