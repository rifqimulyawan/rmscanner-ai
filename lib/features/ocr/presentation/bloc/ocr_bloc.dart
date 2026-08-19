import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmscanner/core/services/ocr_service.dart';
import 'package:rmscanner/features/ocr/presentation/bloc/ocr_event.dart';
import 'package:printing/printing.dart';
import 'package:rmscanner/features/ocr/presentation/bloc/ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final OcrService ocrService;
  OcrBloc({required this.ocrService}) : super(OcrInitial()) {
    on<ExtractTextFromImage>(_onExtractTextFromImage);
    on<ExtractTextFromPdf>(_onExtractTextFromPdf);
    on<ClearOcrResult>(_onClearOcrResult);
  }
  Future<void> _onExtractTextFromPdf(
    ExtractTextFromPdf event,
    Emitter<OcrState> emit,
  ) async {
    emit(OcrProcessing());
    try {
      final tempDir = Directory('${Directory.systemTemp.path}/ocr_temp');
      if (!await tempDir.exists()) await tempDir.create(recursive: true);
      final stringBuffer = StringBuffer();
      final bytes = await File(event.pdfPath).readAsBytes();
      int pageCounter = 0;
      // Stream PDF pages individually to prevent native OOM crashes on massive files
      await for (var page in Printing.raster(bytes, dpi: 200)) {
        pageCounter++;
        final uiImage = await page.toImage();
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        uiImage.dispose();
        // CRITICAL memory free
        if (byteData != null) {
          final tempPath = '${tempDir.path}/temp_page_$pageCounter.png';
          await File(
            tempPath,
          ).writeAsBytes(byteData.buffer.asUint8List(), flush: true);
          final text = await ocrService.extractTextFromImage(
            tempPath,
            language: event.language,
          );
          if (text.trim().isNotEmpty) {
            stringBuffer.writeln(text);
            stringBuffer.writeln('--- Page Break ---');
          }
          try {
            await File(tempPath).delete();
          } catch (_) {}
        }
      }
      final fullText = stringBuffer.toString();
      if (fullText.trim().isEmpty) {
        emit(const OcrError('no_text_in_pdf'));
        return;
      }
      final wordCount = fullText
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;
      final characterCount = fullText.replaceAll(RegExp(r'\s+'), '').length;
      emit(
        OcrSuccess(
          extractedText: fullText,
          wordCount: wordCount,
          characterCount: characterCount,
        ),
      );
    } catch (e) {
      emit(OcrError(e.toString()));
    }
  }

  Future<void> _onExtractTextFromImage(
    ExtractTextFromImage event,
    Emitter<OcrState> emit,
  ) async {
    emit(OcrProcessing());
    try {
      final text = await ocrService.extractTextFromImage(
        event.imagePath,
        language: event.language,
      );
      if (text.isEmpty) {
        emit(const OcrError('no_text_in_image'));
        return;
      }
      final wordCount = text
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;
      final characterCount = text.replaceAll(RegExp(r'\s+'), '').length;
      emit(
        OcrSuccess(
          extractedText: text,
          wordCount: wordCount,
          characterCount: characterCount,
        ),
      );
    } catch (e) {
      emit(OcrError(e.toString()));
    }
  }

  void _onClearOcrResult(ClearOcrResult event, Emitter<OcrState> emit) {
    emit(OcrInitial());
  }

  @override
  Future<void> close() {
    ocrService.dispose();
    return super.close();
  }
}
