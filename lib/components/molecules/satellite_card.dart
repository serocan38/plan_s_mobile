import 'package:flutter/material.dart';
import '../../models/satellite.dart';
import '../atoms/satellite_icon.dart';
import '../atoms/tle_freshness_badge.dart';
import '../../utils/tle_utils.dart';

class SatelliteCard extends StatelessWidget {
  final Satellite satellite;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRefreshTLE;
  final VoidCallback? onCalculatePass;
  final bool isAdmin;

  const SatelliteCard({
    super.key,
    required this.satellite,
    required this.onTap,
    required this.onDelete,
    required this.onRefreshTLE,
    this.onCalculatePass,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final tleFreshnessData = checkTLEFreshness(satellite.tle);
    final daysFromEpoch = tleFreshnessData['daysFromEpoch'] as int;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SatelliteIcon(size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      satellite.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NORAD ID: ${satellite.noradId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              TLEFreshnessBadge(
                daysFromEpoch: daysFromEpoch,
                compact: true,
              ),
              const SizedBox(width: 8),
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'calculate_pass') {
                      onCalculatePass?.call();
                    } else if (value == 'refresh') {
                      onRefreshTLE();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onCalculatePass != null)
                      const PopupMenuItem(
                        value: 'calculate_pass',
                        child: Row(
                          children: [
                            Icon(Icons.timeline, size: 20, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Calculate Passes'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 20),
                          SizedBox(width: 8),
                          Text('Refresh TLE'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
