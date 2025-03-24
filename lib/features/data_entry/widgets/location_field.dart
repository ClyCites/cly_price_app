import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';

class LocationField extends StatelessWidget {
  final TextEditingController controller;
  final bool useCurrentLocation;
  final Function(bool) onToggleLocation;
  
  const LocationField({
    super.key,
    required this.controller,
    required this.useCurrentLocation,
    required this.onToggleLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Use current location',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
                Switch(
                  value: useCurrentLocation,
                  onChanged: onToggleLocation,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !useCurrentLocation,
          validator: Validators.required('Location is required'),
          decoration: InputDecoration(
            hintText: 'e.g., Kampala, Uganda',
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: AppColors.textMedium,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

