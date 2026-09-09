import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class DialogActionButton extends StatelessWidget {
  const DialogActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        disabledForegroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        textStyle: AppTextStyles.action,
      ),
      child: Text(label),
    );
  }
}
