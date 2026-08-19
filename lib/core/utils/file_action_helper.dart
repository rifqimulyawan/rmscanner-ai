import 'dart:io';
import 'package:rmscanner/core/widgets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/core/router/app_router.dart';
import 'package:rmscanner/core/utils/app_strings.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';

class FileActionHelper {
  static void showFileOptions(BuildContext context, FileModel file) {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      title: loc.tr('file_options'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(loc.tr('share')),
              onTap: () {
                Navigator.pop(context);
                shareFile(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(loc.tr('download')),
              onTap: () {
                Navigator.pop(context);
                downloadFile(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(loc.tr('rename')),
              onTap: () {
                Navigator.pop(context);
                renameFile(context, file);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                loc.tr('delete_confirm'),
                style: TextStyle(color: AppColors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                confirmDelete(context, file);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> shareFile(BuildContext context, FileModel file) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: AppStrings.sharedViaRmscanner,
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  static Future<void> downloadFile(BuildContext context, FileModel file) async {
    try {
      String downloadsPath = Platform.isAndroid
          ? '/storage/emulated/0/Download'
          : (await getApplicationDocumentsDirectory()).path;
      // Ensure unique filename
      String finalName = file.name;
      String newPath = '$downloadsPath/$finalName';
      int counter = 1;
      try {
        while (await File(newPath).exists()) {
          final extIndex = file.name.lastIndexOf('.');
          if (extIndex != -1) {
            final name = file.name.substring(0, extIndex);
            final ext = file.name.substring(extIndex);
            finalName = '${name}_($counter)$ext';
          } else {
            finalName = '${file.name}_($counter)';
          }
          newPath = '$downloadsPath/$finalName';
          counter++;
        }
      } catch (_) {
        // ignore exists Exception
        // Request storage permission specifically for Android < 11
        // On Android 11+ scoped storage allows writing to Download without permission.
        await Permission.storage.request();
      }
      await File(file.path).copy(newPath);
      if (context.mounted) {
        GlobalSnackBar.showSuccess(
          AppLocalizations.of(context).tr('saved_to_downloads'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('could_not_save_permission'),
        );
      }
    }
  }

  static void renameFile(BuildContext context, FileModel file) {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController(text: file.name.split('.').first);
    showCustomBottomSheet(
      context: context,
      useRootNavigator: true,
      title: loc.tr('rename'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: controller, autofocus: true),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(loc.tr('cancel')),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final newName =
                          '${controller.text}.${file.name.split('.').last}';
                      context.read<FilesBloc>().add(
                        RenameFile(file.id, newName),
                      );
                    }
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(loc.tr('rename')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void confirmDelete(BuildContext context, FileModel file) {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      useRootNavigator: true,
      title: loc.tr('delete_confirm'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(loc.tr('delete_confirmation').replaceAll('\$fileName', file.name)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(loc.tr('cancel')),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    context.read<FilesBloc>().add(DeleteFile(file.id));
                    Navigator.of(context, rootNavigator: true).pop();
                    final mc = rootNavigatorKey.currentContext;
                    if (mc != null) {
                      String tName;
                      switch (file.type) {
                        case FileType.pdf:
                          tName = AppStrings.typePdf;
                          break;
                        case FileType.image:
                          tName = AppStrings.typeImage;
                          break;
                        case FileType.text:
                          tName = AppStrings.typeText;
                          break;
                      }
                      GlobalSnackBar.showSuccess(
                        AppLocalizations.of(mc)
                            .tr('deleted_successfully')
                            .replaceAll('\$fileType', tName),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                  child: Text(loc.tr('delete_confirm')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
