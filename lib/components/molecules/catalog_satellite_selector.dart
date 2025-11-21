import 'package:flutter/material.dart';
import '../../core/data/catalog_data_source.dart';
import '../atoms/text_fields.dart';
import '../molecules/selected_satellite_card.dart';
import '../molecules/satellite_search_list.dart';

class CatalogSatelliteSelector extends StatelessWidget {
  final TextEditingController searchController;
  final List<CatalogSatellite> searchResults;
  final CatalogSatellite? selectedSatellite;
  final ValueChanged<CatalogSatellite> onSatelliteSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final bool isSearching;
  final bool isLoading;

  const CatalogSatelliteSelector({
    super.key,
    required this.searchController,
    required this.searchResults,
    required this.selectedSatellite,
    required this.onSatelliteSelected,
    required this.onSearchChanged,
    required this.onSearchCleared,
    this.isSearching = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchTextField(
          controller: searchController,
          labelText: 'Search Satellites',
          hintText: 'Search by name or NORAD ID...',
          suffixIcon: isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : (searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onSearchCleared,
                    )
                  : null),
          enabled: !isLoading,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 16),

        if (selectedSatellite != null) ...[
          SelectedSatelliteCard(satellite: selectedSatellite!),
          const SizedBox(height: 16),
        ],

        SatelliteSearchList(
          satellites: searchResults,
          selectedSatellite: selectedSatellite,
          onSatelliteSelected: onSatelliteSelected,
          isSearching: isSearching,
        ),
      ],
    );
  }
}
