import 'package:flutter/material.dart';
import 'package:rmscanner/core/widgets/custom_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/widgets/section_header.dart';
import 'package:rmscanner/core/localization/bloc/language_bloc.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/core/services/preferences_service.dart';
import 'package:rmscanner/core/utils/app_strings.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';
import 'package:rmscanner/core/theme/bloc/theme_bloc.dart';
import 'package:rmscanner/core/theme/app_theme.dart';
import 'package:rmscanner/features/settings/presentation/widgets/settings_tile.dart';
import 'package:rmscanner/core/services/ad_service.dart';
import 'package:rmscanner/core/widgets/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final PreferencesService _prefsService = PreferencesService();
  final FileService _fileService = FileService();
  bool _autoEnhance = true;
  bool _useSystemFont = false;
  String _scanQuality = 'High';
  String _ocrLanguage = 'Indonesian';
  String _defaultPageSize = 'A4';
  int _cacheSize = 0;
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadCacheSize();
  }

  Future<void> _loadPreferences() async {
    final autoEnhance = await _prefsService.getAutoEnhance();
    final useSystemFont = await _prefsService.getUseSystemFont();
    final scanQuality = await _prefsService.getScanQuality();
    final ocrLanguage = await _prefsService.getOcrLanguage();
    final defaultPageSize = await _prefsService.getDefaultPageSize();
    if (mounted) {
      setState(() {
        _autoEnhance = autoEnhance;
        _useSystemFont = useSystemFont;
        _scanQuality = scanQuality;
        _ocrLanguage = ocrLanguage;
        _defaultPageSize = defaultPageSize;
      });
    }
  }

  Future<void> _loadCacheSize() async {
    final size = await _fileService.getCacheSize();
    if (mounted) setState(() => _cacheSize = size);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: loc.tr('menu'),
        actionIcon: Icons.info_outline,
        onActionTap: () => context.push('/about'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.horizontalPadding),
        children: [
          _buildSectionHeader(context, loc.tr('basic')),
          _buildSettingsGroup([
            BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, state) {
                return SettingsTile(
                  title: loc.tr('language'),
                  icon: Icons.language,
                  subtitle: _getLanguageName(state.locale.languageCode),
                  onTap: () => _showLanguageDialog(context),
                );
              },
            ),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return SettingsTile(
                  title: loc.tr('theme'),
                  icon: Icons.dark_mode,
                  subtitle: state.themeMode.name.capitalize(),
                  onTap: () => _showThemeDialog(),
                );
              },
            ),
            SettingsTile(
              title: loc.tr('refer_friend'),
              icon: Icons.share_outlined,
              onTap: () => _shareApp(),
            ),
            SettingsTile(
              title: loc.tr('use_system_font'),
              icon: Icons.font_download_outlined,
              subtitle: _useSystemFont
                  ? loc.tr('system_font')
                  : loc.tr('app_font'),
              trailing: Switch(
                value: _useSystemFont,
                onChanged: (value) async {
                  await _prefsService.setUseSystemFont(value);
                  AppTheme.useSystemFont = value;
                  setState(() => _useSystemFont = value);
                  if (context.mounted) {
                    context.read<ThemeBloc>().add(
                      ChangeTheme(context.read<ThemeBloc>().state.themeMode),
                    );
                  }
                },
              ),
              onTap: () {},
            ),
          ]),
          _buildSectionHeader(context, loc.tr('scan_section')),
          _buildSettingsGroup([
            SettingsTile(
              title: loc.tr('auto_enhance'),
              icon: Icons.auto_fix_high,
              trailing: Switch(
                value: _autoEnhance,
                onChanged: (value) async {
                  await _prefsService.setAutoEnhance(value);
                  setState(() => _autoEnhance = value);
                },
              ),
              onTap: () {},
            ),
            SettingsTile(
              title: loc.tr('scan_quality'),
              icon: Icons.high_quality,
              subtitle: _scanQuality,
              onTap: () => _showScanQualityDialog(),
            ),
          ]),
          _buildSectionHeader(context, loc.tr('pdf_ocr_section')),
          _buildSettingsGroup([
            SettingsTile(
              title: loc.tr('default_page_size'),
              icon: Icons.aspect_ratio,
              subtitle: _defaultPageSize,
              onTap: () => _showPageSizeDialog(),
            ),
            SettingsTile(
              title: loc.tr('ocr_language'),
              icon: Icons.translate,
              subtitle: _ocrLanguage,
              onTap: () => _showOcrLanguageDialog(),
            ),
          ]),
          _buildSectionHeader(context, loc.tr('support_privacy')),
          _buildSettingsGroup([
            SettingsTile(
              title: loc.tr('privacy_policy'),
              icon: Icons.policy_outlined,
              onTap: () =>
                  _launchUrl('https://rmdigital.co.id/kebijakan-privasi/'),
            ),
            SettingsTile(
              title: loc.tr('feature_request'),
              icon: Icons.lightbulb_outline,
              onTap: () => _launchEmail('Feature Request'),
            ),
            SettingsTile(
              title: loc.tr('report_bug'),
              icon: Icons.bug_report_outlined,
              onTap: () => _launchEmail('Bug Report'),
            ),
            SettingsTile(
              title: loc.tr('support_developer'),
              icon: Icons.favorite_outline,
              onTap: () {
                GlobalSnackBar.show(loc.tr('loading_support_ad'));
                AdService().showRewardedAd(
                  onRewarded: (reward) {
                    GlobalSnackBar.showSuccess(loc.tr('thank_you_support'));
                  },
                  onAdFailed: () {
                    GlobalSnackBar.showError(loc.tr('ad_not_ready'));
                  },
                );
              },
            ),
          ]),
          _buildSectionHeader(context, loc.tr('data_section')),
          _buildSettingsGroup([
            SettingsTile(
              title: loc.tr('clear_cache'),
              icon: Icons.delete_outline,
              subtitle: _formatBytes(_cacheSize),
              onTap: () => _showClearCacheDialog(),
              isDestructive: true,
            ),
          ]),
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> tiles) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(tiles.length, (i) => Column(
          children: [
            tiles[i],
            if (i < tiles.length - 1)
              Divider(
                height: 1,
                indent: 56,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              ),
          ],
        )),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimensions.paddingXL,
        bottom: Dimensions.gapSmall,
      ),
      child: SectionHeader(title: title),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'bn':
        return 'Bangla';
      case 'hi':
        return 'Hindi';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'ar':
        return 'Arabic';
      case 'id':
        return 'Indonesia';
      default:
        return 'English';
    }
  }

  Future<void> _shareApp() async {
    await SharePlus.instance.share(ShareParams(text: AppStrings.shareMessage));
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String subject) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'rmdigital.co.id@gmail.com',
      query: 'subject=$subject',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final List<Map<String, String>> langs = [
      {
        'name': 'English',
        'code': 'en',
        'flag': 'https://flagcdn.com/w40/us.png',
      },
      {
        'name': 'Bangla',
        'code': 'bn',
        'flag': 'https://flagcdn.com/w40/bd.png',
      },
      {'name': 'Hindi', 'code': 'hi', 'flag': 'https://flagcdn.com/w40/in.png'},
      {
        'name': 'French',
        'code': 'fr',
        'flag': 'https://flagcdn.com/w40/fr.png',
      },
      {
        'name': 'German',
        'code': 'de',
        'flag': 'https://flagcdn.com/w40/de.png',
      },
      {
        'name': 'Arabic',
        'code': 'ar',
        'flag': 'https://flagcdn.com/w40/sa.png',
      },
      {
        'name': 'Indonesia',
        'code': 'id',
        'flag': 'https://flagcdn.com/w40/id.png',
      },
    ];
    showCustomBottomSheet(
      context: context,
      title: loc.tr('language'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs.map((lang) {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  lang['flag']!,
                  width: 30,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.flag, size: 20),
                ),
              ),
              title: Text(lang['name']!),
              onTap: () {
                context.read<LanguageBloc>().add(
                  ChangeLanguage(Locale(lang['code']!)),
                );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      title: loc.tr('theme'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return RadioGroup<ThemeMode>(
              groupValue: state.themeMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeBloc>().add(ChangeTheme(value));
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(loc.tr('theme_light')),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(loc.tr('theme_dark')),
                    value: ThemeMode.dark,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(loc.tr('theme_system')),
                    value: ThemeMode.system,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showScanQualityDialog() {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      title: loc.tr('scan_quality'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: RadioGroup<String>(
          groupValue: _scanQuality,
          onChanged: (v) {
            if (v != null) {
              _prefsService.setScanQuality(v);
              setState(() => _scanQuality = v);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [loc.tr('quality_low'), loc.tr('quality_medium'), loc.tr('quality_high'), loc.tr('quality_ultra')]
                .map((q) => RadioListTile<String>(title: Text(q), value: q))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showPageSizeDialog() {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      title: loc.tr('default_page_size'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: RadioGroup<String>(
          groupValue: _defaultPageSize,
          onChanged: (v) {
            if (v != null) {
              _prefsService.setDefaultPageSize(v);
              setState(() => _defaultPageSize = v);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['A4', 'Letter', 'Legal']
                .map((s) => RadioListTile<String>(title: Text(s), value: s))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showOcrLanguageDialog() {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      title: loc.tr('ocr_language'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: RadioGroup<String>(
          groupValue: _ocrLanguage,
          onChanged: (v) {
            if (v != null) {
              _prefsService.setOcrLanguage(v);
              setState(() => _ocrLanguage = v);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                [
                      'English',
                      'Indonesian',
                      'Hindi',
                      'Chinese',
                      'Japanese',
                      'Korean',
                    ]
                    .map((l) => RadioListTile<String>(title: Text(l), value: l))
                    .toList(),
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    final loc = AppLocalizations.of(context);
    showCustomBottomSheet(
      context: context,
      title: loc.tr('clear_cache'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(loc.tr('clear_cache_confirm').replaceAll('\$size', _formatBytes(_cacheSize))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.tr('cancel')),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    await _fileService.clearCache();
                    await _loadCacheSize();
                    if (!mounted) return;
                    Navigator.pop(context);
                    GlobalSnackBar.showSuccess(loc.tr('cache_cleared'));
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                  child: Text(loc.tr('clear')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
