import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';

class ProductField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> products;
  final Function(String) onProductSelected;
  
  const ProductField({
    super.key,
    required this.controller,
    required this.products,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return products.where((option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            controller.text = selection;
            onProductSelected(selection);
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            controller.text = fieldController.text;
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              validator: Validators.required('Product is required'),
              decoration: InputDecoration(
                hintText: 'e.g., Rice, Wheat, Corn',
                prefixIcon: const Icon(
                  Icons.agriculture_outlined,
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
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32, // Adjust width
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

