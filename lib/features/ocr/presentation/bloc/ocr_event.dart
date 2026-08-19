import 'package:equatable/equatable.dart';

// Events
abstract class OcrEvent extends Equatable {
  const OcrEvent();
  @override
  List<Object?> get props => [];
}

class ExtractTextFromImage extends OcrEvent {
  final String imagePath;
  final String language;
  const ExtractTextFromImage(this.imagePath, {this.language = 'English'});
  @override
  List<Object?> get props => [imagePath, language];
}

class ExtractTextFromPdf extends OcrEvent {
  final String pdfPath;
  final String language;
  const ExtractTextFromPdf(this.pdfPath, {this.language = 'English'});
  @override
  List<Object?> get props => [pdfPath, language];
}

class ExtractTextFromCamera extends OcrEvent {}

class ClearOcrResult extends OcrEvent {}
