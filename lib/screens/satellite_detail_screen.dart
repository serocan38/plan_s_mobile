import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/satellite.dart';
import '../models/pass_prediction.dart';
import '../providers/satellite_state_provider.dart';
import '../providers/pass_state_provider.dart';
import '../providers/auth_state_provider.dart';
import '../components/organisms/interactive_globe_3d.dart';
import '../components/organisms/satellite_position_accordion.dart';
import '../components/organisms/pass_prediction_dialog.dart';
import '../components/molecules/edit_name_dialog.dart';
import '../components/molecules/satellite_info_section.dart';
import '../components/molecules/tle_info_section.dart';
import '../components/molecules/satellite_actions_bar.dart';
import '../components/molecules/next_pass_info_dialog.dart';
import '../components/molecules/delete_confirmation_dialog.dart';
import '../components/atoms/loading_dialog.dart';

class SatelliteDetailScreen extends StatefulWidget {
  final Satellite satellite;

  const SatelliteDetailScreen({
    super.key,
    required this.satellite,
  });

  @override
  State<SatelliteDetailScreen> createState() => _SatelliteDetailScreenState();
}

class _SatelliteDetailScreenState extends State<SatelliteDetailScreen> {
  DateTime? _selectedPositionTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPosition(context, widget.satellite);
    });
  }

  void _refreshPosition(BuildContext context, Satellite satellite) {
    context.read<PassStateProvider>().getSatellitePosition(
      noradId: satellite.noradId,
      tle: satellite.tle.toJson(),
      time: (_selectedPositionTime ?? DateTime.now()).toUtc(),
    );
  }

  void _setToNow(BuildContext context, Satellite satellite) {
    setState(() {
      _selectedPositionTime = null; // Reset to current time
    });
    _refreshPosition(context, satellite);
  }

  Future<void> _selectPositionTime(BuildContext context, Satellite satellite) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedPositionTime ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 30)),
    );

    if (selectedDate != null && context.mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedPositionTime ?? now),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedPositionTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });

        if (context.mounted) {
          _refreshPosition(context, satellite);
        }
      }
    }
  }

  void _showNextPass(BuildContext context, Satellite satellite) async {
    final passProvider = context.read<PassStateProvider>();
    
    final groundLocation = GroundLocation(
      latitude: 41.0082,
      longitude: 28.9784,
      altitude: 0.05,
    );
    
    // Show loading dialog
    LoadingDialog.show(context, message: 'Calculating next pass...');
    
    await passProvider.predictNextPass(
      noradId: satellite.noradId,
      groundLocation: groundLocation,
      minElevation: 10.0,
      searchHours: 72,
    );
    
    if (context.mounted) {
      LoadingDialog.hide(context);
      
      if (passProvider.nextPass != null) {
        _showNextPassDialog(context, passProvider.nextPass!, satellite.name);
      } else if (passProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(passProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No passes found in the next 72 hours'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showNextPassDialog(BuildContext context, PassPrediction pass, String satelliteName) {
    showDialog(
      context: context,
      builder: (context) => NextPassInfoDialog(
        pass: pass,
        satelliteName: satelliteName,
        onViewAllPasses: () {
          showDialog(
            context: context,
            builder: (context) => PassPredictionDialog(satellite: widget.satellite),
          );
        },
      ),
    );
  }

  Future<void> _updateTLE(BuildContext context, Satellite satellite) async {
    try {
      await context.read<SatelliteStateProvider>().refreshTLE(satellite.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TLE updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update TLE data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthStateProvider>();
    final isAdmin = authProvider.user?.isAdmin ?? false;

    return Consumer<SatelliteStateProvider>(
      builder: (context, provider, child) {
        final currentSatellite = provider.selectedSatellite ?? widget.satellite;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(
              currentSatellite.name,
              style: const TextStyle(fontSize: 18),
            ),
            actions: isAdmin
                ? [
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(context, value, currentSatellite),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'update',
                          child: Row(
                            children: [
                              Icon(Icons.refresh, size: 20),
                              SizedBox(width: 12),
                              Text('Update TLE'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Delete Satellite', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  color: Colors.black,
                  child: InteractiveGlobe3D(
                    satellites: [currentSatellite],
                    selectedSatellite: currentSatellite,
                    currentTime: _selectedPositionTime ?? DateTime.now(),
                    size: MediaQuery.of(context).size.width * 0.9,
                  ),
                ),

                SatellitePositionAccordion(
                  satellite: currentSatellite,
                  selectedTime: _selectedPositionTime,
                  onSelectTime: () => _selectPositionTime(context, currentSatellite),
                  onSetToNow: () => _setToNow(context, currentSatellite),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SatelliteInfoSection(satellite: currentSatellite),
                      const SizedBox(height: 16),
                      TLEInfoSection(satellite: currentSatellite),
                      const SizedBox(height: 24),
                      SatelliteActionsBar(
                        satellite: currentSatellite,
                        isAdmin: isAdmin,
                        onUpdateTLE: () => _updateTLE(context, currentSatellite),
                        onCalculatePasses: () {
                          showDialog(
                            context: context,
                            builder: (context) => PassPredictionDialog(
                              satellite: currentSatellite,
                            ),
                          );
                        },
                        onShowNextPass: () => _showNextPass(context, currentSatellite),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String value, Satellite satellite) async {
    switch (value) {
      case 'edit':
        await showDialog(
          context: context,
          builder: (context) => EditNameDialog(
            currentName: satellite.name,
            onSave: (newName) async {
              return await context.read<SatelliteStateProvider>().updateSatelliteName(
                id: satellite.id,
                name: newName,
              );
            },
          ),
        );
        break;
      case 'update':
        await _updateTLE(context, satellite);
        break;
      case 'delete':
        await _handleDelete(context, satellite);
        break;
    }
  }

  Future<void> _handleDelete(BuildContext context, Satellite satellite) async {
    final confirm = await DeleteConfirmationDialog.show(
      context,
      title: 'Delete Satellite',
      itemName: satellite.name,
    );

    if (confirm && context.mounted) {
      try {
        await context.read<SatelliteStateProvider>().deleteSatellite(satellite.id);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Satellite deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to delete satellite. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
