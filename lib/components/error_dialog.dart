import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppTheme.yellowForeground),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.yellowForeground, width: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            'OK',
            style: TextStyle(color: AppTheme.yellowForeground),
          ),
        ),
      ],
    );
  }
}
