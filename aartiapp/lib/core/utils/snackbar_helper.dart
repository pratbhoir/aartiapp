import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Centralized helper for semantic, theme-aligned snackbar feedback.
abstract final class SnackBarHelper {
  static const Duration _successDuration = Duration(milliseconds: 1500);
  static const Duration _errorDuration = Duration(seconds: 3);
  static const Duration _warningDuration = Duration(seconds: 4);
  static const Duration _infoDuration = Duration(seconds: 2);

  /// Shows a success snackbar for completed actions.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.snackBarSuccess,
      icon: Icons.check_circle_rounded,
      duration: duration ?? _successDuration,
      action: action,
    );
  }

  /// Shows an error snackbar for validation or submission failures.
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.snackBarError,
      icon: Icons.error_rounded,
      duration: duration ?? _errorDuration,
      action: action,
    );
  }

  /// Shows a warning snackbar for cautionary or destructive acknowledgements.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.snackBarWarning,
      icon: Icons.warning_rounded,
      duration: duration ?? _warningDuration,
      action: action,
    );
  }

  /// Shows an informational snackbar for neutral notices.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.snackBarInfo,
      icon: Icons.info_rounded,
      duration: duration ?? _infoDuration,
      action: action,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        duration: duration,
        content: Row(
          children: <Widget>[
            const SizedBox(width: AppSpacing.xxs),
            Icon(icon, color: AppColors.white, size: AppSpacing.lgWide),
            const SizedBox(width: AppSpacing.smWide),
            Expanded(child: Text(message)),
          ],
        ),
        action: action == null
            ? null
            : SnackBarAction(
                label: action.label,
                onPressed: action.onPressed,
                textColor: AppColors.white,
              ),
      ),
    );
  }
}
