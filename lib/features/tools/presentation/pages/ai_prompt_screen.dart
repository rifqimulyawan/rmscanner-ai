import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/services/prompt_template_service.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';
import 'package:rmscanner/core/widgets/section_header.dart';

class AiPromptScreen extends StatefulWidget {
  final String documentText;
  const AiPromptScreen({super.key, required this.documentText});

  @override
  State<AiPromptScreen> createState() => _AiPromptScreenState();
}

class _AiPromptScreenState extends State<AiPromptScreen> {
  PromptTemplate? _selectedTemplate;
  String _generatedPrompt = '';

  void _generatePrompt() {
    if (_selectedTemplate == null) return;
    final loc = AppLocalizations.of(context);
    setState(() {
      _generatedPrompt = PromptTemplateService.generatePrompt(
        loc: loc,
        template: _selectedTemplate!,
        documentText: widget.documentText,
      );
    });
  }

  Future<void> _copyPrompt() async {
    if (_generatedPrompt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _generatedPrompt));
    if (mounted) {
      GlobalSnackBar.showSuccess(
        AppLocalizations.of(context).tr('prompt_copied'),
      );
    }
  }

  Future<void> _sharePrompt() async {
    if (_generatedPrompt.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(text: _generatedPrompt),
    );
  }

  Future<void> _openAiTool(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        GlobalSnackBar.showError(
          AppLocalizations.of(context).tr('open_ai_failed'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('ai_prompt'), style: Styles.appBarTitle(context)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: loc.tr('select_template')),
            const Gap(Dimensions.gap),
            _buildTemplateGrid(loc),
            const Gap(Dimensions.gapXL),
            if (_generatedPrompt.isNotEmpty) ...[
              SectionHeader(title: loc.tr('prompt_preview')),
              const Gap(Dimensions.gap),
              _buildPromptPreview(context, loc),
              const Gap(Dimensions.gap),
              _buildActionButtons(loc),
              const Gap(Dimensions.gapXL),
            ],
            SectionHeader(title: loc.tr('ai_guide_title')),
            const Gap(Dimensions.gap),
            _buildGuideCard(context, loc),
            const Gap(Dimensions.gap),
            SectionHeader(title: loc.tr('ai_tools')),
            const Gap(Dimensions.gap),
            _buildAiToolsGrid(loc),
            const Gap(80),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateGrid(AppLocalizations loc) {
    final templates = [
      (
        PromptTemplate.summarize,
        loc.tr('prompt_summarize'),
        loc.tr('prompt_summarize_desc'),
        Icons.summarize,
        AppColors.blue,
      ),
      (
        PromptTemplate.qa,
        loc.tr('prompt_qa'),
        loc.tr('prompt_qa_desc'),
        Icons.question_answer,
        AppColors.green,
      ),
      (
        PromptTemplate.translate,
        loc.tr('prompt_translate'),
        loc.tr('prompt_translate_desc'),
        Icons.translate,
        AppColors.orange,
      ),
      (
        PromptTemplate.extractData,
        loc.tr('prompt_extract_data'),
        loc.tr('prompt_extract_data_desc'),
        Icons.data_object,
        AppColors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: Dimensions.gap,
        crossAxisSpacing: Dimensions.gap,
        childAspectRatio: 1.1,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final t = templates[index];
        final isSelected = _selectedTemplate == t.$1;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedTemplate = t.$1);
            _generatePrompt();
          },
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingLarge),
            decoration: BoxDecoration(
              color: isSelected
                  ? t.$5.withValues(alpha: 0.1)
                  : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(Dimensions.radius),
              border: Border.all(
                color: isSelected
                    ? t.$5.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outlineVariant
                        .withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: Dimensions.cardBlurRadius,
                  offset: const Offset(0, Dimensions.cardShadowOffsetY),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.padding),
                  decoration: BoxDecoration(
                    color: t.$5.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                  child: Icon(t.$4, color: t.$5, size: Dimensions.iconMedium),
                ),
                const Gap(Dimensions.gap),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    t.$2,
                    style: Styles.cardTitle(context),
                  ),
                ),
                const Gap(2),
                Flexible(
                  child: Text(
                    t.$3,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromptPreview(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant
              .withValues(alpha: 0.3),
        ),
      ),
      child: SelectableText(
        _generatedPrompt,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _copyPrompt,
            icon: const Icon(Icons.copy, size: 18),
            label: Text(loc.tr('copy_prompt')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius),
              ),
            ),
          ),
        ),
        const Gap(Dimensions.gap),
        Expanded(
          child: FilledButton.icon(
            onPressed: _sharePrompt,
            icon: const Icon(Icons.share, size: 18),
            label: Text(loc.tr('share_prompt')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  loc.tr('ai_guide_desc'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            loc.tr('ai_prompt_guide_step1'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Gap(4),
          Text(
            loc.tr('ai_prompt_guide_step2'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Gap(4),
          Text(
            loc.tr('ai_prompt_guide_step3'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAiToolsGrid(AppLocalizations loc) {
    final tools = [
      (loc.tr('open_chatgpt'), 'https://chat.openai.com', Icons.smart_toy),
      (loc.tr('open_gemini'), 'https://gemini.google.com', Icons.auto_awesome),
      (loc.tr('open_claude'), 'https://claude.ai', Icons.psychology),
      (loc.tr('open_copilot'), 'https://copilot.microsoft.com', Icons.flight_takeoff),
      (loc.tr('open_deepseek'), 'https://chat.deepseek.com', Icons.search),
      (loc.tr('open_perplexity'), 'https://www.perplexity.ai', Icons.manage_search),
      (loc.tr('open_mistral'), 'https://chat.mistral.ai', Icons.air),
      (loc.tr('open_grok'), 'https://grok.com', Icons.bolt),
      (loc.tr('open_meta_ai'), 'https://www.meta.ai', Icons.facebook),
      (loc.tr('open_you_com'), 'https://you.com', Icons.explore),
      (loc.tr('open_pi'), 'https://heypi.com', Icons.chat_bubble_outline),
    ];

    return Wrap(
      spacing: Dimensions.gap,
      runSpacing: Dimensions.gap,
      children: tools.map((t) {
        return ActionChip(
          onPressed: () => _openAiTool(t.$2),
          avatar: Icon(t.$3, size: 18),
          label: Text(t.$1),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding,
            vertical: 8,
          ),
        );
      }).toList(),
    );
  }
}
