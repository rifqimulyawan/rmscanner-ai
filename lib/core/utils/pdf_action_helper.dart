import 'dart:io';
import 'dart:ui' as ui;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:rmscanner/core/utils/app_strings.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/widgets/custom_bottom_sheet.dart';
import 'package:rmscanner/core/widgets/app_loader.dart';
import 'package:rmscanner/core/services/pdf_service.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/core/services/preferences_service.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:pdf/pdf.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmscanner/core/router/app_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:rmscanner/core/services/ocr_service.dart';
import 'package:rmscanner/features/tools/presentation/pages/signature_position_screen.dart';
import 'package:rmscanner/features/tools/presentation/pages/draw_signature_screen.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';

class PdfActionHelper {
  static Future<PdfPageFormat> _getPreferredPageSize() async {
    final prefs = PreferencesService();
    final size = await prefs.getDefaultPageSize();
    switch (size) {
      case 'Letter':
        return PdfPageFormat.letter;
      case 'Legal':
        return PdfPageFormat.legal;
      default:
        return PdfPageFormat.a4;
    }
  }

  static List<int> _parsePageRange(String input, int totalPages) {
    final Set<int> indexes = {};

    final parts = input.split(',');
    for (var part in parts) {
      part = part.trim();
      if (part.contains('-')) {
        final rangeParts = part.split('-');
        if (rangeParts.length == 2) {
          final start = int.tryParse(rangeParts[0].trim());
          final end = int.tryParse(rangeParts[1].trim());
          if (start != null && end != null) {
            final realStart = start.clamp(1, totalPages);
            final realEnd = end.clamp(1, totalPages);
            final low = realStart < realEnd ? realStart : realEnd;
            final high = realStart < realEnd ? realEnd : realStart;
            for (int i = low; i <= high; i++) {
              indexes.add(i - 1);
            }
          }
        }
      } else {
        final page = int.tryParse(part);
        if (page != null) {
          final realPage = page.clamp(1, totalPages);
          indexes.add(realPage - 1);
        }
      }
    }
    final sortedList = indexes.toList()..sort();
    return sortedList;
  }

  /// Centralized task completion. Uses notify SnackBar if user dismissed early, else plain SnackBar.
  static void _completeTask(
    BackgroundTaskHandle loader,
    String successMessage,
  ) {
    loader.dismiss();
    final mc = rootNavigatorKey.currentContext;
    if (mc == null) return;
    mc.read<FilesBloc>().add(LoadFiles());
    if (loader.userWantsNotification) {
      loader.notifySuccess(successMessage);
    } else {
      GlobalSnackBar.showSuccess(successMessage);
    }
  }

  static void _errorTask(BackgroundTaskHandle loader, String message) {
    loader.dismiss();
    if (loader.userWantsNotification) {
      loader.notifyError(message);
    } else {
      final mc = rootNavigatorKey.currentContext;
      if (mc != null) {
        GlobalSnackBar.showError(message);
      }
    }
  }

  static Future<TextRecognizer> _getPreferredRecognizer() async {
    final prefs = PreferencesService();
    final lang = await prefs.getOcrLanguage();
    switch (lang) {
      case 'Hindi':
        return TextRecognizer(script: TextRecognitionScript.devanagiri);
      case 'Chinese':
        return TextRecognizer(script: TextRecognitionScript.chinese);
      default:
        return TextRecognizer(script: TextRecognitionScript.latin);
    }
  }

  static Future<void> textToPdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();
    final text = await showCustomBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      title: AppStrings.textToPdf,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: AppStrings.enterTextHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(controller.text),
                  child: const Text(AppStrings.create),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (text == null || text.isEmpty) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final format = await _getPreferredPageSize();
      final fileName = 'text_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.createPdfFromText(
        text,
        path,
        format: format,
      );
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: path,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['text'],
        ),
      );
      _completeTask(loader, loc.tr('pdf_created_successfully'));
    } catch (e, st) {
      debugPrint('Text to PDF error: $e');
      debugPrint('$st');
      _errorTask(loader, loc.tr('text_to_pdf_error'));
    }
  }

  static Future<void> imageToPdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty || !context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final format = await _getPreferredPageSize();
      final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.createPdfFromImages(
        images.map((i) => i.path).toList(),
        path,
        format: format,
      );
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: path,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['converted'],
        ),
      );
      _completeTask(loader, loc.tr('image_to_pdf_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> mergePdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.length < 2) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final inputPaths = result.files.map((f) => f.path!).toList();
      final fileName = 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.mergePdfs(inputPaths, outputPath);
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['merged'],
        ),
      );
      _completeTask(loader, loc.tr('pdfs_merged_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> splitPdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    if (!context.mounted) return;
    // Show immediate loader for pre-checks
    final preLoader = await showAppLoader(context);
    int totalPages = 0;
    try {
      totalPages = await PdfService().getPdfPageCount(path);
      preLoader.dismiss();
    } catch (e) {
      preLoader.dismiss();
      // Continue and let it fail later or show error
    }
    if (!context.mounted) return;
    final controller = TextEditingController();
    final pageRange = await showCustomBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      title: AppStrings.splitPdf,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: AppStrings.pageRangeLabel,
                hintText: AppStrings.pageRangeHint,
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(AppLocalizations.of(context).tr('cancel')),
                ),
                const Gap(8),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(controller.text),
                  child: const Text(AppStrings.split),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (pageRange == null || pageRange.isEmpty) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final List<int> indexes = _parsePageRange(pageRange, totalPages);
      if (indexes.isEmpty) {
        loader.dismiss();
        final mc = rootNavigatorKey.currentContext;
        if (mc != null && mc.mounted) {
          GlobalSnackBar.showError(
            AppLocalizations.of(mc).tr('invalid_page_range'),
          );
        }
        return;
      }
      final fileName = 'split_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.splitPdf(
        result.files.single.path!,
        outputPath,
        indexes,
      );
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['split'],
        ),
      );
      _completeTask(loader, loc.tr('pdf_split_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> compressPdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    if (!context.mounted) return;
    final int? q = await showCustomBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      title: AppStrings.compressionQuality,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: const Text(AppStrings.compressLow),
              onTap: () => Navigator.of(context, rootNavigator: true).pop(90),
            ),
            ListTile(
              leading: const Icon(Icons.shutter_speed_outlined),
              title: const Text(AppStrings.compressMedium),
              onTap: () => Navigator.of(context, rootNavigator: true).pop(70),
            ),
            ListTile(
              leading: const Icon(Icons.compress),
              title: const Text(AppStrings.compressHigh),
              onTap: () => Navigator.of(context, rootNavigator: true).pop(40),
            ),
          ],
        ),
      ),
    );
    if (q == null) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final fileName = 'comp_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.compressPdf(
        result.files.single.path!,
        outputPath,
        q,
      );
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['compressed'],
        ),
      );
      _completeTask(loader, loc.tr('pdf_compressed_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> rotatePdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    if (!context.mounted) return;
    // Show immediate loader as feedback
    final preLoader = await showAppLoader(context);
    await Future.delayed(const Duration(milliseconds: 200));
    // Tiny delay for visual consistency
    preLoader.dismiss();
    if (!context.mounted) return;
    final int? angle = await showCustomBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      title: AppStrings.rotationAngle,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.rotate_90_degrees_ccw),
              title: const Text(AppStrings.rotate90CW),
              onTap: () => Navigator.of(context, rootNavigator: true).pop(90),
            ),
            ListTile(
              leading: const Icon(Icons.rotate_right),
              title: const Text(AppStrings.rotate180),
              onTap: () => Navigator.of(context, rootNavigator: true).pop(180),
            ),
            ListTile(
              leading: const Icon(Icons.rotate_90_degrees_cw_outlined),
              title: const Text(AppStrings.rotate270CW),
              onTap: () => Navigator.of(context, rootNavigator: true).pop(270),
            ),
          ],
        ),
      ),
    );
    if (angle == null) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final fileName = 'rot_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.rotatePdf(path, outputPath, angle);
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['rotated'],
        ),
      );
      _completeTask(loader, loc.tr('pdf_rotated_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> lockPdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    if (!context.mounted) return;
    // Show immediate loader for checks
    final preLoader = await showAppLoader(context);
    final isAlreadyEncrypted = await PdfService().isPdfEncrypted(path);
    preLoader.dismiss();
    if (isAlreadyEncrypted && context.mounted) {
      GlobalSnackBar.showError(
        AppLocalizations.of(context).tr('already_protected'),
      );
      return;
    }
    if (!context.mounted) return;
    final controller = TextEditingController();
    final password = await showCustomBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      title: AppStrings.lockPdf,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(AppStrings.enterPasswordToProtect),
            const Gap(16),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: AppStrings.password,
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                const Gap(8),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(controller.text),
                  child: const Text(AppStrings.lock),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final fileService = FileService();
      final fileName = 'locked_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      final file = await PdfService().lockPdf(
        result.files.single.path!,
        outputPath,
        password,
      );
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['locked'],
        ),
      );
      _completeTask(loader, loc.tr('pdf_locked_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> unlockPdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    if (!context.mounted) return;
    // Show immediate loader for checks
    final preLoader = await showAppLoader(context);
    final isEncrypted = await PdfService().isPdfEncrypted(path);
    preLoader.dismiss();
    if (!isEncrypted && context.mounted) {
      GlobalSnackBar.showError(
        AppLocalizations.of(context).tr('not_protected'),
      );
      return;
    }
    if (!context.mounted) return;
    final controller = TextEditingController();
    final password = await showCustomBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      title: AppStrings.unlockPdf,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(AppStrings.enterPasswordToUnlock),
            const Gap(16),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: AppStrings.password,
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                const Gap(8),
                FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(controller.text),
                  child: const Text(AppStrings.unlock),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final fileService = FileService();
      final fileName = 'unlocked_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      final file = await PdfService().unlockPdf(
        result.files.single.path!,
        outputPath,
        password,
      );
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['unlocked'],
        ),
      );
      _completeTask(loader, loc.tr('pdf_unlocked_success'));
    } catch (e) {
      loader.dismiss();
      final message =
          e.toString().toLowerCase().contains('password') ||
              e.toString().toLowerCase().contains('incorrect')
          ? loc.tr('incorrect_password')
          : loc.tr('failed_to_unlock');
      if (loader.userWantsNotification) {
        loader.notifyError(message);
      } else {
        final mc = rootNavigatorKey.currentContext;
        if (mc != null) {
          GlobalSnackBar.showError(message);
        }
      }
    }
  }

  static Future<void> pdfToImage(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final appDir = await getApplicationDocumentsDirectory();
      final paths = await pdfService.pdfToImages(
        result.files.single.path!,
        '${appDir.path}/ocr_temp',
      );
      for (var p in paths) {
        final f = File(p);
        await fileService.saveFile(
          FileModel(
            id: const Uuid().v4(),
            name: 'page_${DateTime.now().millisecondsSinceEpoch}.jpg',
            path: p,
            type: FileType.image,
            createdAt: DateTime.now(),
            sizeInBytes: await f.length(),
          ),
        );
      }
      _completeTask(loader, loc.tr('pdf_to_image_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> imageToText(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    // Show source chooser: Gallery or Camera
    final ImageSource? source = await showCustomBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      title: AppStrings.selectImageSource,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(AppStrings.gallery),
              subtitle: const Text(AppStrings.pickFromGallery),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(AppStrings.camera),
              subtitle: const Text(AppStrings.captureNewPhoto),
              onTap: () => Navigator.of(
                context,
                rootNavigator: true,
              ).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 100);
    if (image == null) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = await _getPreferredRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();
      final sortedText = OcrService.buildSortedText(recognizedText.blocks);
      _completeTask(loader, loc.tr('text_extracted_success'));
      final mc = rootNavigatorKey.currentContext;
      if (mc != null && mc.mounted) {
        mc.pushNamed(
          'ocr-result',
          extra: {
            'text': sortedText,
            'wordCount': sortedText.split(' ').length,
            'characterCount': sortedText.length,
          },
        );
      }
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> pdfToText(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;
    final loader = await showAppLoader(context);
    try {
      final appDir = await getTemporaryDirectory();
      final tempDir = Directory('${appDir.path}/ocr_temp');
      if (!await tempDir.exists()) await tempDir.create(recursive: true);
      String combinedText = '';
      final textRecognizer = await _getPreferredRecognizer();
      final bytes = await File(result.files.single.path!).readAsBytes();
      int pageCounter = 0;
      // We read one page, convert to PNG, run OCR, and delete the temp file immediately
      // This enforces backpressure so `Printing.raster` doesn't burn Native memory out.
      await for (var page in Printing.raster(bytes, dpi: 200)) {
        // 200 DPI for accurate OCR
        pageCounter++;
        final uiImage = await page.toImage();
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        uiImage.dispose();
        // CRITICAL memory free!
        if (byteData != null) {
          final tempPath = '${tempDir.path}/temp_page_$pageCounter.png';
          await File(
            tempPath,
          ).writeAsBytes(byteData.buffer.asUint8List(), flush: true);
          final RecognizedText recognizedText = await textRecognizer
              .processImage(InputImage.fromFilePath(tempPath));
          final sortedPageText = OcrService.buildSortedText(
            recognizedText.blocks,
          );
          if (sortedPageText.trim().isNotEmpty) {
            combinedText += '$sortedPageText\n\n';
          }
          try {
            await File(tempPath).delete();
          } catch (_) {
            // ignore deletion errors
          }
        }
      }
      await textRecognizer.close();
      _completeTask(loader, loc.tr('pdf_to_text_success'));
      final mc = rootNavigatorKey.currentContext;
      if (mc != null && mc.mounted) {
        mc.pushNamed(
          'ocr-result',
          extra: {
            'text': combinedText,
            'wordCount': combinedText
                .split(RegExp(r'\s+'))
                .where((e) => e.isNotEmpty)
                .length,
            'characterCount': combinedText.length,
          },
        );
      }
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> signatureFlow(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    // 1. Draw signature on dedicated screen
    if (!context.mounted) return;
    final Uint8List? signatureBytes = await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const DrawSignatureScreen()));
    if (signatureBytes == null || signatureBytes.isEmpty) return;
    // 2. Position Signature
    if (!context.mounted) return;
    final String sourcePath = result.files.single.path!;
    final bool isPdf = sourcePath.toLowerCase().endsWith('.pdf');
    final Map<String, dynamic>? positionData =
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => SignaturePositionScreen(
              file: File(sourcePath),
              signatureBytes: signatureBytes,
              isPdf: isPdf,
            ),
          ),
        );
    if (positionData == null || !context.mounted) return;
    // 3. Process and Save
    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = isPdf ? 'pdf' : 'jpg';
      final fileName = 'signed_$timestamp.$ext';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      File finalFile;
      if (isPdf) {
        finalFile = await pdfService.addSignatureToPdf(
          sourcePath,
          outputPath,
          signatureBytes,
          xPercent: positionData['xPercent'],
          yPercent: positionData['yPercent'],
          widthPercent: positionData['widthPercent'],
          heightPercent: positionData['heightPercent'],
          pageIndex: positionData['pageIndex'] ?? 0,
        );
      } else {
        finalFile = await pdfService.addSignatureToImage(
          sourcePath,
          outputPath,
          signatureBytes,
          xPercent: positionData['xPercent'],
          yPercent: positionData['yPercent'],
          widthPercent: positionData['widthPercent'],
          heightPercent: positionData['heightPercent'],
        );
      }
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: isPdf ? FileType.pdf : FileType.image,
          createdAt: DateTime.now(),
          sizeInBytes: await finalFile.length(),
          tags: ['signed'],
        ),
      );
      _completeTask(loader, loc.tr('signature_saved'));
    } catch (e) {
      _errorTask(loader, loc.tr('error_prefix'));
    }
  }

  static Future<void> addWatermark(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;
    final sourcePath = result.files.single.path!;
    if (!context.mounted) return;

    final settings = await _showWatermarkDialog(context, loc, sourcePath);
    if (settings == null || settings.text.isEmpty) return;
    if (!context.mounted) return;

    final loader = await showAppLoader(context);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = settings.overwrite
          ? result.files.single.name
          : 'watermarked_$timestamp.pdf';
      final outputPath = settings.overwrite
          ? sourcePath
          : await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.addWatermark(
        sourcePath,
        outputPath,
        text: settings.text,
        opacity: settings.opacity,
        fontSize: settings.fontSize,
        rotation: settings.rotation,
        color: settings.color,
        isBold: settings.isBold,
        isItalic: settings.isItalic,
        isTiled: settings.isTiled,
        fontFamily: settings.fontFamily,
      );
      if (!settings.overwrite) {
        await fileService.saveFile(
          FileModel(
            id: const Uuid().v4(),
            name: fileName,
            path: outputPath,
            type: FileType.pdf,
            createdAt: DateTime.now(),
            sizeInBytes: await file.length(),
            tags: ['watermark'],
          ),
        );
      }
      _completeTask(loader, loc.tr('watermark_success'));
    } catch (e) {
      _errorTask(loader, loc.tr('watermark_error'));
    }
  }

  static Future<_WatermarkSettings?> _showWatermarkDialog(
    BuildContext context,
    AppLocalizations loc,
    String sourcePath,
  ) async {
    final controller = TextEditingController();
    double opacity = 0.3;
    double fontSize = 50;
    double rotation = -45;
    int colorIndex = 0;
    bool isBold = false;
    bool isItalic = false;
    bool isTiled = false;
    String? errorMessage;
    int fontFamilyIndex = 0;
    Uint8List? pagePreview;
    bool isLoadingPreview = true;
    final fontFamilies = <Map<String, String?>>[
      {'name': 'Helvetica', 'pdfFamily': 'helvetica', 'dartFont': null},
      {'name': 'Times', 'pdfFamily': 'times', 'dartFont': 'serif'},
      {'name': 'Courier', 'pdfFamily': 'courier', 'dartFont': 'monospace'},
    ];
    final colors = [
      Colors.grey,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.black,
    ];
    // Render first page of the PDF in background
    PdfService().renderFirstPage(sourcePath).then((bytes) {
      if (bytes != null) {
        pagePreview = bytes;
      }
      isLoadingPreview = false;
    });

    return showDialog<_WatermarkSettings>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            // Check if preview loaded after first render
            if (isLoadingPreview && pagePreview != null) {
              isLoadingPreview = false;
            }
            return AlertDialog(
              title: Text(loc.tr('watermark_pdf')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: loc.tr('watermark_text'),
                        hintText: loc.tr('watermark_text_hint'),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (errorMessage != null) {
                          setState(() => errorMessage = null);
                        } else {
                          setState(() {});
                        }
                      },
                    ),
                    const Gap(12),
                    // Preview - rendered PDF page with watermark overlay
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: isLoadingPreview && pagePreview == null
                          ? const Center(child: CircularProgressIndicator())
                          : LayoutBuilder(
                              builder: (ctx, constraints) {
                                final previewText = controller.text.isEmpty
                                    ? loc.tr('watermark_text_hint')
                                    : controller.text;
                                final previewFontSize = fontSize * 0.3;
                                final previewColor = colors[colorIndex].withValues(alpha: opacity);
                                final previewStyle = TextStyle(
                                  fontSize: previewFontSize,
                                  color: previewColor,
                                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                                  fontFamily: fontFamilies[fontFamilyIndex]['dartFont'] == 'serif'
                                      ? 'serif'
                                      : fontFamilies[fontFamilyIndex]['dartFont'] == 'monospace'
                                          ? 'monospace'
                                          : null,
                                );
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // PDF page background
                                    if (pagePreview != null)
                                      Positioned.fill(
                                        child: FittedBox(
                                          fit: BoxFit.cover,
                                          child: Image.memory(
                                            pagePreview!,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(color: Colors.white),
                                    // Watermark overlay
                                    if (isTiled)
                                      ClipRect(
                                        child: Transform.rotate(
                                          angle: rotation * 3.14159 / 180,
                                          child: Wrap(
                                            runSpacing: previewFontSize * 1.5,
                                            spacing: previewFontSize * 2,
                                            children: List.generate(40, (i) => Text(
                                              previewText,
                                              style: previewStyle,
                                            )),
                                          ),
                                        ),
                                      )
                                    else
                                      Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Transform.rotate(
                                            angle: rotation * 3.14159 / 180,
                                            child: Text(
                                              previewText,
                                              style: previewStyle,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const Gap(12),
                    // Color selection
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: colors.length,
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => setState(() => colorIndex = i),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colors[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorIndex == i
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    // Font family dropdown
                    DropdownButtonFormField<int>(
                      initialValue: fontFamilyIndex,
                      decoration: InputDecoration(
                        labelText: loc.tr('watermark_font'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: fontFamilies.asMap().entries.map((e) {
                        final ff = e.value;
                        return DropdownMenuItem<int>(
                          value: e.key,
                          child: Text(ff['name'] as String,
                            style: TextStyle(
                              fontFamily: ff['dartFont'],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => fontFamilyIndex = v ?? 0),
                    ),
                    const Gap(8),
                    // Bold toggle
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.tr('watermark_bold'), style: const TextStyle(fontSize: 13)),
                      value: isBold,
                      onChanged: (v) => setState(() => isBold = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    // Italic toggle
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.tr('watermark_italic'), style: const TextStyle(fontSize: 13)),
                      value: isItalic,
                      onChanged: (v) => setState(() => isItalic = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    // Tiled style toggle
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.tr('watermark_tiled'), style: const TextStyle(fontSize: 13)),
                      value: isTiled,
                      onChanged: (v) => setState(() => isTiled = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    Text('${loc.tr('watermark_opacity')}: ${(opacity * 100).toInt()}%'),
                    Slider(
                      value: opacity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      onChanged: (v) => setState(() => opacity = v),
                    ),
                    Text('${loc.tr('watermark_font_size')}: ${fontSize.toInt()}'),
                    Slider(
                      value: fontSize,
                      min: 20,
                      max: 100,
                      divisions: 8,
                      onChanged: (v) => setState(() => fontSize = v),
                    ),
                    Text('${loc.tr('watermark_rotation')}: ${rotation.toInt()}°'),
                    Slider(
                      value: rotation,
                      min: -90,
                      max: 90,
                      divisions: 18,
                      onChanged: (v) => setState(() => rotation = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(loc.tr('cancel')),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      setState(() => errorMessage = loc.tr('watermark_text_empty'));
                      return;
                    }
                    Navigator.pop(
                      ctx,
                      _WatermarkSettings(
                        text: controller.text,
                        opacity: opacity,
                        fontSize: fontSize,
                        rotation: rotation,
                        color: colors[colorIndex],
                        isBold: isBold,
                        isItalic: isItalic,
                        isTiled: isTiled,
                        fontFamily: fontFamilies[fontFamilyIndex]['pdfFamily'] as String,
                        overwrite: true,
                      ),
                    );
                  },
                  child: Text(loc.tr('save')),
                ),
                FilledButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      setState(() => errorMessage = loc.tr('watermark_text_empty'));
                      return;
                    }
                    Navigator.pop(
                      ctx,
                      _WatermarkSettings(
                        text: controller.text,
                        opacity: opacity,
                        fontSize: fontSize,
                        rotation: rotation,
                        color: colors[colorIndex],
                        isBold: isBold,
                        isItalic: isItalic,
                        isTiled: isTiled,
                        fontFamily: fontFamilies[fontFamilyIndex]['pdfFamily'] as String,
                        overwrite: false,
                      ),
                    );
                  },
                  child: Text(loc.tr('save_as_copy')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> reorderPages(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;
    final sourcePath = result.files.single.path!;
    if (!context.mounted) return;

    final loader = await showAppLoader(context);
    BackgroundTaskHandle? loader2;
    try {
      final pdfService = PdfService();
      final thumbnails = await pdfService.getPageThumbnails(sourcePath);
      loader.dismiss();
      if (!context.mounted) return;

      final navResult = await Navigator.of(context, rootNavigator: true).push<
        (List<int>, bool)
      >(
        MaterialPageRoute(
          builder: (_) => _ReorderPagesScreen(
            thumbnails: thumbnails,
            loc: loc,
          ),
        ),
      );
      if (navResult == null || navResult.$1.isEmpty) return;
      if (!context.mounted) return;

      final pageOrder = navResult.$1;
      final overwrite = navResult.$2;
      loader2 = await showAppLoader(context);
      final fileService = FileService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = overwrite
          ? result.files.single.name
          : 'reordered_$timestamp.pdf';
      final outputPath = overwrite
          ? sourcePath
          : await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.reorderPages(
        sourcePath,
        outputPath,
        pageOrder,
      );
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.pdf,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['reorder'],
        ),
      );
      _completeTask(loader2, loc.tr('reorder_success'));
    } catch (e) {
      loader2?.dismiss();
      loader.dismiss();
      _errorTask(loader, loc.tr('reorder_error'));
    }
  }

  static Future<void> batchOcr(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final picker = ImagePicker();

    final source = await _showImageSourceDialog(context, loc);
    if (source == null || !context.mounted) return;

    List<XFile> images;
    if (source == 'gallery') {
      images = await picker.pickMultiImage();
    } else {
      images = await _pickMultipleFromCamera(context, picker, loc);
    }
    if (images.isEmpty) return;
    if (!context.mounted) return;

    final loader = await showAppLoader(context);
    try {
      final recognizer = await _getPreferredRecognizer();
      final List<Map<String, String>> results = [];
      for (int i = 0; i < images.length; i++) {
        loader.updateMessage(
          '${loc.tr('batch_ocr_processing')} ${i + 1} ${loc.tr('batch_ocr_of')} ${images.length}',
        );
        final inputImage = InputImage.fromFilePath(images[i].path);
        final visionText = await recognizer.processImage(inputImage);
        final text = visionText.text;
        if (text.isNotEmpty) {
          results.add({
            'fileName': images[i].name,
            'text': text,
          });
        }
      }
      recognizer.close();
      loader.dismiss();

      final mc = rootNavigatorKey.currentContext;
      if (mc == null) return;

      if (results.isEmpty) {
        GlobalSnackBar.showError(loc.tr('batch_ocr_no_text'));
        return;
      }

      final exportFormat = await _showExportFormatDialog(mc, loc);
      if (exportFormat == null) return;

      final fileService = FileService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String content;
      String ext;
      if (exportFormat == 'txt') {
        content = results.map((r) {
          return '=== ${r['fileName']} ===\n${r['text']}\n';
        }).join('\n');
        ext = 'txt';
      } else {
        final buffer = StringBuffer();
        buffer.write('File Name,Extracted Text\n');
        for (final r in results) {
          final escapedText = r['text']!.replaceAll('"', '""');
          buffer.write('"${r['fileName']}","$escapedText"\n');
        }
        content = buffer.toString();
        ext = 'csv';
      }
      final fileName = 'batch_ocr_$timestamp.$ext';
      final outputPath = await fileService.getUniqueFilePath(fileName);
      await File(outputPath).writeAsString(content);
      await fileService.saveFile(
        FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: outputPath,
          type: FileType.text,
          createdAt: DateTime.now(),
          sizeInBytes: File(outputPath).lengthSync(),
          tags: ['batch_ocr'],
        ),
      );
      final mc2 = rootNavigatorKey.currentContext;
      if (mc2 != null) {
        mc2.read<FilesBloc>().add(LoadFiles());
      }

      GlobalSnackBar.showSuccess(loc.tr('batch_ocr_success'));

      final allText = results.map((r) => r['text'] as String).join('\n\n');
      if (allText.isNotEmpty) {
        final mc3 = rootNavigatorKey.currentContext;
        if (mc3 != null) {
          await showDialog(
            context: mc3,
            builder: (ctx) {
              final loc2 = AppLocalizations.of(ctx);
              return AlertDialog(
                title: Text(loc2.tr('batch_ocr_success')),
                content: Text(loc2.tr('ai_guide_desc')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      mc3.pushNamed('ai-prompt', extra: allText);
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(loc2.tr('generate_ai_prompt')),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Batch OCR error: $e');
      debugPrint('Stack trace: $stackTrace');
      loader.dismiss();
      final mc = rootNavigatorKey.currentContext;
      if (mc != null) {
        GlobalSnackBar.showErrorOverlay(mc, loc.tr('batch_ocr_error'));
      } else {
        _errorTask(loader, loc.tr('batch_ocr_error'));
      }
    }
  }

  static Future<String?> _showImageSourceDialog(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.tr('batch_ocr')),
          content: Text(loc.tr('batch_ocr_select_source')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'gallery'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library, size: 20),
                  const Gap(8),
                  Text(loc.tr('batch_ocr_from_gallery')),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'camera'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, size: 20),
                  const Gap(8),
                  Text(loc.tr('batch_ocr_from_camera')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<List<XFile>> _pickMultipleFromCamera(
    BuildContext context,
    ImagePicker picker,
    AppLocalizations loc,
  ) async {
    final List<XFile> images = [];
    bool keepCapturing = true;
    while (keepCapturing) {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (photo == null) {
        keepCapturing = false;
      } else {
        images.add(photo);
        if (context.mounted) {
          keepCapturing = await _confirmContinueCapture(context, loc, images.length);
        } else {
          keepCapturing = false;
        }
      }
    }
    return images;
  }

  static Future<bool> _confirmContinueCapture(
    BuildContext context,
    AppLocalizations loc,
    int capturedCount,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.tr('batch_ocr')),
          content: Text(loc.tr('batch_ocr_captured_count').replaceAll('\$count', capturedCount.toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.tr('batch_ocr_done')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.tr('batch_ocr_capture_more')),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static Future<String?> _showExportFormatDialog(
    BuildContext context,
    AppLocalizations loc,
  ) async {
    return showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.tr('export_format')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_snippet),
                title: Text(loc.tr('batch_ocr_export_txt')),
                onTap: () => Navigator.pop(ctx, 'txt'),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: Text(loc.tr('batch_ocr_export_csv')),
                onTap: () => Navigator.pop(ctx, 'csv'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReorderPagesScreen extends StatefulWidget {
  final List<Uint8List> thumbnails;
  final AppLocalizations loc;
  const _ReorderPagesScreen({
    required this.thumbnails,
    required this.loc,
  });
  @override
  State<_ReorderPagesScreen> createState() => _ReorderPagesScreenState();
}

class _ReorderPagesScreenState extends State<_ReorderPagesScreen> {
  late List<int> _order;
  late List<bool> _deleted;

  @override
  void initState() {
    super.initState();
    _order = List.generate(widget.thumbnails.length, (i) => i);
    _deleted = List.generate(widget.thumbnails.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final activeIndices = _order.where((i) => !_deleted[i]).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('reorder_pages')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, (activeIndices, false)),
            child: Text(
              loc.tr('save_as_copy'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, (activeIndices, true)),
            child: Text(
              loc.tr('save'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: activeIndices.isEmpty
          ? Center(child: Text(loc.tr('no_pages_to_show')))
          : ReorderableListView.builder(
              itemCount: _order.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _order.removeAt(oldIndex);
                  _order.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final pageIndex = _order[index];
                if (_deleted[pageIndex]) {
                  return SizedBox.shrink(key: ValueKey('deleted-$pageIndex'));
                }
                return Card(
                  key: ValueKey('page-$pageIndex'),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        widget.thumbnails[pageIndex],
                        width: 48,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text('${loc.tr('page')} ${pageIndex + 1}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() => _deleted[pageIndex] = true);
                          },
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _WatermarkSettings {
  final String text;
  final double opacity;
  final double fontSize;
  final double rotation;
  final Color color;
  final bool isBold;
  final bool isItalic;
  final bool isTiled;
  final String fontFamily;
  final bool overwrite;

  _WatermarkSettings({
    required this.text,
    required this.opacity,
    required this.fontSize,
    required this.rotation,
    required this.color,
    required this.isBold,
    required this.isItalic,
    required this.isTiled,
    required this.fontFamily,
    required this.overwrite,
  });
}
