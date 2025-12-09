import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackType { info, success, error, warning }

void showThemedSnack(
  BuildContext context,
  String message, {
  SnackType type = SnackType.info,
  Duration? duration,
}) {
  IconData icon;
  Color color;

  switch (type) {
    case SnackType.success:
      icon = Icons.check_circle_outline;
      color = AppTheme.successGreen;
      break;
    case SnackType.error:
      icon = Icons.error_outline;
      color = AppTheme.errorRed;
      break;
    case SnackType.warning:
      icon = Icons.report_problem_outlined;
      color = AppTheme.accentBlue;
      break;
    case SnackType.info:
      icon = Icons.info_outline;
      color = AppTheme.yellowForeground;
      break;
  }

  final snack = SnackBar(
    content: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ],
    ),
    backgroundColor: AppTheme.cardBackground,
    margin: const EdgeInsets.all(12),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: color, width: 1.5),
    ),
    duration: duration ?? const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snack);
}
