import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:go_router/go_router.dart';
import 'package:rmscanner/core/utils/pdf_action_helper.dart';
import 'package:rmscanner/core/utils/styles.dart';
import 'package:rmscanner/core/widgets/custom_app_bar.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: loc.tr('all_tools'),
        actionIcon: Icons.info_outline,
        onActionTap: () => context.push('/about'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth > 0
              ? constraints.maxWidth
              : 400;
          final int cols = ((width - 40) / 105).floor().clamp(2, 4);
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.horizontalPadding,
                    Dimensions.paddingSmall,
                    Dimensions.horizontalPadding,
                    Dimensions.bottomSheetPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernSection(context, loc.tr('pdf_tools'), [
                        _ToolData(
                          loc.tr('merge_pdf'),
                          Icons.merge_type,
                          AppColors.indigo,
                          (ctx) => PdfActionHelper.mergePdf(ctx),
                        ),
                        _ToolData(
                          loc.tr('split_pdf'),
                          Icons.call_split,
                          AppColors.teal,
                          (ctx) => PdfActionHelper.splitPdf(ctx),
                        ),
                        _ToolData(
                          loc.tr('compress_pdf'),
                          Icons.compress,
                          AppColors.purple,
                          (ctx) => PdfActionHelper.compressPdf(ctx),
                        ),
                        _ToolData(
                          loc.tr('rotate_pdf'),
                          Icons.rotate_right,
                          AppColors.orange,
                          (ctx) => PdfActionHelper.rotatePdf(ctx),
                        ),
                        _ToolData(
                          loc.tr('watermark_pdf'),
                          Icons.water_drop,
                          AppColors.teal,
                          (ctx) => PdfActionHelper.addWatermark(ctx),
                        ),
                        _ToolData(
                          loc.tr('reorder_pages'),
                          Icons.swap_vert,
                          AppColors.indigo,
                          (ctx) => PdfActionHelper.reorderPages(ctx),
                        ),
                      ], cols: cols),
                      const Gap(32),
                      _buildModernSection(context, loc.tr('converters'), [
                        _ToolData(
                          loc.tr('image_to_pdf'),
                          Icons.image,
                          AppColors.pink,
                          (ctx) => PdfActionHelper.imageToPdf(ctx),
                          subtitle: loc.tr('high_quality'),
                        ),
                        _ToolData(
                          loc.tr('pdf_to_image'),
                          Icons.picture_as_pdf,
                          AppColors.green,
                          (ctx) => PdfActionHelper.pdfToImage(ctx),
                          subtitle: loc.tr('fast_scan'),
                        ),
                        _ToolData(
                          loc.tr('text_to_pdf'),
                          Icons.description,
                          AppColors.brown,
                          (ctx) => PdfActionHelper.textToPdf(ctx),
                          subtitle: loc.tr('easy_edit'),
                        ),
                        _ToolData(
                          loc.tr('pdf_to_text'),
                          Icons.text_fields,
                          AppColors.blueGrey,
                          (ctx) => PdfActionHelper.pdfToText(ctx),
                          subtitle: loc.tr('extract_data'),
                        ),
                        _ToolData(
                          loc.tr('qr_scanner'),
                          Icons.qr_code_scanner,
                          AppColors.purple,
                          (ctx) => ctx.push('/qr-scanner'),
                          subtitle: loc.tr('scan_qr_barcode'),
                        ),
                      ], cols: cols),
                      const Gap(32),
                      _buildModernSection(
                        context,
                        loc.tr('privacy_security'),
                        [
                          _ToolData(
                            loc.tr('lock_pdf'),
                            Icons.lock,
                            AppColors.red,
                            (ctx) => PdfActionHelper.lockPdf(ctx),
                            subtitle: loc.tr('add_password_protection'),
                          ),
                          _ToolData(
                            loc.tr('unlock_pdf'),
                            Icons.lock_open,
                            AppColors.amber,
                            (ctx) => PdfActionHelper.unlockPdf(ctx),
                            subtitle: loc.tr('remove_restrictions'),
                          ),
                          _ToolData(
                            loc.tr('add_signature'),
                            Icons.gesture,
                            AppColors.blue,
                            (ctx) => _signatureFlow(ctx),
                            subtitle: loc.tr('digitally_sign'),
                          ),
                        ],
                        cols: cols,
                      ),
                    ],
                  ),
                ),
                // End SingleChildScrollView
              ),
              // End Expanded
            ],
          );
          // End Column
        },
      ),
    );
  }

  Widget _buildModernSection(
    BuildContext context,
    String title,
    List<_ToolData> tools, {
    int cols = 2,
  }) {
    final loc = AppLocalizations.of(context);
    final bool isSecurity = title == loc.tr('privacy_security');
    final bool isPdfTools = title == loc.tr('pdf_tools');
    final double aspectRatio = cols > 2
        ? (isPdfTools ? 1.5 : 1.3)
        : (isPdfTools ? 1.3 : 1.1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(Dimensions.gap),
            Text(title, style: Styles.sectionTitle(context)),
          ],
        ),
        const Gap(Dimensions.gapXL),
        if (isSecurity)
          Column(
            children: tools.map((tool) => _SecurityCard(tool: tool)).toList(),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: Dimensions.gap,
              crossAxisSpacing: Dimensions.gap,
              childAspectRatio: aspectRatio,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) => isPdfTools
                ? _buildPdfToolCard(context, tools[index])
                : _buildConverterCard(context, tools[index]),
          ),
      ],
    );
  }

  Widget _buildPdfToolCard(BuildContext context, _ToolData tool) {
    return InkWell(
      onTap: () => tool.onTap(context),
      borderRadius: BorderRadius.circular(Dimensions.radius),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.padding),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surface,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSmall),
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Icon(
                tool.icon,
                color: tool.color,
                size: Dimensions.iconSmall20,
              ),
            ),
            const Expanded(child: SizedBox(height: Dimensions.gapSmall)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tool.title,
                style: Styles.cardTitle(context).copyWith(height: 1.2, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterCard(BuildContext context, _ToolData tool) {
    return InkWell(
      onTap: () => tool.onTap(context),
      borderRadius: BorderRadius.circular(Dimensions.radius),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.padding),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.surface,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.padding),
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Icon(
                tool.icon,
                color: tool.color,
                size: Dimensions.iconSmall20,
              ),
            ),
            const Gap(Dimensions.gapSmall),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(tool.title, style: Styles.cardTitle(context).copyWith(fontSize: 12)),
            ),
            if (tool.subtitle != null) ...[
              const Gap(2),
              Flexible(
                child: Text(
                  tool.subtitle!,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _signatureFlow(BuildContext context) async {
    await PdfActionHelper.signatureFlow(context);
  }
}

class _SecurityCard extends StatefulWidget {
  final _ToolData tool;
  const _SecurityCard({required this.tool});
  @override
  State<_SecurityCard> createState() => _SecurityCardState();
}

class _SecurityCardState extends State<_SecurityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.tool.onTap(context);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          margin: const EdgeInsets.only(bottom: Dimensions.gap),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusXL),
            boxShadow: [
              BoxShadow(
                color: widget.tool.color.withValues(
                  alpha: _isPressed ? 0.3 : 0.04,
                ),
                blurRadius: _isPressed ? 15 : Dimensions.cardBlurRadius,
                offset: const Offset(0, Dimensions.cardShadowOffsetY),
              ),
            ],
            border: Border.all(
              color: _isPressed
                  ? widget.tool.color.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: _isPressed ? 1.5 : 1.0,
            ),
          ),
          child: CustomPaint(
            foregroundPainter: _LeftBorderPainter(
              color: widget.tool.color,
              radius: Dimensions.radiusXL,
              strokeWidth: _isPressed ? 6.0 : 4.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusXL),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Placeholder gap so content isn't under the thicker stroke
                    const Gap(Dimensions.gapSmall),
                    const Gap(Dimensions.padding),
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(Dimensions.padding),
                        decoration: BoxDecoration(
                          color: widget.tool.color.withValues(
                            alpha: _isPressed ? 0.2 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusLarge,
                          ),
                        ),
                        child: Icon(
                          widget.tool.icon,
                          color: widget.tool.color,
                          size: Dimensions.iconSmall20,
                        ),
                      ),
                    ),
                    const Gap(Dimensions.padding),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(Dimensions.padding),
                          Text(
                            widget.tool.title,
                            style: Styles.cardTitle(context).copyWith(fontSize: 14),
                          ),
                          const Gap(Dimensions.gapSmall),
                          Text(
                            widget.tool.subtitle ?? '',
                            style: Styles.cardSubtitle(context).copyWith(fontSize: 11),
                          ),
                          const Gap(Dimensions.padding),
                        ],
                      ),
                    ),
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.only(right: _isPressed ? 4.0 : 0.0),
                        child: Icon(
                          Icons.chevron_right,
                          color: _isPressed
                              ? widget.tool.color
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.3,
                                ),
                          size: Dimensions.iconMedium,
                        ),
                      ),
                    ),
                    const Gap(Dimensions.padding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  _LeftBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    // Softens the ends nicely
    final inset = strokeWidth / 2;
    final r = radius - inset;
    if (r <= 0) return;
    final path = Path();
    // Start slightly inside the top horizontal line so it fully wraps the corner
    path.moveTo(radius + inset, inset);
    // Draw top-left arc
    path.arcToPoint(
      Offset(inset, radius + inset),
      radius: Radius.circular(r),
      clockwise: false,
    );
    // Draw left vertical line
    path.lineTo(inset, size.height - radius - inset);
    // Draw bottom-left arc
    path.arcToPoint(
      Offset(radius + inset, size.height - inset),
      radius: Radius.circular(r),
      clockwise: false,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LeftBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _ToolData {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Function(BuildContext) onTap;
  _ToolData(this.title, this.icon, this.color, this.onTap, {this.subtitle});
}
