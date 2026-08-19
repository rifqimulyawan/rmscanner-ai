import 'package:flutter/material.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool showCloseButton = true,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (title != null || showCloseButton) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    if (showCloseButton)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                        splashRadius: 24,
                      ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    ),
  );
}
