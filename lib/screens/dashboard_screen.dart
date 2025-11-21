import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/satellite_state_provider.dart';
import '../providers/auth_state_provider.dart';
import '../core/navigation/app_router.dart';
import '../components/organisms/satellite_list_view.dart';
import '../components/templates/list_template.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadSatellites();
  }

  void _loadSatellites() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SatelliteStateProvider>().loadSatellites();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthStateProvider>().logout();
      if (context.mounted) {
        AppRouter.toLogin(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthStateProvider>();
    final isAdmin = authProvider.user?.isAdmin ?? false;

    return ListTemplate(
      title: 'Plan-S',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () => _handleLogout(context),
        ),
      ],
      body: const SatelliteListView(),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => AppRouter.showAddSatelliteDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Satellite'),
            )
          : null,
    );
  }
}
