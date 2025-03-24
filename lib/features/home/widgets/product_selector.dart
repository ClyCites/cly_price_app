import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProductSelector extends StatelessWidget {
  final List<String> products;
  final String selectedProduct;
  final Function(String) onProductChanged;

  const Product


Selector({
    super.key,
    required this.products,
    required this.selectedProduct,
    required this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedProduct,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          items: products.map((String product) {
            return DropdownMenuItem<String>(
              value: product,
              child: Text(product),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onProductChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}

