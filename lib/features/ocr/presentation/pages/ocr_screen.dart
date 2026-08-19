import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/widgets/custom_bottom_sheet.dart';
import 'package:rmscanner/core/widgets/app_loader.dart';
import 'package:rmscanner/core/widgets/custom_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:rmscanner/features/ocr/presentation/bloc/ocr_bloc.dart';
import 'package:rmscanner/features/ocr/presentation/bloc/ocr_event.dart';
import 'package:rmscanner/features/ocr/presentation/bloc/ocr_state.dart';
import 'package:rmscanner/core/services/preferences_service.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart' as fm;
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/core/router/app_router.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/utils/pdf_action_helper.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});
  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  int _selectedMode = 2;
  // 0: Image, 1: PDF, 2: Camera
  final ImagePicker _imagePicker = ImagePicker();
  final PreferencesService _prefsService = PreferencesService();
  String _selectedLanguage = 'Indonesian';
  BackgroundTaskHandle? _ocrLoader;
  @override
  void initState() {
    super.initState();
    _loadOcrLanguage();
  }

  Future<void> _loadOcrLanguage() async {
    final lang = await _prefsService.getOcrLanguage();
    if (mounted) {
      setState(() {
        _selectedLanguage = lang;
      });
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final languages = [
      'English',
      'Indonesian',
      'Hindi',
      'Chinese',
      'Japanese',
      'Korean',
    ];
    showCustomBottomSheet(
      context: context,
      title: loc.tr('select_ocr_language'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: RadioGroup<String>(
          groupValue: _selectedLanguage,
          onChanged: (value) async {
            if (value != null) {
              await _prefsService.setOcrLanguage(value);
              setState(() => _selectedLanguage = value);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              return RadioListTile<String>(title: Text(lang), value: lang);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (!context.mounted) return;
      if (image != null) {
        final bloc = context.read<OcrBloc>();
        final msg = AppLocalizations.of(context).tr('extracting_from_image');
        _ocrLoader = await showAppLoader(context, message: msg);
        bloc.add(
          ExtractTextFromImage(image.path, language: _selectedLanguage),
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          loc.tr('error_picking_image'),
        );
      }
    }
  }

  Future<void> _pickPdf(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (!context.mounted) return;
      if (result != null && result.files.single.path != null) {
        final bloc = context.read<OcrBloc>();
        final msg = AppLocalizations.of(context).tr('extracting_from_pdf');
        _ocrLoader = await showAppLoader(context, message: msg);
        bloc.add(
          ExtractTextFromPdf(
            result.files.single.path!,
            language: _selectedLanguage,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          loc.tr('error_picking_pdf'),
        );
      }
    }
  }

  Future<void> _captureImage(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    try {
      final bloc = context.read<OcrBloc>();
      final msg = AppLocalizations.of(context).tr('extracting_from_capture');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (!context.mounted) return;
      if (image != null) {
        _ocrLoader = await showAppLoader(context, message: msg);
        bloc.add(
          ExtractTextFromImage(image.path, language: _selectedLanguage),
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          loc.tr('error_capturing_image'),
        );
      }
    }
  }

  /// Saves extracted text in the background when user chose "Notify When Ready" and
  /// navigated away. Without this, the text would be silently discarded.
  Future<void> _backgroundSaveText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      final fileService = FileService();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Scanner_Text_$timestamp.txt';
      final filePath = await fileService.getUniqueFilePath(fileName);
      final file = File(filePath);
      await file.writeAsString(text);
      final fileModel = fm.FileModel(
        id: const Uuid().v4(),
        name: fileName,
        path: filePath,
        type: fm.FileType.text,
        createdAt: DateTime.now(),
        sizeInBytes: await file.length(),
        tags: ['ocr', 'text'],
      );
      await fileService.saveFile(fileModel);
      // Refresh files list
      final mc = rootNavigatorKey.currentContext;
      if (mc != null && mc.mounted) {
        try {
          mc.read<FilesBloc>().add(LoadFiles());
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Background save failed: $e');
    }
  }

  void _onOcrStateChanged(BuildContext context, OcrState state) {
    if (state is OcrSuccess) {
      context.read<OcrBloc>().add(ClearOcrResult());
      // If user tapped "Notify When Ready", save the text in background and notify
      if (_ocrLoader?.userWantsNotification == true) {
        // Auto-save even when user navigated away
        _backgroundSaveText(state.extractedText);
        _ocrLoader?.notifySuccess(AppLocalizations.of(context).tr('text_extracted_success'));
        _ocrLoader = null;
        return;
      }
      _ocrLoader?.dismiss();
      _ocrLoader = null;
      context.pushNamed(
        'ocr-result',
        extra: {
          'text': state.extractedText,
          'wordCount': state.wordCount,
          'characterCount': state.characterCount,
        },
      );
    } else if (state is OcrError) {
      context.read<OcrBloc>().add(ClearOcrResult());
      _ocrLoader?.dismiss();
      if (_ocrLoader?.userWantsNotification == true) {
        _ocrLoader?.notifyError(state.message);
      } else if (mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr(state.message),
        );
      }
      _ocrLoader = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OcrBloc, OcrState>(
      listener: _onOcrStateChanged,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: AppLocalizations.of(context).tr('ocr'),
          actionIcon: Icons.language,
          onActionTap: () => _showLanguageDialog(context),
        ),
        body: Stack(
          children: [
            // Safe Area content to prevent overlap
            SafeArea(
              child: Column(
                children: [
                  // Background Placeholder
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.document_scanner_rounded,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Gap(24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                AppLocalizations.of(context).tr('extract_text_title'),
                                style: Styles.sectionTitle(context),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Gap(8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                AppLocalizations.of(context).tr('extract_text_subtitle'),
                                textAlign: TextAlign.center,
                                style: Styles.cardSubtitle(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom padding adjustment given bottom navigation bar logic in main layout
                  Gap(MediaQuery.of(context).padding.bottom + 220),
                ],
              ),
            ),
            // Bottom Control Panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  // extra padding for nav bar overlay
                  top: 24,
                  left: 16,
                  right: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modes
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ModeButton(
                            icon: Icons.image_outlined,
                            label: AppLocalizations.of(context).tr('source_image'),
                            index: 0,
                            isSelected: _selectedMode == 0,
                            onTap: () => setState(() => _selectedMode = 0),
                          ),
                          const Gap(16),
                          _ModeButton(
                            icon: Icons.picture_as_pdf_outlined,
                            label: AppLocalizations.of(context).tr('source_pdf'),
                            index: 1,
                            isSelected: _selectedMode == 1,
                            onTap: () => setState(() => _selectedMode = 1),
                          ),
                          const Gap(16),
                          _ModeButton(
                            icon: Icons.camera_alt_outlined,
                            label: AppLocalizations.of(context).tr('source_camera'),
                            index: 2,
                            isSelected: _selectedMode == 2,
                            onTap: () => setState(() => _selectedMode = 2),
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          switch (_selectedMode) {
                            case 0:
                              _pickImage(context);
                              break;
                            case 1:
                              _pickPdf(context);
                              break;
                            case 2:
                              _captureImage(context);
                              break;
                          }
                        },
                        icon: Icon(
                          _selectedMode == 2
                              ? Icons.camera
                              : Icons.upload_file,
                        ),
                        label: Text(
                          _selectedMode == 2
                              ? AppLocalizations.of(context).tr('capture_document')
                              : AppLocalizations.of(context).tr('select_file'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    // Batch OCR button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => PdfActionHelper.batchOcr(context),
                        icon: const Icon(Icons.document_scanner_outlined, size: 22),
                        label: Text(
                          AppLocalizations.of(context).tr('batch_ocr'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const Gap(80),
                    // Prevent collision with the router's bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingLarge,
          vertical: Dimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Dimensions.iconSmall20,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            const Gap(Dimensions.gapSmall),
            Text(label, style: Styles.tabText(context, isSelected: isSelected)),
          ],
        ),
      ),
    );
  }
}
