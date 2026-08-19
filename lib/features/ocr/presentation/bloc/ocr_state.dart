import 'package:equatable/equatable.dart';

// States
abstract class OcrState extends Equatable {
  const OcrState();
  @override
  List<Object?> get props => [];
}

class OcrInitial extends OcrState {}

class OcrProcessing extends OcrState {}

class OcrSuccess extends OcrState {
  final String extractedText;
  final int wordCount;
  final int characterCount;
  const OcrSuccess({
    required this.extractedText,
    required this.wordCount,
    required this.characterCount,
  });
  @override
  List<Object?> get props => [extractedText, wordCount, characterCount];
}

class OcrError extends OcrState {
  final String message;
  const OcrError(this.message);
  @override
  List<Object?> get props => [message];
}
