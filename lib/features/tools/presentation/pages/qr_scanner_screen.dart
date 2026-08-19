import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:gap/gap.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isDetected = false;
  String _detectedValue = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isDetected) {
      setState(() {
        _isDetected = true;
        _detectedValue = barcodes.first.rawValue ?? '';
      });
      _controller.stop();
    }
  }

  void _resetScanner() {
    setState(() {
      _isDetected = false;
      _detectedValue = '';
    });
    _controller.start();
  }

  bool _isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  void _copyText(AppLocalizations loc) {
    Clipboard.setData(ClipboardData(text: _detectedValue));
    GlobalSnackBar.showSuccess(loc.tr('qr_copied_to_clipboard'));
  }

  void _openUrl(AppLocalizations loc) async {
    if (!_isUrl(_detectedValue)) {
      GlobalSnackBar.showError(loc.tr('qr_invalid_url'));
      return;
    }
    final uri = Uri.parse(_detectedValue);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      GlobalSnackBar.showError(loc.tr('qr_invalid_url'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('qr_scanner'), style: Styles.appBarTitle(context)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          if (!_isDetected)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.tr('qr_point_at_code'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          if (_isDetected)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.green, size: 24),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              loc.tr('qr_code_detected'),
                              style: Styles.cardTitle(context),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 22),
                            onPressed: () {
                              _controller.stop();
                              Navigator.of(context).pop();
                            },
                            tooltip: loc.tr('close'),
                          ),
                        ],
                      ),
                    const Gap(16),
                    Text(
                      loc.tr('qr_result'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _detectedValue,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _copyText(loc),
                            icon: const Icon(Icons.copy, size: 18),
                            label: Text(loc.tr('qr_copy_text')),
                          ),
                        ),
                        const Gap(8),
                        if (_isUrl(_detectedValue))
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _openUrl(loc),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: Text(loc.tr('qr_open_url')),
                            ),
                          ),
                      ],
                    ),
                    const Gap(8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _resetScanner,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(loc.tr('qr_scan_again')),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
        ],
      ),
    );
  }
}
