import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../localization/app_localizations.dart';
import '../widgets/global_snackbar.dart';

class AppActionHelper {
  static Future<void> openPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse(AppStrings.privacyPolicyUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      GlobalSnackBar.showError(
        AppLocalizations.of(context).tr('could_not_open_privacy_policy'),
      );
    }
  }

  static Future<void> openSupportEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppStrings.supportEmail,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Rmscannerner AI Support Request',
      }),
    );
    if (!await launchUrl(emailLaunchUri)) {
      if (!context.mounted) return;
      GlobalSnackBar.showError(
        AppLocalizations.of(context).tr('could_not_open_email'),
      );
    }
  }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
