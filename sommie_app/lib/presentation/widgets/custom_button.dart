import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: Size(
              width ?? double.infinity,
              height ?? AppConstants.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
            side: const BorderSide(color: AppConstants.primaryColor),
            minimumSize: Size(
              width ?? double.infinity,
              height ?? AppConstants.buttonHeight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          );

    if (isLoading) {
      return Container(
        width: width ?? double.infinity,
        height: height ?? AppConstants.buttonHeight,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppConstants.primaryColor.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: isPrimary ? null : Border.all(color: AppConstants.primaryColor),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
  }
}
