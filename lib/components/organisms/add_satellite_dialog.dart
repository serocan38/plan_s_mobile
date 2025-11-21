import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/satellite_state_provider.dart';
import '../../core/data/catalog_data_source.dart';
import '../../core/network/api_client.dart';
import '../../core/navigation/app_router.dart';
import '../atoms/buttons.dart';
import '../molecules/catalog_satellite_selector.dart';
import '../molecules/custom_satellite_form.dart';

enum AddSatelliteMode {
  catalog,
  custom,
}

class AddSatelliteDialog extends StatefulWidget {
  const AddSatelliteDialog({super.key});

  @override
  State<AddSatelliteDialog> createState() => _AddSatelliteDialogState();
}

class _AddSatelliteDialogState extends State<AddSatelliteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _noradCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  
  bool _loading = false;
  bool _searching = false;
  AddSatelliteMode _mode = AddSatelliteMode.catalog;
  
  List<CatalogSatellite> _results = [];
  CatalogSatellite? _selected;
  
  late CatalogDataSource _catalog;

  @override
  void initState() {
    super.initState();
    _catalog = CatalogDataSource(ApiClient());
    _fetch();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noradCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _searching = true;
    });

    try {
      final response = await _catalog.searchCatalog(null);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _results = response.data!;
          _searching = false;
        });
      } else {
        setState(() {
          _searching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searching = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      await _fetch();
      return;
    }

    setState(() {
      _searching = true;
    });

    try {
      final response = await _catalog.searchCatalog(query);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _results = response.data!;
          _searching = false;
        });
      } else {
        setState(() {
          _searching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searching = false;
      });
    }
  }

  void _handleSearchCleared() {
    _searchCtrl.clear();
    _search('');
  }

  void _handleSearchChanged(String value) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (value == _searchCtrl.text) {
        _search(value);
      }
    });
  }

  void _select(CatalogSatellite satellite) {
    setState(() {
      _selected = satellite;
      _nameCtrl.text = satellite.name;
      _noradCtrl.text = satellite.noradId;
    });
  }

  Future<void> _handleSubmit() async {
    if (_mode == AddSatelliteMode.catalog && _selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a satellite from the catalog'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_mode == AddSatelliteMode.custom && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final provider = context.read<SatelliteStateProvider>();
      final success = await provider.createSatellite(
        name: _nameCtrl.text.trim(),
        noradId: _noradCtrl.text.trim(),
      );

      if (mounted) {
        AppRouter.goBack(context);
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Satellite added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            final errorMessage = provider.error ?? 'Unable to add satellite. Please try again.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppRouter.goBack(context);
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildCatalogMode() {
    return CatalogSatelliteSelector(
      searchController: _searchCtrl,
      searchResults: _results,
      selectedSatellite: _selected,
      onSatelliteSelected: _select,
      onSearchChanged: _handleSearchChanged,
      onSearchCleared: _handleSearchCleared,
      isSearching: _searching,
      isLoading: _loading,
    );
  }

  Widget _buildCustomMode() {
    return CustomSatelliteForm(
      nameController: _nameCtrl,
      noradController: _noradCtrl,
      isLoading: _loading,
      formKey: _formKey,
      onSubmit: _handleSubmit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: isSmallScreen ? screenHeight * 0.85 : 650,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.satellite_alt, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add Satellite',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => AppRouter.goBack(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                SegmentedButton<AddSatelliteMode>(
                  segments: const [
                    ButtonSegment(
                      value: AddSatelliteMode.catalog,
                      label: Text('From Catalog'),
                      icon: Icon(Icons.search, size: 18),
                    ),
                    ButtonSegment(
                      value: AddSatelliteMode.custom,
                      label: Text('Custom'),
                      icon: Icon(Icons.edit, size: 18),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (Set<AddSatelliteMode> newSelection) {
                    setState(() {
                      _mode = newSelection.first;
                      _selected = null;
                      _nameCtrl.clear();
                      _noradCtrl.clear();
                      _searchCtrl.clear();
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: _mode == AddSatelliteMode.catalog
                        ? _buildCatalogMode()
                        : _buildCustomMode(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppTextButton(
                      onPressed: _loading ? null : () => AppRouter.goBack(context),
                      label: 'Cancel',
                    ),
                    const SizedBox(width: 12),
                    AppPrimaryButton(
                      onPressed: _handleSubmit,
                      label: _loading ? 'Adding...' : 'Add',
                      icon: Icons.add,
                      isLoading: _loading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
