import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/core/services/pdf_service.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/services/preferences_service.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:rmscanner/features/home/presentation/widgets/action_card.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_state.dart';
import 'package:rmscanner/features/files/presentation/widgets/file_item.dart';
import 'package:rmscanner/core/widgets/custom_bottom_sheet.dart';
import 'package:rmscanner/core/widgets/section_header.dart';
import 'package:rmscanner/core/widgets/custom_app_bar.dart';
import 'package:rmscanner/core/utils/pdf_action_helper.dart';
import 'package:rmscanner/core/utils/file_action_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _HomeScreenContent();
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();
  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: loc.tr('home'),
        actionIcon: Icons.info_outline,
        onActionTap: () => context.push('/about'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth > 0
              ? constraints.maxWidth
              : 400;
          final int cols = ((width - 32) / 105).floor().clamp(2, 4);
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<FilesBloc>().add(LoadFiles());
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScanBanner(context, loc),
                        const Gap(20),
                        SectionHeader(
                          title: loc.tr('quick_actions'),
                          actionText: loc.tr('see_all_tools'),
                          onActionTap: () => context.go('/tools'),
                        ),
                        const Gap(12),
                        GridView.count(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: cols,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                          children: [
                            ActionCard(
                              title: loc.tr('image_to_pdf'),
                              subtitle: loc.tr('convert_photos'),
                              icon: Icons.image_outlined,
                              color: AppColors.orange,
                              onTap: () => _imageToPdf(context),
                            ),
                            ActionCard(
                              title: loc.tr('image_to_text'),
                              subtitle: loc.tr('extract_ocr'),
                              icon: Icons.text_fields,
                              color: AppColors.blue,
                              onTap: () => _imageToText(context),
                            ),
                            ActionCard(
                              title: loc.tr('pdf_to_text'),
                              subtitle: loc.tr('convert_pdf'),
                              icon: Icons.picture_as_pdf_outlined,
                              color: AppColors.red,
                              onTap: () => _pdfToText(context),
                            ),
                            ActionCard(
                              title: loc.tr('text_to_pdf'),
                              subtitle: loc.tr('create_doc'),
                              icon: Icons.edit_document,
                              color: AppColors.green,
                              onTap: () => _textToPdf(context),
                            ),
                            ActionCard(
                              title: loc.tr('qr_scanner'),
                              subtitle: loc.tr('scan_qr_barcode'),
                              icon: Icons.qr_code_scanner,
                              color: AppColors.purple,
                              onTap: () => context.push('/qr-scanner'),
                            ),
                            ActionCard(
                              title: loc.tr('merge_pdf'),
                              subtitle: loc.tr('pdf_tools'),
                              icon: Icons.merge_outlined,
                              color: AppColors.teal,
                              onTap: () => PdfActionHelper.mergePdf(context),
                            ),
                          ],
                        ),
                        const Gap(24),
                        _buildRecentHeader(context, loc),
                        const Gap(8),
                        _buildRecentFilesList(),
                        const Gap(100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanBanner(BuildContext context, AppLocalizations loc) {
    return GestureDetector(
      onTap: () => _handleCameraPermission(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 40,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tr('scan_doc'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        loc.tr('scan_subtitle'),
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.tr('scan_doc'),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Gap(8),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context, AppLocalizations loc) {
    return SectionHeader(
      title: loc.tr('recent_files'),
      actionText: loc.tr('see_all'),
      onActionTap: () => context.go('/files'),
    );
  }

  Widget _buildRecentFilesList() {
    return BlocBuilder<FilesBloc, FilesState>(
      builder: (context, state) {
        if (state is FilesLoading || state is FilesInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is FilesLoaded) {
          if (state.files.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: Dimensions.icon48,
                      color: AppColors.grey400,
                    ),
                    const Gap(8),
                    Text(
                      AppLocalizations.of(context).tr('no_recent_files'),
                      style: Styles.emptyStateTitle(context),
                    ),
                  ],
                ),
              ),
            );
          }
          final recentFiles = state.files.take(20).toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentFiles.length,
            itemBuilder: (context, index) {
              final file = recentFiles[index];
              return FileItem(
                title: file.name,
                date: file.formattedDate(AppLocalizations.of(context)),
                size: file.formattedSize,
                type: file.type.name,
                onTap: () => _openFile(context, file),
                onMoreTap: () => _showFileOptions(context, file),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  bool _isProcessingScan = false;
  Future<void> _handleCameraPermission(BuildContext context) async {
    if (_isProcessingScan) return;
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (!context.mounted) return;
      _isProcessingScan = true;
      try {
        List<String>? pictures = await CunningDocumentScanner.getPictures(
          isGalleryImportAllowed: true,
        );
        if (pictures != null && pictures.isNotEmpty && context.mounted) {
          context.push('/scan-result', extra: pictures);
        }
      } catch (e) {
        if (context.mounted) {
          GlobalSnackBar.showError(
            AppLocalizations.of(context).tr('scan_error'),
          );
        }
      } finally {
        _isProcessingScan = false;
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionSettingsDialog(
          context,
          AppLocalizations.of(context).tr('source_camera'),
          AppLocalizations.of(context).tr('camera_permission_msg'),
        );
      }
    }
  }

  void _showPermissionSettingsDialog(
    BuildContext context,
    String name,
    String msg,
  ) {
    showCustomBottomSheet(
      context: context,
      useRootNavigator: true,
      title: AppLocalizations.of(context).tr('permission_required').replaceAll('\\$name', name),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(msg),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(AppLocalizations.of(context).tr('cancel')),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(AppLocalizations.of(context).tr('open_settings')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _imageToPdf(BuildContext context) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isEmpty || !context.mounted) return;
    _showLoading(context, AppLocalizations.of(context).tr('creating_pdf'));
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
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        context.read<FilesBloc>().add(LoadFiles());
        GlobalSnackBar.showSuccess(
          AppLocalizations.of(context).tr('pdf_created_successfully'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_prefix'),
        );
      }
    }
  }

  Future<void> _imageToText(BuildContext context) async {
    await PdfActionHelper.imageToText(context);
  }

  Future<void> _pdfToText(BuildContext context) async {
    await PdfActionHelper.pdfToText(context);
  }

  Future<void> _textToPdf(BuildContext context) async {
    await PdfActionHelper.textToPdf(context);
  }

  void _showLoading(BuildContext context, String msg) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) => _LoadingDialog(msg: msg),
    );
  }

  Future<void> _openFile(BuildContext context, FileModel file) async {
    try {
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && context.mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('could_not_open_file'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_prefix'),
        );
      }
    }
  }

  void _showFileOptions(BuildContext context, FileModel file) {
    FileActionHelper.showFileOptions(context, file);
  }
}

class _LoadingDialog extends StatelessWidget {
  final String msg;
  const _LoadingDialog({required this.msg});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              Text(msg),
            ],
          ),
        ),
      ),
    );
  }
}
