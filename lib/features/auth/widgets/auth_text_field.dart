import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive sizing
    final size = MediaQuery.of(context).size;
    final labelSize = size.width * 0.035; // Relative label size
    final fieldHeight = size.height * 0.07; // Relative field height
    final iconSize = size.width * 0.05; // Relative icon size
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: labelSize,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        SizedBox(
          height: fieldHeight,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(fontSize: labelSize * 1.1),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: labelSize * 1.1),
              prefixIcon: Icon(
                prefixIcon,
                color: AppColors.textMedium,
                size: iconSize,
              ),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.015,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

