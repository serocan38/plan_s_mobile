import 'package:flutter/material.dart';
import '../../models/satellite.dart';
import '../atoms/buttons.dart';

class SatelliteActionsBar extends StatelessWidget {
  final Satellite satellite;
  final VoidCallback onUpdateTLE;
  final VoidCallback onCalculatePasses;
  final VoidCallback onShowNextPass;
  final bool isAdmin;

  const SatelliteActionsBar({
    super.key,
    required this.satellite,
    required this.onUpdateTLE,
    required this.onCalculatePasses,
    required this.onShowNextPass,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAdmin) ...[
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              onPressed: onUpdateTLE,
              icon: Icons.refresh,
              label: 'Update TLE',
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                onPressed: onCalculatePasses,
                icon: Icons.timeline,
                label: 'Calculate Passes',
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppOutlinedButton(
                onPressed: onShowNextPass,
                icon: Icons.schedule,
                label: 'Next Pass',
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
