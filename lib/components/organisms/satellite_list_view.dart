import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/satellite_state_provider.dart';
import '../../providers/auth_state_provider.dart';
import '../../core/navigation/app_router.dart';
import '../molecules/satellite_card.dart';
import '../molecules/empty_state_message.dart';
import '../molecules/error_state_message.dart';
import 'pass_prediction_dialog.dart';

class SatelliteListView extends StatelessWidget {
  const SatelliteListView({super.key});

  void _handleDelete(BuildContext context, String id) async {
    try {
      await context.read<SatelliteStateProvider>().deleteSatellite(id);
      if (context.mounted) {
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
          SnackBar(
            content: Text('Failed to delete satellite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRefreshTLE(BuildContext context, String id) {
    context.read<SatelliteStateProvider>().refreshTLE(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing TLE data...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCalculatePass(BuildContext context, String id) {
    final provider = context.read<SatelliteStateProvider>();
    final satellite = provider.satellites.firstWhere((s) => s.id == id);
    
    showDialog(
      context: context,
      builder: (context) => PassPredictionDialog(satellite: satellite),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthStateProvider>();
    final isAdmin = authProvider.user?.isAdmin ?? false;

    return Consumer<SatelliteStateProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.satellites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading satellites...'),
              ],
            ),
          );
        }

        if (provider.error != null && provider.satellites.isEmpty) {
          return ErrorStateMessage(
            title: 'Failed to load satellites',
            message: provider.error!,
            onRetry: () => provider.loadSatellites(),
          );
        }

        if (provider.satellites.isEmpty) {
          return const EmptyStateMessage(
            icon: Icons.satellite_alt,
            title: 'No satellites yet',
            subtitle: 'Add a new satellite to get started',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadSatellites(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: provider.satellites.length,
            itemBuilder: (context, index) {
              final satellite = provider.satellites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SatelliteCard(
                  satellite: satellite,
                  isAdmin: isAdmin,
                  onTap: () {
                    provider.selectSatellite(satellite);
                    AppRouter.toSatelliteDetail(context, satellite);
                  },
                  onDelete: () => _handleDelete(context, satellite.id),
                  onRefreshTLE: () => _handleRefreshTLE(context, satellite.id),
                  onCalculatePass: () => _handleCalculatePass(context, satellite.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}