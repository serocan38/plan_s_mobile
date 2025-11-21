import 'package:flutter/material.dart';
import '../atoms/buttons.dart';

/// Molecule: Delete Confirmation Dialog
/// A reusable confirmation dialog for delete operations
class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String itemName;
  final String? message;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.itemName,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(
        message ?? 'Are you sure you want to delete $itemName?',
      ),
      actions: [
        AppTextButton(
          onPressed: () => Navigator.pop(context, false),
          label: 'Cancel',
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  /// Helper method to show delete confirmation
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String itemName,
    String? message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        itemName: itemName,
        message: message,
      ),
    );
    return result ?? false;
  }
}
