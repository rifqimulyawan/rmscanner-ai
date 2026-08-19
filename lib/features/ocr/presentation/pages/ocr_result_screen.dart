import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/core/utils/app_strings.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/features/files/data/models/file_model.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/core/router/app_router.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';

class OcrResultScreen extends StatefulWidget {
  final String text;
  final int wordCount;
  final int characterCount;
  const OcrResultScreen({
    super.key,
    required this.text,
    this.wordCount = 0,
    this.characterCount = 0,
  });
  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  late TextEditingController _textController;
  final FileService _fileService = FileService();
  bool _isSaving = false;
  bool _isAutoSaved = false;
  String? _savedFilePath;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
    // Auto-save extracted text immediately so it always appears in Files
    _autoSave();
  }

  /// Automatically saves the extracted text as a .txt file on arrival.
  /// This ensures the result always appears in the Files section,
  /// even if the user presses back without tapping Save.
  Future<void> _autoSave() async {
    if (widget.text.trim().isEmpty) return;
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Scanner_Text_$timestamp.txt';
      final filePath = await _fileService.getUniqueFilePath(fileName);
      final file = File(filePath);
      await file.writeAsString(widget.text);
      final fileId = const Uuid().v4();
      final fileModel = FileModel(
        id: fileId,
        name: fileName,
        path: filePath,
        type: FileType.text,
        createdAt: DateTime.now(),
        sizeInBytes: await file.length(),
        tags: ['ocr', 'text'],
      );
      await _fileService.saveFile(fileModel);
      // Refresh the files list so it shows immediately
      final mc = rootNavigatorKey.currentContext;
      if (mc != null && mc.mounted) {
        try {
          mc.read<FilesBloc>().add(LoadFiles());
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _isAutoSaved = true;
          _savedFilePath = filePath;
        });
      }
    } catch (e) {
      debugPrint('Auto-save failed: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (mounted) {
      GlobalSnackBar.showSuccess(
        AppLocalizations.of(context).tr('text_copied'),
      );
    }
  }

  Future<void> _shareText() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: _textController.text,
          subject: AppStrings.scannedTextFromRmscanner,
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

  /// Saves any edits the user made to the text. If auto-save already created
  /// a file, we overwrite it with the edited content instead of creating a duplicate.
  Future<void> _saveAsTextFile() async {
    setState(() => _isSaving = true);
    try {
      if (_isAutoSaved && _savedFilePath != null) {
        // Overwrite the auto-saved file with (possibly edited) text
        final file = File(_savedFilePath!);
        await file.writeAsString(_textController.text);
      } else {
        // Fallback: create a new file if auto-save didn't run
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'Scanner_Text_$timestamp.txt';
        final filePath = await _fileService.getUniqueFilePath(fileName);
        final file = File(filePath);
        await file.writeAsString(_textController.text);
        final fileModel = FileModel(
          id: const Uuid().v4(),
          name: fileName,
          path: filePath,
          type: FileType.text,
          createdAt: DateTime.now(),
          sizeInBytes: await file.length(),
          tags: ['ocr', 'text'],
        );
        await _fileService.saveFile(fileModel);
      }
      // Refresh files list
      final mc = rootNavigatorKey.currentContext;
      if (mc != null && mc.mounted) {
        try {
          mc.read<FilesBloc>().add(LoadFiles());
        } catch (_) {}
      }
      if (mounted) {
        Navigator.pop(context);
        GlobalSnackBar.showSuccess(
          AppLocalizations.of(context).tr('saved_success_text'),
        );
      }
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('error_saving_doc'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the bottom padding needed so content isn't covered by bottom nav
    // We get the bottom inset plus approximately 80px for the typical nav bar height
    final bottomNavAvoidance = MediaQuery.of(context).padding.bottom + 80;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('extraction_results')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy),
            tooltip: AppLocalizations.of(context).tr('copy'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Card
                    if (widget.wordCount > 0 || widget.characterCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.analytics_outlined,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).tr('document_statistics'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    '${widget.wordCount} ${AppLocalizations.of(context).tr('words')} • ${widget.characterCount} ${AppLocalizations.of(context).tr('characters')}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Gap(24),
                    // Editor Section Header
                    Text(
                      AppLocalizations.of(context).tr('extracted_text'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    // Editable Text Area
                    Container(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight * 0.4,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: AppLocalizations.of(context).tr('no_text_hint'),
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                    ),
                    const Gap(32),
                    // AI Prompt Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          final mc = rootNavigatorKey.currentContext;
                          if (mc != null) {
                            mc.pushNamed('ai-prompt', extra: _textController.text);
                          }
                        },
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        label: Text(AppLocalizations.of(context).tr('generate_ai_prompt')),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareText,
                            icon: const Icon(Icons.share_outlined),
                            label: Text(AppLocalizations.of(context).tr('share')),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _saveAsTextFile,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(AppLocalizations.of(context).tr('save_document')),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Critical spacing for Bottom Navigation Bar overlap
                    Gap(bottomNavAvoidance),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
