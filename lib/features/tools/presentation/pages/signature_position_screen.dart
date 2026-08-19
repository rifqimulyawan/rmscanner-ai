import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:printing/printing.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';

class SignaturePositionScreen extends StatefulWidget {
  final File file;
  final Uint8List signatureBytes;
  final bool isPdf;
  const SignaturePositionScreen({
    super.key,
    required this.file,
    required this.signatureBytes,
    required this.isPdf,
  });
  @override
  State<SignaturePositionScreen> createState() =>
      _SignaturePositionScreenState();
}

class _SignaturePositionScreenState extends State<SignaturePositionScreen> {
  // Relative position and scale
  double xPercent = 0.5;
  double yPercent = 0.5;
  double scale = 1.0;
  List<Uint8List> pages = [];
  bool isLoading = true;
  int activePageIndex = 0;
  // Base dimensions for the signature ratio relative to the screen width
  final double baseWidth = Dimensions.signatureBaseWidth;
  final double baseHeight = Dimensions.signatureBaseHeight;
  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      if (widget.isPdf) {
        final bytes = await widget.file.readAsBytes();
        final List<Uint8List> renderedPages = [];
        await for (var page in Printing.raster(bytes, dpi: 150)) {
          final image = await page.toImage();
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          if (png != null) {
            if (mounted) renderedPages.add(png.buffer.asUint8List());
          }
        }
        if (mounted) {
          setState(() {
            pages = renderedPages;
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading preview: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onConfirm(Size constraintsSize) {
    // Current width and height of the signature block as a percentage of the entire page
    final renderedSigWidth = baseWidth * scale;
    final renderedSigHeight = baseHeight * scale;
    final widthPercent = renderedSigWidth / constraintsSize.width;
    final heightPercent = renderedSigHeight / constraintsSize.height;
    Navigator.pop(context, {
      'xPercent': xPercent,
      'yPercent': yPercent,
      'widthPercent': widthPercent,
      'heightPercent': heightPercent,
      'pageIndex': activePageIndex,
    });
  }

  void _selectPage(int index) {
    if (activePageIndex != index) {
      setState(() {
        activePageIndex = index;
        xPercent = 0.5;
        yPercent = 0.5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Deep premium dark mode
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          loc.tr('add_signature'),
          style: Styles.appBarTitle(context),
        ),
        centerTitle: true,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 4.0,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Dimensions.paddingTiny),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: Dimensions.iconMedium),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            // Main Document Engine Viewer
            if (isLoading)
              Center(
                child: SizedBox(
                  width: Dimensions.progressIndicatorSize,
                  height: Dimensions.progressIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingXL,
                  bottom: Dimensions.bottomSheetPadding * 2,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: widget.isPdf
                        ? _buildPdfPreview()
                        : _buildImagePreview(),
                  ),
                ),
              ),
            // Top Info indicator (Page control)
            if (!isLoading && widget.isPdf && pages.length > 1)
              Positioned(
                top: Dimensions.paddingXL * 5,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingLarge,
                      vertical: Dimensions.paddingTiny,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(Dimensions.radiusXL),
                      border: Border.all(color: AppColors.white24),
                    ),
                    child: Text(
                      loc.tr('page_of').replaceAll('\$current', '${activePageIndex + 1}').replaceAll('\$total', '${pages.length}'),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            // Floating Glassmorphism Bottom Control Tray
            Positioned(
              bottom: Dimensions.paddingXL,
              left: Dimensions.horizontalPadding,
              right: Dimensions.horizontalPadding,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusXL),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey900.withValues(alpha: 0.85),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.horizontalPadding,
                    vertical: Dimensions.paddingSmall,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.tr('drag_scale_signature'),
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: Dimensions.fontTiny,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(Dimensions.gapLarge),
                      // Scale Slider
                      Row(
                        children: [
                          const Icon(
                            Icons.text_decrease,
                            color: AppColors.white60,
                            size: Dimensions.iconSmall,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.blueAccent,
                                inactiveTrackColor: AppColors.white12,
                                thumbColor: AppColors.white,
                                overlayColor: AppColors.blueAccent.withValues(
                                  alpha: 0.2,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: scale,
                                min: Dimensions.sliderMin,
                                max: Dimensions.sliderMax,
                                onChanged: (val) => setState(() => scale = val),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.text_increase,
                            color: AppColors.white60,
                            size: Dimensions.iconSmall,
                          ),
                        ],
                      ),
                      const Gap(Dimensions.gapSmall),
                      // Confirm Action Button
                      SizedBox(
                        width: double.infinity,
                        height: Dimensions.actionButtonHeight,
                        child: FilledButton(
                          onPressed: () {
                            // The layout guarantees constraints; fetch from active Key
                            final RenderBox? box =
                                _pageKeys[activePageIndex]?.currentContext
                                        ?.findRenderObject()
                                    as RenderBox?;
                            if (box != null) {
                              _onConfirm(box.size);
                            } else if (!widget.isPdf) {
                              final RenderBox? imageBox =
                                  _pageKeys[0]?.currentContext
                                          ?.findRenderObject()
                                      as RenderBox?;
                              if (imageBox != null) _onConfirm(imageBox.size);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusLarge,
                              ),
                            ),
                          ),
                          child: Text(
                            loc.tr('confirm_save_stamp'),
                            style: const TextStyle(
                              fontSize: Dimensions.fontSmall,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final Map<int, GlobalKey> _pageKeys = {};

  Widget _buildPdfPreview() {
    return Column(
      children: List.generate(pages.length, (index) {
        final isSelected = activePageIndex == index;
        final key = _pageKeys.putIfAbsent(index, () => GlobalKey());
        return GestureDetector(
          onTap: () => _selectPage(index),
          child: Container(
            key: key,
            margin: EdgeInsets.only(
              bottom: Dimensions.gapXL,
              left: Dimensions.horizontalPadding,
              right: Dimensions.horizontalPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.blueAccent : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.blueAccent.withValues(alpha: 0.2)
                      : Colors.black54,
                  blurRadius: isSelected
                      ? Dimensions.cardBlurRadius
                      : Dimensions.cardBlurRadius / 2,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.memory(pages[index], fit: BoxFit.contain),
                if (isSelected)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final renderedWidth = baseWidth * scale;
                        final renderedHeight = baseHeight * scale;
                        // Map 0.0 - 1.0 percentages into physical coordinates
                        final physicalX = xPercent * constraints.maxWidth;
                        final physicalY = yPercent * constraints.maxHeight;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: physicalX,
                              top: physicalY,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    // Calculate delta as percentage of total wrapper constraint
                                    double deltaXPercent =
                                        details.delta.dx / constraints.maxWidth;
                                    double deltaYPercent =
                                        details.delta.dy /
                                        constraints.maxHeight;
                                    // Apply boundary limits so it doesn't leave the screen loosely
                                    xPercent = (xPercent + deltaXPercent).clamp(
                                      0.0,
                                      1.0 -
                                          (renderedWidth /
                                              constraints.maxWidth),
                                    );
                                    yPercent = (yPercent + deltaYPercent).clamp(
                                      0.0,
                                      1.0 -
                                          (renderedHeight /
                                              constraints.maxHeight),
                                    );
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.blueAccent.withValues(
                                      alpha: 0.1,
                                    ),
                                    border: Border.all(
                                      color: AppColors.blueAccent,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSmall,
                                  ),
                                  child: Image.memory(
                                    widget.signatureBytes,
                                    width: renderedWidth,
                                    height: renderedHeight,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImagePreview() {
    final key = _pageKeys.putIfAbsent(0, () => GlobalKey());
    return Container(
      key: key,
      margin: EdgeInsets.symmetric(horizontal: Dimensions.horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.blueAccent, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueAccent.withValues(alpha: 0.2),
            blurRadius: Dimensions.cardBlurRadius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.file(widget.file, fit: BoxFit.contain),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final renderedWidth = baseWidth * scale;
                final renderedHeight = baseHeight * scale;
                final physicalX = xPercent * constraints.maxWidth;
                final physicalY = yPercent * constraints.maxHeight;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: physicalX,
                      top: physicalY,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            double deltaXPercent =
                                details.delta.dx / constraints.maxWidth;
                            double deltaYPercent =
                                details.delta.dy / constraints.maxHeight;
                            xPercent = (xPercent + deltaXPercent).clamp(
                              0.0,
                              1.0 - (renderedWidth / constraints.maxWidth),
                            );
                            yPercent = (yPercent + deltaYPercent).clamp(
                              0.0,
                              1.0 - (renderedHeight / constraints.maxHeight),
                            );
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blueAccent.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.blueAccent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSmall,
                          ),
                          child: Image.memory(
                            widget.signatureBytes,
                            width: renderedWidth,
                            height: renderedHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
