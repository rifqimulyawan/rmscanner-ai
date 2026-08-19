import 'package:flutter/material.dart';
import 'package:rmscanner/core/constants/app_colors.dart';

class GlobalSnackBar {
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();
  static void showSuccess(String message) {
    if (key.currentState == null) return;
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          backgroundColor: AppColors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void showError(String message) {
    if (key.currentState == null) return;
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  static void show(String message) {
    if (key.currentState == null) return;
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          backgroundColor: AppColors.grey900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  static OverlayEntry? _overlayEntry;

  static void _showOverlay(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon, {
    int duration = 3,
  }) {
    _overlayEntry?.remove();
    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    _overlayEntry = entry;
    Future.delayed(Duration(seconds: duration), () {
      entry.remove();
      if (_overlayEntry == entry) _overlayEntry = null;
    });
  }

  static void showSuccessOverlay(BuildContext context, String message) {
    _showOverlay(context, message, AppColors.blueAccent, Icons.check_circle_rounded);
  }

  static void showErrorOverlay(BuildContext context, String message) {
    _showOverlay(context, message, AppColors.red, Icons.error_rounded, duration: 4);
  }
}
