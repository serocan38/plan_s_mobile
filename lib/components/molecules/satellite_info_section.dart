import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/satellite.dart';
import '../atoms/info_label.dart';
import 'info_card.dart';

class SatelliteInfoSection extends StatelessWidget {
  final Satellite satellite;

  const SatelliteInfoSection({
    super.key,
    required this.satellite,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'General Information',
      icon: Icons.info_outline,
      children: [
        InfoLabel(
          label: 'Satellite Name',
          value: satellite.name,
        ),
        InfoLabel(
          label: 'NORAD ID',
          value: satellite.noradId,
        ),
        InfoLabel(
          label: 'Created',
          value: DateFormat('dd/MM/yyyy HH:mm').format(satellite.createdAt),
        ),
        InfoLabel(
          label: 'Last Updated',
          value: DateFormat('dd/MM/yyyy HH:mm').format(satellite.updatedAt),
        ),
      ],
    );
  }
}
