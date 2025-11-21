import 'package:flutter/material.dart';
import '../../core/data/catalog_data_source.dart';

class SatelliteSearchList extends StatelessWidget {
  final List<CatalogSatellite> satellites;
  final CatalogSatellite? selectedSatellite;
  final ValueChanged<CatalogSatellite> onSatelliteSelected;
  final bool isSearching;

  const SatelliteSearchList({
    super.key,
    required this.satellites,
    required this.selectedSatellite,
    required this.onSatelliteSelected,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (satellites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.satellite_alt, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No satellites found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: satellites.length,
        itemBuilder: (context, index) {
          final satellite = satellites[index];
          final isSelected = selectedSatellite?.noradId == satellite.noradId;

          return ListTile(
            leading: Icon(
              Icons.satellite_alt,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            title: Text(
              satellite.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : null,
              ),
            ),
            subtitle: Text('NORAD ID: ${satellite.noradId}'),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            selected: isSelected,
            onTap: () => onSatelliteSelected(satellite),
          );
        },
      ),
    );
  }
}
