import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  TextRecognizer? _textRecognizer;
  TextRecognitionScript _currentScript = TextRecognitionScript.latin;
  static String buildSortedText(List<TextBlock> blocks) {
    if (blocks.isEmpty) return '';
    final sorted = List<TextBlock>.from(blocks);
    sorted.sort((a, b) {
      final topDiff = (a.boundingBox.top - b.boundingBox.top).abs();
      final avgHeight = (a.boundingBox.height + b.boundingBox.height) / 2;
      // If two blocks overlap vertically within 50% of the average height
      // treat them as being on the same line.
      final threshold = avgHeight * 0.5;
      if (topDiff < threshold) {
        // Same line â€” sort left to right
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      }
      // Different lines â€” sort top to bottom
      return a.boundingBox.top.compareTo(b.boundingBox.top);
    });
    return sorted.map((block) => block.text).join('\n');
  }

  TextRecognitionScript _getScriptForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'chinese':
        return TextRecognitionScript.chinese;
      case 'hindi':
      case 'marathi':
      case 'nepali':
        return TextRecognitionScript.devanagiri;
      case 'japanese':
        return TextRecognitionScript.japanese;
      case 'korean':
        return TextRecognitionScript.korean;
      case 'english':
      case 'indonesian':
      case 'french':
      case 'german':
      case 'spanish':
      default:
        return TextRecognitionScript.latin;
    }
  }

  void _ensureRecognizerForLanguage(String language) {
    final requiredScript = _getScriptForLanguage(language);
    if (_textRecognizer == null || _currentScript != requiredScript) {
      _textRecognizer?.close();
      _textRecognizer = TextRecognizer(script: requiredScript);
      _currentScript = requiredScript;
    }
  }

  Future<String> extractTextFromImage(
    String imagePath, {
    String language = 'English',
  }) async {
    try {
      _ensureRecognizerForLanguage(language);
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText = await _textRecognizer!.processImage(
        inputImage,
      );
      return buildSortedText(recognizedText.blocks);
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  Future<List<TextBlock>> extractTextBlocks(
    String imagePath, {
    String language = 'English',
  }) async {
    try {
      _ensureRecognizerForLanguage(language);
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText = await _textRecognizer!.processImage(
        inputImage,
      );
      return recognizedText.blocks;
    } catch (e) {
      throw Exception('Failed to extract text blocks: $e');
    }
  }

  Future<Map<String, dynamic>> extractTextWithMetadata(
    String imagePath, {
    String language = 'English',
  }) async {
    try {
      _ensureRecognizerForLanguage(language);
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText = await _textRecognizer!.processImage(
        inputImage,
      );
      final List<Map<String, dynamic>> blocks = [];
      for (var block in recognizedText.blocks) {
        blocks.add({
          'text': block.text,
          'boundingBox': {
            'left': block.boundingBox.left,
            'top': block.boundingBox.top,
            'right': block.boundingBox.right,
            'bottom': block.boundingBox.bottom,
          },
        });
      }
      return {
        'fullText': buildSortedText(recognizedText.blocks),
        'blocks': blocks,
        'blockCount': recognizedText.blocks.length,
      };
    } catch (e) {
      throw Exception('Failed to extract text with metadata: $e');
    }
  }

  void dispose() {
    _textRecognizer?.close();
  }
}
