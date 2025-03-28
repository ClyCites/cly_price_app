import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/product.dart';

class ProductSelector extends StatelessWidget {
  final List<Product> products;
  final String selectedProductId;
  final Function(String, String) onProductChanged;

  const ProductSelector({
    super.key,
    required this.products,
    required this.selectedProductId,
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
          value: selectedProductId.isEmpty && products.isNotEmpty 
              ? products.first.id 
              : selectedProductId,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          items: products.map((Product product) {
            return DropdownMenuItem<String>(
              value: product.id,
              child: Text(product.name),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              // Find the product name for the selected ID
              final selectedProduct = products.firstWhere(
                (product) => product.id == newValue,
                orElse: () => products.first,
              );
              onProductChanged(newValue, selectedProduct.name);
            }
          },
        ),
      ),
    );
  }
}

