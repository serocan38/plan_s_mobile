import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/satellite.dart';
import '../../providers/pass_state_provider.dart';
import '../atoms/position_tile.dart';

class SatellitePositionAccordion extends StatefulWidget {
  final Satellite satellite;
  final DateTime? selectedTime;
  final VoidCallback onSelectTime;
  final VoidCallback onSetToNow;

  const SatellitePositionAccordion({
    super.key,
    required this.satellite,
    this.selectedTime,
    required this.onSelectTime,
    required this.onSetToNow,
  });

  @override
  State<SatellitePositionAccordion> createState() => _SatellitePositionAccordionState();
}

class _SatellitePositionAccordionState extends State<SatellitePositionAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PassStateProvider>(
      builder: (context, passProvider, child) {
        return Container(
          color: Colors.grey.shade900,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: _isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded = expanded;
                });
              },
              leading: Icon(
                Icons.location_on,
                color: passProvider.currentPosition != null 
                    ? Colors.blue 
                    : Colors.grey,
              ),
              title: const Text(
                'Current Position',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: _buildSubtitle(passProvider),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildContent(passProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(PassStateProvider passProvider) {
    if (passProvider.currentPosition != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${passProvider.currentPosition!.latitude.toStringAsFixed(2)}°, ${passProvider.currentPosition!.longitude.toStringAsFixed(2)}°',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          if (widget.selectedTime != null)
            Text(
              'Time: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.selectedTime!)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      );
    } else {
      return Text(
        widget.selectedTime != null
            ? 'Time: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.selectedTime!)}'
            : 'Tap to view position',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      );
    }
  }

  Widget _buildContent(PassStateProvider passProvider) {
    if (passProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (passProvider.currentPosition != null) {
      return _buildPositionData(passProvider);
    }

    return _buildNoData();
  }

  Widget _buildPositionData(PassStateProvider passProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PositionTile(
                label: 'Latitude',
                value: '${passProvider.currentPosition!.latitude.toStringAsFixed(4)}°',
                icon: Icons.explore,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PositionTile(
                label: 'Longitude',
                value: '${passProvider.currentPosition!.longitude.toStringAsFixed(4)}°',
                icon: Icons.public,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PositionTile(
                label: 'Altitude',
                value: '${passProvider.currentPosition!.altitude.toStringAsFixed(2)} km',
                icon: Icons.height,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PositionTile(
                label: 'Velocity',
                value: '${passProvider.currentPosition!.velocity.magnitude.toStringAsFixed(2)} km/s',
                icon: Icons.speed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: OutlinedButton.icon(
                onPressed: widget.onSelectTime,
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(
                  widget.selectedTime != null 
                    ? DateFormat('dd/MM/yyyy HH:mm').format(widget.selectedTime!)
                    : 'Select Time',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: widget.onSetToNow,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: widget.selectedTime == null 
                    ? Colors.blue.withValues(alpha: 0.1)
                    : null,
                ),
                child: const Text(
                  'NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.location_off,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              'No position data available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onSetToNow,
              icon: const Icon(Icons.my_location),
              label: const Text('Get Current Position'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
