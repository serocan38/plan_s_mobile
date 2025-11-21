import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/satellite.dart';
import '../atoms/info_label.dart';
import '../atoms/tle_line_display.dart';
import 'info_card.dart';

class TLEInfoSection extends StatelessWidget {
  final Satellite satellite;

  const TLEInfoSection({
    super.key,
    required this.satellite,
  });

  Color _getFreshnessColor(TLE tle) {
    final daysSinceEpoch = DateTime.now().difference(tle.epoch).inDays;
    
    if (daysSinceEpoch <= 7) {
      return Colors.green;
    } else if (daysSinceEpoch <= 14) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'TLE Information',
      icon: Icons.settings_input_antenna,
      children: [
        InfoLabel(
          label: 'Epoch',
          value: DateFormat('dd/MM/yyyy HH:mm:ss').format(satellite.tle.epoch),
        ),
        InfoLabel(
          label: 'Status',
          value: satellite.tle.freshnessStatus,
          valueColor: _getFreshnessColor(satellite.tle),
          isStatus: true,
        ),
        InfoLabel(
          label: 'Freshness',
          value: '${DateTime.now().difference(satellite.tle.epoch).inDays} gün önce',
        ),
        const SizedBox(height: 12),
        TLELineDisplay(
          label: 'Line 1',
          value: satellite.tle.line1,
        ),
        const SizedBox(height: 8),
        TLELineDisplay(
          label: 'Line 2',
          value: satellite.tle.line2,
        ),
      ],
    );
  }
}
