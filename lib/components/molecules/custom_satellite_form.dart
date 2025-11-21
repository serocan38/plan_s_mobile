import 'package:flutter/material.dart';
import '../atoms/text_fields.dart';
import '../atoms/info_widgets.dart';

class CustomSatelliteForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController noradController;
  final bool isLoading;
  final VoidCallback? onSubmit;
  final GlobalKey<FormState> formKey;

  const CustomSatelliteForm({
    super.key,
    required this.nameController,
    required this.noradController,
    required this.isLoading,
    required this.formKey,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter satellite details manually',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            controller: nameController,
            labelText: 'Satellite Name',
            hintText: 'Ex: ISS (ZARYA)',
            prefixIcon: Icons.label_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Satellite name required';
              }
              return null;
            },
            enabled: !isLoading,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          AppFormField(
            controller: noradController,
            labelText: 'NORAD ID',
            hintText: 'Ex: 25544',
            prefixIcon: Icons.numbers,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'NORAD ID required';
              }
              if (int.tryParse(value.trim()) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            enabled: !isLoading,
            onFieldSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
          ),
          const SizedBox(height: 16),
          InfoBox.info(
            message: 'TLE data will be automatically fetched from Space-Track',
          ),
        ],
      ),
    );
  }
}
