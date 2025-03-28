import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  danger
}

enum AppButtonSize {
  small,
  medium,
  large
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final bool iconAfterText;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.iconAfterText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button style based on type
    final ButtonStyle buttonStyle = _getButtonStyle();
    
    // Determine text style based on type and size
    final TextStyle textStyle = _getTextStyle(context);
    
    // Determine padding based on size
    final EdgeInsets padding = _getPadding();
    
    // Build button content
    Widget buttonContent = _buildButtonContent(textStyle);
    
    // Apply loading state if needed
    if (isLoading) {
      buttonContent = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.0,
            child: buttonContent,
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.outline || type == AppButtonType.text
                    ? AppColors.primary
                    : Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    
    // Build the button
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: Padding(
          padding: padding,
          child: buttonContent,
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.secondary.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case AppButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.primary.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        );
      case AppButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppColors.primary.withOpacity(0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.red.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: type == AppButtonType.primary || type == AppButtonType.secondary || type == AppButtonType.danger
          ? Colors.white
          : AppColors.primary,
    );
    
    switch (size) {
      case AppButtonSize.small:
        return baseStyle.copyWith(fontSize: 14);
      case AppButtonSize.medium:
        return baseStyle.copyWith(fontSize: 16);
      case AppButtonSize.large:
        return baseStyle.copyWith(fontSize: 18);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 16, horizontal: 32);
    }
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (icon == null) {
      return Text(text, style: textStyle);
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!iconAfterText) ...[
          Icon(icon, size: textStyle.fontSize! + 4),
          const SizedBox(width: 8),
        ],
        Text(text, style: textStyle),
        if (iconAfterText) ...[
          const SizedBox(width: 8),
          Icon(icon, size: textStyle.fontSize! + 4),
        ],
      ],
    );
  }
}

