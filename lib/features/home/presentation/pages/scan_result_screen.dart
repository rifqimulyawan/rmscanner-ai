import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/core/services/pdf_service.dart';
import 'package:rmscanner/core/services/preferences_service.dart';
import 'package:rmscanner/core/utils/app_strings.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';

class ScanResultScreen extends StatefulWidget {
  final List<String> scannedImagePaths;
  const ScanResultScreen({super.key, required this.scannedImagePaths});
  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  int _currentPage = 0;
  bool _isSaving = false;
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<PdfPageFormat> _getPreferredPageSize() async {
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

  Future<void> _saveAsImages() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final fileService = FileService();
      for (final path in widget.scannedImagePaths) {
        final fileInfo = File(path);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'scan_$timestamp.jpg';
        final destPath = await fileService.getUniqueFilePath(fileName);
        await fileInfo.copy(destPath);
        final fileModel = FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: destPath,
          type: FileType.image,
          createdAt: DateTime.now(),
          sizeInBytes: await fileInfo.length(),
          tags: ['scan'],
        );
        await fileService.saveFile(fileModel);
      }
      if (mounted) {
        context.read<FilesBloc>().add(LoadFiles());
        Navigator.of(context).pop();
        GlobalSnackBar.showSuccess(
          '${widget.scannedImagePaths.length} ${AppLocalizations.of(context).tr('images_saved')}',
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_prefix'),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAsPdf() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final pdfService = PdfService();
      final fileService = FileService();
      final format = await _getPreferredPageSize();
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = await fileService.getUniqueFilePath(fileName);
      final file = await pdfService.createPdfFromImages(
        widget.scannedImagePaths,
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
          tags: ['scan', 'converted'],
        ),
      );
      if (mounted) {
        context.read<FilesBloc>().add(LoadFiles());
        Navigator.of(context).pop();
        GlobalSnackBar.showSuccess(
          AppLocalizations.of(context).tr('pdf_saved_successfully'),
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_prefix'),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAsDoc() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final loc = AppLocalizations.of(context);
      final fileService = FileService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'scan_doc_$timestamp.txt';
      final filePath = await fileService.getUniqueFilePath(fileName);
      final buffer = StringBuffer();
      buffer.writeln(
        '${loc.tr('scan_result')} - ${DateTime.now().toLocal()}',
      );
      buffer.writeln(
        '${loc.tr('pages_scanned_format')}: ${widget.scannedImagePaths.length}',
      );
      buffer.writeln('---');
      for (int i = 0; i < widget.scannedImagePaths.length; i++) {
        buffer.writeln(
          '${loc.tr('document')} ${i + 1}: ${widget.scannedImagePaths[i]}',
        );
      }
      final file = File(filePath);
      await file.writeAsString(buffer.toString());
      final fileModel = FileModel(
        id: const Uuid().v4(),
        name: fileName,
        path: filePath,
        type: FileType.text,
        createdAt: DateTime.now(),
        sizeInBytes: await file.length(),
        tags: ['scan', 'document'],
      );
      await fileService.saveFile(fileModel);
      if (mounted) {
        context.read<FilesBloc>().add(LoadFiles());
        Navigator.of(context).pop();
        GlobalSnackBar.showSuccess(
          AppLocalizations.of(context).tr('document_saved_successfully'),
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_saving_doc'),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareFiles() async {
    try {
      final xFiles = widget.scannedImagePaths.map((p) => XFile(p)).toList();
      await SharePlus.instance.share(
        ShareParams(
          files: xFiles,
          subject: AppStrings.scannedDocumentsFromRmscanner,
        ),
      );
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_sharing'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageCount = widget.scannedImagePaths.length;
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).tr('scan_result')),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _shareFiles,
              icon: const Icon(Icons.share_outlined),
              tooltip: AppLocalizations.of(context).tr('share'),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.black.withValues(alpha: 0.03),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imageCount,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (context, index) {
                          // Limit decoded image size to screen width to prevent OOM
                          // on multiple high-res scanned images. Original files
                          // are untouched — only preview is downscaled.
                          final screenWidth = MediaQuery.of(
                            context,
                          ).size.width.toInt();
                          return InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: Image.file(
                              File(widget.scannedImagePaths[index]),
                              fit: BoxFit.contain,
                              cacheWidth: screenWidth,
                              filterQuality: FilterQuality.medium,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        size: 48,
                                        color: theme.colorScheme.error,
                                      ),
                                      const Gap(8),
                                      Text(
                                        AppLocalizations.of(context).tr('failed_to_load_image'),
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      // Page indicator
                      if (imageCount > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentPage + 1} / $imageCount',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        '$imageCount ${AppLocalizations.of(context).tr('pages_scanned_format')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context).tr('save_as'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Expanded(
                        child: _SaveOptionCard(
                          icon: Icons.image_outlined,
                          label: AppLocalizations.of(context).tr('source_image'),
                          color: AppColors.orange,
                          onTap: _isSaving ? null : _saveAsImages,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: _SaveOptionCard(
                          icon: Icons.picture_as_pdf_outlined,
                          label: AppLocalizations.of(context).tr('source_pdf'),
                          color: AppColors.red,
                          onTap: _isSaving ? null : _saveAsPdf,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: _SaveOptionCard(
                          icon: Icons.description_outlined,
                          label: AppLocalizations.of(context).tr('document'),
                          color: AppColors.blue,
                          onTap: _isSaving ? null : _saveAsDoc,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  // Share button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _shareFiles,
                      icon: const Icon(Icons.share_outlined),
                      label: Text(AppLocalizations.of(context).tr('share_scanned_pages')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Loading overlay
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const Gap(10),
                    Text(
                      AppLocalizations.of(context).tr('saving'),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class _SaveOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _SaveOptionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Gap(8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
