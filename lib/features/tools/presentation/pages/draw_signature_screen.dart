import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:gap/gap.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';

class DrawSignatureScreen extends StatefulWidget {
  const DrawSignatureScreen({super.key});
  @override
  State<DrawSignatureScreen> createState() => _DrawSignatureScreenState();
}

class _DrawSignatureScreenState extends State<DrawSignatureScreen> {
  late SignatureController _controller;
  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 4,
      penColor: AppColors.black,
      exportBackgroundColor: AppColors.transparent,
      onDrawEnd: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      // Sleek dark mode background
      appBar: AppBar(
        title: Text(
          loc.tr('draw_signature'),
          style: Styles.appBarTitle(context),
        ),
        centerTitle: true,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingXL,
                vertical: Dimensions.paddingSmall,
              ),
              child: Text(
                loc.tr('please_sign'),
                style: Styles.smallMutedWhite(),
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(Dimensions.gapXL),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingXL,
                ),
                child: Hero(
                  tag: 'signature_pad',
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.2),
                          blurRadius: Dimensions.cardBlurRadius,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // The Canvas
                        Signature(
                          controller: _controller,
                          backgroundColor: AppColors.white,
                        ),
                        // Signature Baseline Guide
                        Positioned(
                          bottom: Dimensions.paddingXL * 2,
                          left: Dimensions.paddingXL,
                          right: Dimensions.paddingXL,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: AppColors.black.withValues(alpha: 0.26),
                                size: Dimensions.iconSmall,
                              ),
                              const Gap(Dimensions.gapSmall),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppColors.black12,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusTiny,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Floating Action Tray
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingLarge,
                vertical: Dimensions.paddingXL,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.refresh,
                      label: loc.tr('clear'),
                      color: AppColors.white12,
                      textColor: AppColors.white,
                      onTap: () {
                        _controller.clear();
                        setState(() {});
                      },
                    ),
                  ),
                  const Gap(Dimensions.gapSmall),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.undo,
                      label: loc.tr('undo'),
                      color: AppColors.white12,
                      textColor: AppColors.white,
                      onTap: () {
                        if (_controller.isNotEmpty) {
                          _controller.undo();
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const Gap(Dimensions.gapSmall),
                  Expanded(
                    flex: 2,
                    child: _buildActionButton(
                      icon: Icons.check,
                      label: loc.tr('confirm'),
                      color: _controller.isNotEmpty
                          ? AppColors.blueAccent
                          : AppColors.white12,
                      textColor: _controller.isNotEmpty
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.54),
                      onTap: () async {
                        if (_controller.isEmpty) return;
                        final Uint8List? signatureBytes = await _controller
                            .toPngBytes();
                        if (context.mounted) {
                          Navigator.pop(context, signatureBytes);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingLarge),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: Dimensions.iconSmall),
            const Gap(Dimensions.gapSmall),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.fontTiny,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
