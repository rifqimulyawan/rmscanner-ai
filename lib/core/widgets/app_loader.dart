import 'package:flutter/material.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';

/// Tracks a background task and controls its loading dialog.
class BackgroundTaskHandle {
  bool isShowing = true;
  bool _runInBackground = false;
  BuildContext? dialogContext;

  /// Dismiss the loader dialog. The task continues running.
  void dismiss() {
    if (isShowing) {
      isShowing = false;
      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!).pop();
      }
    }
  }

  /// Called when user taps "Notify When Ready".
  /// Hides the dialog but keeps the task running.
  void runInBackground() {
    _runInBackground = true;
    dismiss();
  }

  /// Whether the user asked to be notified instead of watching.
  bool get userWantsNotification => _runInBackground;

  /// Update the loading message dynamically.
  void updateMessage(String newMessage) {
    // No-op: message is set at dialog creation time.
    // For dynamic updates, the caller should dismiss and re-show.
  }

  /// Show a success snackbar notification.
  /// Call this after the task completes when [userWantsNotification] is true.
  void notifySuccess(String message) {
    GlobalSnackBar.showSuccess(message);
  }

  /// Show an error snackbar notification.
  void notifyError(String message) {
    GlobalSnackBar.showError(message);
  }
}

Future<BackgroundTaskHandle> showAppLoader(
  BuildContext context, {
  String? message,
}) async {
  final loc = AppLocalizations.of(context);
  final msg = message ?? loc.tr('processing');
  final handle = BackgroundTaskHandle();
  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) {
      handle.dialogContext = ctx;
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: Dimensions.cardBlurRadius24,
                  offset: const Offset(0, Dimensions.cardShadowOffsetY12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: Dimensions.progressIndicatorSize,
                  height: Dimensions.progressIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.modalSpacing),
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: Styles.loaderTitle(context),
                ),
                const SizedBox(height: Dimensions.paddingSmall),
                Text(
                  loc.tr('may_take_a_while'),
                  textAlign: TextAlign.center,
                  style: Styles.loaderSubtitle(context),
                ),
                const SizedBox(height: Dimensions.modalSpacing),
                FilledButton(
                  onPressed: () => handle.runInBackground(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.01),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingLarge,
                      vertical: Dimensions.paddingSmall,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.fontSmallButton,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: Dimensions.iconSmall16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: Dimensions.gapSmall),
                      Text(
                        loc.tr('notify_when_ready'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).then((_) {
    if (handle.isShowing) {
      handle.runInBackground();
    }
  });
  return handle;
}
