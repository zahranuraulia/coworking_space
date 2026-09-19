import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      if (onPressed == null || isLoading) {
        return variant == AppButtonVariant.outline
            ? Colors.transparent
            : AppColors.border;
      }
      switch (variant) {
        case AppButtonVariant.primary:
          return AppColors.primary;
        case AppButtonVariant.secondary:
          return AppColors.secondary;
        case AppButtonVariant.outline:
          return Colors.transparent;
        case AppButtonVariant.danger:
          return AppColors.error;
      }
    }

    Color getFgColor() {
      if (onPressed == null || isLoading) {
        return AppColors.textMuted;
      }
      switch (variant) {
        case AppButtonVariant.outline:
          return AppColors.primary;
        default:
          return Colors.white;
      }
    }

    BorderSide? getBorder() {
      if (variant == AppButtonVariant.outline) {
        return const BorderSide(color: AppColors.border, width: 1.5);
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getFgColor(),
          disabledBackgroundColor: variant == AppButtonVariant.outline
              ? Colors.transparent
              : const Color(0xFFE2E8F0),
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: getBorder() ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: getFgColor()),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: getFgColor(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
