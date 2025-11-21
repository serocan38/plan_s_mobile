import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/satellite.dart';
import '../../models/pass_prediction.dart';
import '../../providers/pass_state_provider.dart';
import '../../core/navigation/app_router.dart';

class PassPredictionDialog extends StatefulWidget {
  final Satellite satellite;

  const PassPredictionDialog({
    super.key,
    required this.satellite,
  });

  @override
  State<PassPredictionDialog> createState() => _PassPredictionDialogState();
}

class _PassPredictionDialogState extends State<PassPredictionDialog> {
  final TextEditingController _latController = TextEditingController(text: '41.0082');
  final TextEditingController _lonController = TextEditingController(text: '28.9784');
  final TextEditingController _altController = TextEditingController(text: '0.05');
  double _minElevation = 10.0;
  int _maxPasses = 5;

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _altController.dispose();
    super.dispose();
  }

  void _predictPasses() {
    final latitude = double.tryParse(_latController.text);
    final longitude = double.tryParse(_lonController.text);
    final altitude = double.tryParse(_altController.text);


    if (latitude == null || longitude == null || altitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid coordinates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (latitude < -90 || latitude > 90) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latitude must be between -90 and 90'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (longitude < -180 || longitude > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Longitude must be between -180 and 180'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final groundLocation = GroundLocation(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
    );

    context.read<PassStateProvider>().predictPasses(
          noradId: widget.satellite.noradId,
          groundLocation: groundLocation,
          minElevation: _minElevation,
          maxPasses: _maxPasses,
          searchHours: 72,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationInputs(),
                    const SizedBox(height: 20),
                    _buildSettings(),
                    const SizedBox(height: 20),
                    _buildPredictButton(),
                    const SizedBox(height: 20),
                    _buildResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.satellite_alt,
            color: Colors.blue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pass Predictions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.satellite.name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => AppRouter.goBack(context),
        ),
      ],
    );
  }

  Widget _buildLocationInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ground Location',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _latController,
          label: 'Latitude (°)',
          hint: 'e.g., 41.0082',
          icon: Icons.place,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _lonController,
          label: 'Longitude (°)',
          hint: 'e.g., 28.9784',
          icon: Icons.place,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _altController,
          label: 'Altitude (km)',
          hint: 'e.g., 0.05',
          icon: Icons.height,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: Colors.blue.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          label: 'Min Elevation',
          value: _minElevation,
          min: 0,
          max: 45,
          divisions: 9,
          suffix: '°',
          onChanged: (value) => setState(() => _minElevation = value),
        ),
        const SizedBox(height: 12),
        _buildSlider(
          label: 'Max Passes',
          value: _maxPasses.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          suffix: '',
          onChanged: (value) => setState(() => _maxPasses = value.round()),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            Text(
              '${value.toStringAsFixed(suffix == '°' ? 1 : 0)}$suffix',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Colors.blue,
          inactiveColor: Colors.blue.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPredictButton() {
    return Consumer<PassStateProvider>(
      builder: (context, passProvider, _) {
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: passProvider.isLoading ? null : _predictPasses,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: passProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.calculate),
            label: Text(
              passProvider.isLoading ? 'Calculating...' : 'Predict Passes',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    return Consumer<PassStateProvider>(
      builder: (context, passProvider, _) {
        if (passProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    passProvider.error ?? 'Unable to load pass predictions',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }

        if (passProvider.passes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Predicted Passes',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${passProvider.passes.length} found',
                  style: TextStyle(
                    color: Colors.blue.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...passProvider.passes.map((pass) => _buildPassCard(pass)),
          ],
        );
      },
    );
  }

  Widget _buildPassCard(PassPrediction pass) {
    final dateFormat = DateFormat('MMM dd, HH:mm:ss');
    final timeFormat = DateFormat('HH:mm:ss');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AOS: ${dateFormat.format(pass.aos)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pass.maxElevationFormatted,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPassDetail('TCA', timeFormat.format(pass.tca)),
          _buildPassDetail('LOS', timeFormat.format(pass.los)),
          const Divider(color: Colors.white24, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPassDetail('Duration', pass.durationFormatted),
              _buildPassDetail('Max Elevation', pass.maxElevationFormatted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
