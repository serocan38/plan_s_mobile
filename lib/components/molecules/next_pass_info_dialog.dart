import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pass_prediction.dart';
import '../atoms/buttons.dart';

/// Molecule: Next Pass Info Dialog
/// Displays information about the next satellite pass
class NextPassInfoDialog extends StatelessWidget {
  final PassPrediction pass;
  final String satelliteName;
  final VoidCallback? onViewAllPasses;

  const NextPassInfoDialog({
    super.key,
    required this.pass,
    required this.satelliteName,
    this.onViewAllPasses,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm:ss');

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.schedule, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next Pass', style: TextStyle(fontSize: 18)),
                Text(
                  satelliteName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PassInfoRow(label: 'AOS', value: dateFormat.format(pass.aos)),
          const SizedBox(height: 8),
          _PassInfoRow(label: 'TCA', value: dateFormat.format(pass.tca)),
          const SizedBox(height: 8),
          _PassInfoRow(label: 'LOS', value: dateFormat.format(pass.los)),
          const Divider(height: 24),
          _PassInfoRow(label: 'Duration', value: pass.durationFormatted),
          const SizedBox(height: 8),
          _PassInfoRow(
            label: 'Max Elevation',
            value: pass.maxElevationFormatted,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location: Istanbul (41.0°N, 28.9°E)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AppTextButton(
          onPressed: () => Navigator.pop(context),
          label: 'Close',
        ),
        if (onViewAllPasses != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onViewAllPasses!();
            },
            child: const Text('View All Passes'),
          ),
      ],
    );
  }
}

/// Private widget for pass info row
class _PassInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _PassInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
