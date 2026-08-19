import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

Future<void> _mergePdfsInIsolate(Map<String, dynamic> args) async {
  final List<String> inputPaths = args['inputPaths'];
  final String outputPath = args['outputPath'];
  final sf.PdfDocument finalDoc = sf.PdfDocument();
  for (final path in inputPaths) {
    final Uint8List bytes = await File(path).readAsBytes();
    final sf.PdfDocument tempDoc = sf.PdfDocument(inputBytes: bytes);
    final int pageCount = tempDoc.pages.count;
    for (int i = 0; i < pageCount; i++) {
      final srcPage = tempDoc.pages[i];
      finalDoc.pageSettings.size = srcPage.size;
      finalDoc.pageSettings.margins.all = 0;
      final newPage = finalDoc.pages.add();
      newPage.graphics.drawPdfTemplate(
        srcPage.createTemplate(),
        const ui.Offset(0, 0),
      );
    }
    tempDoc.dispose();
  }
  final Uint8List savedBytes = Uint8List.fromList(await finalDoc.save());
  finalDoc.dispose();
  await File(outputPath).writeAsBytes(savedBytes, flush: true);
}

Future<void> _splitPdfInIsolate(Map<String, dynamic> args) async {
  final String inputPath = args['inputPath'];
  final String outputPath = args['outputPath'];
  final List<int> pageIndexes = args['pageIndexes'];
  final Uint8List bytes = await File(inputPath).readAsBytes();
  final sf.PdfDocument sourceDoc = sf.PdfDocument(inputBytes: bytes);
  final sf.PdfDocument outputDoc = sf.PdfDocument();
  final int total = sourceDoc.pages.count;
  for (final index in pageIndexes) {
    if (index < total) {
      final srcPage = sourceDoc.pages[index];
      outputDoc.pageSettings.size = srcPage.size;
      outputDoc.pageSettings.margins.all = 0;
      final newPage = outputDoc.pages.add();
      newPage.graphics.drawPdfTemplate(
        srcPage.createTemplate(),
        const ui.Offset(0, 0),
      );
    }
  }
  sourceDoc.dispose();
  final Uint8List savedBytes = Uint8List.fromList(await outputDoc.save());
  outputDoc.dispose();
  await File(outputPath).writeAsBytes(savedBytes, flush: true);
}

Future<void> _rotatePdfInIsolate(Map<String, dynamic> args) async {
  final String inputPath = args['inputPath'];
  final String outputPath = args['outputPath'];
  final int rotationAngle = args['rotationAngle'];
  final String selection = args['selection'];
  final List<int> bytes = await File(inputPath).readAsBytes();
  final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
  sf.PdfPageRotateAngle angle;
  switch (rotationAngle) {
    case 90:
      angle = sf.PdfPageRotateAngle.rotateAngle90;
      break;
    case 180:
      angle = sf.PdfPageRotateAngle.rotateAngle180;
      break;
    case 270:
      angle = sf.PdfPageRotateAngle.rotateAngle270;
      break;
    default:
      angle = sf.PdfPageRotateAngle.rotateAngle0;
  }
  for (int i = 0; i < document.pages.count; i++) {
    bool shouldRotate = false;
    if (selection == 'all') {
      shouldRotate = true;
    } else if (selection == 'even') {
      shouldRotate = (i + 1) % 2 == 0;
    } else if (selection == 'odd') {
      shouldRotate = (i + 1) % 2 != 0;
    }
    if (shouldRotate) document.pages[i].rotation = angle;
  }
  final List<int> savedBytes = await document.save();
  document.dispose();
  await File(outputPath).writeAsBytes(savedBytes);
}

Future<void> _lockPdfInIsolate(Map<String, dynamic> args) async {
  final String inputPath = args['inputPath'];
  final String outputPath = args['outputPath'];
  final String password = args['password'];
  final Uint8List bytes = await File(inputPath).readAsBytes();
  final document = sf.PdfDocument(inputBytes: bytes);
  document.security.userPassword = password;
  document.security.ownerPassword = password;
  final Uint8List savedBytes = Uint8List.fromList(await document.save());
  document.dispose();
  await File(outputPath).writeAsBytes(savedBytes, flush: true);
}

Future<bool> _isPdfEncryptedInIsolate(String path) async {
  try {
    final bytes = await File(path).readAsBytes();
    final doc = sf.PdfDocument(inputBytes: bytes);
    doc.dispose();
    return false;
  } catch (e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('password') ||
        errorStr.contains('invalid') ||
        errorStr.contains('incorrect')) {
      return true;
    }
    return false;
  }
}

Future<void> _unlockPdfInIsolate(Map<String, dynamic> args) async {
  final String inputPath = args['inputPath'];
  final String outputPath = args['outputPath'];
  final String password = args['password'];
  final Uint8List bytes = await File(inputPath).readAsBytes();
  final document = sf.PdfDocument(inputBytes: bytes, password: password);
  document.security.userPassword = '';
  document.security.ownerPassword = '';
  final Uint8List savedBytes = Uint8List.fromList(await document.save());
  document.dispose();
  await File(outputPath).writeAsBytes(savedBytes, flush: true);
}

Future<int> _getPdfPageCountInIsolate(Map<String, dynamic> args) async {
  final String inputPath = args['inputPath'];
  final List<int> bytes = await File(inputPath).readAsBytes();
  final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
  final int count = document.pages.count;
  document.dispose();
  return count;
}

Future<void> _reorderPagesInIsolate(Map<String, dynamic> args) async {
  final String inputPath = args['inputPath'];
  final String outputPath = args['outputPath'];
  final List<int> pageOrder = args['pageOrder'];
  final Uint8List bytes = await File(inputPath).readAsBytes();
  final sf.PdfDocument sourceDoc = sf.PdfDocument(inputBytes: bytes);
  final sf.PdfDocument outputDoc = sf.PdfDocument();
  for (final index in pageOrder) {
    if (index < sourceDoc.pages.count) {
      final srcPage = sourceDoc.pages[index];
      outputDoc.pageSettings.size = srcPage.size;
      outputDoc.pageSettings.margins.all = 0;
      final newPage = outputDoc.pages.add();
      newPage.graphics.drawPdfTemplate(
        srcPage.createTemplate(),
        const ui.Offset(0, 0),
      );
    }
  }
  sourceDoc.dispose();
  final Uint8List savedBytes = Uint8List.fromList(await outputDoc.save());
  outputDoc.dispose();
  await File(outputPath).writeAsBytes(savedBytes, flush: true);
}

class PdfService {
  Future<File> createPdfFromImages(
    List<String> imagePaths,
    String outputPath, {
    PdfPageFormat? format,
  }) async {
    final pdf = pw.Document();
    final pageFormat = format ?? PdfPageFormat.a4;
    for (final imagePath in imagePaths) {
      final imageBytes = await File(imagePath).readAsBytes();
      final image = pw.MemoryImage(imageBytes);
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) =>
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> createPdfFromText(
    String text,
    String outputPath, {
    PdfPageFormat? format,
  }) async {
    final pdf = pw.Document();
    final pageFormat = format ?? PdfPageFormat.a4;
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Paragraph(text: text, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<List<String>> pdfToImages(String pdfPath, String outputDir) async {
    final List<String> imagePaths = [];
    try {
      final bytes = await File(pdfPath).readAsBytes();
      final dir = Directory(outputDir);
      if (!await dir.exists()) await dir.create(recursive: true);
      await for (var page in Printing.raster(bytes, dpi: 200)) {
        final uiImage = await page.toImage();
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        // EXTREMELY CRITICAL: Explicitly release native Image memory immediately
        // Failing to do this on 100+ page PDFs will cause instant native OOM crashes.
        uiImage.dispose();
        if (byteData != null) {
          final imagePath = '${dir.path}/page_${imagePaths.length + 1}.png';
          await File(
            imagePath,
          ).writeAsBytes(byteData.buffer.asUint8List(), flush: true);
          imagePaths.add(imagePath);
        }
      }
    } catch (e) {
      throw Exception('Failed to convert PDF to images: $e');
    }
    return imagePaths;
  }

  Future<File> mergePdfs(List<String> inputPaths, String outputPath) async {
    try {
      await compute(_mergePdfsInIsolate, {
        'inputPaths': inputPaths,
        'outputPath': outputPath,
      });
      return File(outputPath);
    } catch (e) {
      throw Exception('Failed to merge PDFs: $e');
    }
  }

  Future<File> splitPdf(
    String inputPath,
    String outputPath,
    List<int> pageIndexes,
  ) async {
    try {
      await compute(_splitPdfInIsolate, {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'pageIndexes': pageIndexes,
      });
      return File(outputPath);
    } catch (e) {
      throw Exception('Failed to split PDF: $e');
    }
  }

  Future<File> rotatePdf(
    String inputPath,
    String outputPath,
    int rotationAngle, {
    String selection = 'all',
  }) async {
    try {
      await compute(_rotatePdfInIsolate, {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'rotationAngle': rotationAngle,
        'selection': selection,
      });
      return File(outputPath);
    } catch (e) {
      throw Exception('Failed to rotate PDF: $e');
    }
  }

  Future<int> getPdfPageCount(String inputPath) async {
    try {
      return await compute(_getPdfPageCountInIsolate, {'inputPath': inputPath});
    } catch (e) {
      throw Exception('Failed to get PDF page count: $e');
    }
  }

  Future<File> addSignatureToPdf(
    String inputPath,
    String outputPath,
    Uint8List signatureBytes, {
    required double xPercent,
    required double yPercent,
    required double widthPercent,
    required double heightPercent,
    required int pageIndex,
  }) async {
    try {
      final bytes = await File(inputPath).readAsBytes();
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
      final sf.PdfPage page = document.pages[pageIndex];
      final double pdfWidth = page.getClientSize().width;
      final double pdfHeight = page.getClientSize().height;
      final sf.PdfBitmap bitmap = sf.PdfBitmap(signatureBytes);
      page.graphics.drawImage(
        bitmap,
        ui.Rect.fromLTWH(
          xPercent * pdfWidth,
          yPercent * pdfHeight,
          widthPercent * pdfWidth,
          heightPercent * pdfHeight,
        ),
      );
      final savedBytes = await document.save();
      document.dispose();
      final file = File(outputPath);
      await file.writeAsBytes(savedBytes);
      return file;
    } catch (e) {
      throw Exception('Failed to add signature to PDF: $e');
    }
  }

  Future<File> addSignatureToImage(
    String inputPath,
    String outputPath,
    Uint8List signatureBytes, {
    required double xPercent,
    required double yPercent,
    required double widthPercent,
    required double heightPercent,
  }) async {
    try {
      final baseBytes = await File(inputPath).readAsBytes();
      // Decode base and signature images using dart:ui
      final ui.Codec baseCodec = await ui.instantiateImageCodec(baseBytes);
      final ui.FrameInfo baseFrame = await baseCodec.getNextFrame();
      final ui.Image baseImage = baseFrame.image;
      final ui.Codec sigCodec = await ui.instantiateImageCodec(signatureBytes);
      final ui.FrameInfo sigFrame = await sigCodec.getNextFrame();
      final ui.Image sigImage = sigFrame.image;
      final int baseWidth = baseImage.width;
      final int baseHeight = baseImage.height;
      final int sigW = (widthPercent * baseWidth).toInt();
      final int sigH = (heightPercent * baseHeight).toInt();
      final int sigX = (xPercent * baseWidth).toInt();
      final int sigY = (yPercent * baseHeight).toInt();
      // Composite using PictureRecorder
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      canvas.drawImage(baseImage, Offset.zero, Paint());
      // Scale and draw the signature
      final ui.Codec resizedSigCodec = await ui.instantiateImageCodec(
        signatureBytes,
        targetWidth: sigW,
        targetHeight: sigH,
      );
      final ui.FrameInfo resizedFrame = await resizedSigCodec.getNextFrame();
      canvas.drawImage(
        resizedFrame.image,
        Offset(sigX.toDouble(), sigY.toDouble()),
        Paint(),
      );
      resizedFrame.image.dispose();
      final ui.Picture picture = recorder.endRecording();
      final ui.Image resultImage = await picture.toImage(baseWidth, baseHeight);
      picture.dispose();
      baseImage.dispose();
      sigImage.dispose();
      final ByteData? byteData = await resultImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      resultImage.dispose();
      if (byteData == null) throw Exception('Failed to encode image');
      // Compress to JPEG using native compressor
      final Uint8List compressed = await FlutterImageCompress.compressWithList(
        byteData.buffer.asUint8List(),
        quality: 95,
        format: CompressFormat.jpeg,
      );
      final file = File(outputPath);
      await file.writeAsBytes(compressed, flush: true);
      return file;
    } catch (e) {
      throw Exception('Failed to add signature to Image: $e');
    }
  }

  Future<File> lockPdf(
    String inputPath,
    String outputPath,
    String password,
  ) async {
    try {
      await compute(_lockPdfInIsolate, {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'password': password,
      });
      return File(outputPath);
    } catch (e) {
      throw Exception('Failed to lock PDF: $e');
    }
  }

  Future<File> unlockPdf(
    String inputPath,
    String outputPath,
    String password,
  ) async {
    try {
      await compute(_unlockPdfInIsolate, {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'password': password,
      });
      return File(outputPath);
    } catch (e) {
      throw Exception('Failed to unlock PDF: $e');
    }
  }

  Future<File> compressPdf(
    String inputPath,
    String outputPath,
    int quality,
  ) async {
    try {
      final bytes = await File(inputPath).readAsBytes();
      final sf.PdfDocument outputDocument = sf.PdfDocument();
      // Map quality to DPI settings
      // High: 40%, Medium: 70%, Low: 90%
      int dpi = 130;
      if (quality <= 40) {
        dpi = 100;
      } else if (quality >= 90) {
        dpi = 150;
      }
      await for (var page in Printing.raster(bytes, dpi: dpi.toDouble())) {
        final uiImage = await page.toImage();
        // COMPOSITE: Draw onto white background to prevent black background
        // when converting PDFs with transparency to JPEG.
        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final ui.Canvas canvas = ui.Canvas(recorder);
        final ui.Paint paint = ui.Paint()..color = Colors.white;
        canvas.drawRect(
          ui.Rect.fromLTWH(
            0,
            0,
            uiImage.width.toDouble(),
            uiImage.height.toDouble(),
          ),
          paint,
        );
        canvas.drawImage(uiImage, ui.Offset.zero, ui.Paint());
        final ui.Picture picture = recorder.endRecording();
        final ui.Image whiteBgImage = await picture.toImage(
          uiImage.width,
          uiImage.height,
        );
        final byteData = await whiteBgImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        // CRITICAL: Release native memory immediately
        uiImage.dispose();
        whiteBgImage.dispose();
        picture.dispose();
        if (byteData != null) {
          final Uint8List inputBytes = byteData.buffer.asUint8List();
          // Use native compressor for heavy lifting
          final Uint8List compressedBytes =
              await FlutterImageCompress.compressWithList(
                inputBytes,
                quality: quality,
                format: CompressFormat.jpeg,
              );
          final sf.PdfPage pdfPage = outputDocument.pages.add();
          final sf.PdfBitmap bitmap = sf.PdfBitmap(compressedBytes);
          // Draw image to fill the page
          pdfPage.graphics.drawImage(
            bitmap,
            Rect.fromLTWH(
              0,
              0,
              pdfPage.getClientSize().width,
              pdfPage.getClientSize().height,
            ),
          );

          // Memory breathing: Allow native memory & GC to reclaim space
          // before starting next high-memory page operation.
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }
      final List<int> savedBytes = await outputDocument.save();
      outputDocument.dispose();
      final file = File(outputPath);
      await file.writeAsBytes(savedBytes, flush: true);
      return file;
    } catch (e) {
      throw Exception('Failed to compress PDF: $e');
    }
  }

  Future<bool> isPdfEncrypted(String path) async {
    try {
      return await compute(_isPdfEncryptedInIsolate, path);
    } catch (e) {
      return false;
    }
  }

  Future<File> addWatermark(
    String inputPath,
    String outputPath, {
    required String text,
    double opacity = 0.3,
    double fontSize = 50,
    double rotation = -45,
    Color color = Colors.grey,
    bool isBold = false,
    bool isItalic = false,
    bool isTiled = false,
    String fontFamily = 'helvetica',
  }) async {
    try {
      final bytes = await File(inputPath).readAsBytes();
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
      sf.PdfFontStyle style = sf.PdfFontStyle.regular;
      if (isBold && !isItalic) {
        style = sf.PdfFontStyle.bold;
      } else if (isItalic && !isBold) {
        style = sf.PdfFontStyle.italic;
      }
      final sf.PdfFontFamily pdfFontFamily = switch (fontFamily) {
        'times' => sf.PdfFontFamily.timesRoman,
        'courier' => sf.PdfFontFamily.courier,
        _ => sf.PdfFontFamily.helvetica,
      };
      final sf.PdfFont font = sf.PdfStandardFont(
        pdfFontFamily,
        fontSize,
        style: style,
        multiStyle: (isBold && isItalic) ? [sf.PdfFontStyle.bold, sf.PdfFontStyle.italic] : null,
      );
      final sf.PdfColor pdfColor = sf.PdfColor(
        (color.r * 255.0).round().clamp(0, 255),
        (color.g * 255.0).round().clamp(0, 255),
        (color.b * 255.0).round().clamp(0, 255),
        (opacity * 255).toInt(),
      );
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        final size = page.getClientSize();
        page.graphics.save();
        page.graphics.translateTransform(size.width / 2, size.height / 2);
        page.graphics.rotateTransform(rotation);
        final sf.PdfStringFormat format = sf.PdfStringFormat(
          alignment: sf.PdfTextAlignment.center,
          lineAlignment: sf.PdfVerticalAlignment.middle,
        );
        if (isTiled) {
          final textWidth = fontSize * text.length * 0.6;
          final textHeight = fontSize * 1.5;
          final spacingX = textWidth + fontSize * 2;
          final spacingY = textHeight + fontSize * 2;
          final cols = (size.width / spacingX).ceil() + 2;
          final rows = (size.height / spacingY).ceil() + 2;
          final startX = -(cols * spacingX) / 2;
          final startY = -(rows * spacingY) / 2;
          for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
              final x = startX + c * spacingX + (r % 2 == 0 ? 0 : spacingX / 2);
              final y = startY + r * spacingY;
              page.graphics.drawString(
                text,
                font,
                brush: sf.PdfSolidBrush(pdfColor),
                bounds: ui.Rect.fromCenter(
                  center: ui.Offset(x, y),
                  width: textWidth + fontSize,
                  height: textHeight,
                ),
                format: format,
              );
            }
          }
        } else {
          page.graphics.drawString(
            text,
            font,
            brush: sf.PdfSolidBrush(pdfColor),
            bounds: ui.Rect.fromCenter(
              center: ui.Offset(0, 0),
              width: size.width,
              height: fontSize * 2,
            ),
            format: format,
          );
        }
        page.graphics.restore();
      }
      final savedBytes = await document.save();
      document.dispose();
      final file = File(outputPath);
      await file.writeAsBytes(savedBytes, flush: true);
      return file;
    } catch (e) {
      throw Exception('Failed to add watermark: $e');
    }
  }

  Future<File> reorderPages(
    String inputPath,
    String outputPath,
    List<int> pageOrder,
  ) async {
    try {
      await compute(_reorderPagesInIsolate, {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'pageOrder': pageOrder,
      });
      return File(outputPath);
    } catch (e) {
      throw Exception('Failed to reorder pages: $e');
    }
  }

  Future<List<Uint8List>> getPageThumbnails(String inputPath) async {
    final List<Uint8List> thumbnails = [];
    try {
      final bytes = await File(inputPath).readAsBytes();
      await for (var page in Printing.raster(bytes, dpi: 72)) {
        final uiImage = await page.toImage();
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        uiImage.dispose();
        if (byteData != null) {
          thumbnails.add(byteData.buffer.asUint8List());
        }
      }
    } catch (e) {
      throw Exception('Failed to get page thumbnails: $e');
    }
    return thumbnails;
  }

  Future<Uint8List?> renderFirstPage(String inputPath) async {
    try {
      final bytes = await File(inputPath).readAsBytes();
      await for (var page in Printing.raster(bytes, dpi: 72)) {
        final uiImage = await page.toImage();
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        uiImage.dispose();
        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
        break;
      }
    } catch (e) {
      debugPrint('Failed to render first page: $e');
    }
    return null;
  }
}
