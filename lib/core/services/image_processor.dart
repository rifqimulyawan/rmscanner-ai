import 'dart:io';
import 'package:image/image.dart' as img;

class ImageProcessor {
  Future<File> enhanceImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imageFile;

    // Auto-adjust levels
    image = img.adjustColor(
      image,
      brightness: 1.1,
      contrast: 1.2,
      saturation: 0.9,
    );

    // Sharpen image = img.convolution(image, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);

    // Save enhanced image
    final enhancedBytes = img.encodeJpg(image, quality: 95);
    await imageFile.writeAsBytes(enhancedBytes);
    return imageFile;
  }

  Future<File> convertToGrayscale(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imageFile;
    image = img.grayscale(image);
    final grayBytes = img.encodeJpg(image, quality: 95);
    await imageFile.writeAsBytes(grayBytes);
    return imageFile;
  }

  Future<File> cropImage(
    File imageFile,
    int x,
    int y,
    int width,
    int height,
  ) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imageFile;
    image = img.copyCrop(image, x: x, y: y, width: width, height: height);
    final croppedBytes = img.encodeJpg(image, quality: 95);
    await imageFile.writeAsBytes(croppedBytes);
    return imageFile;
  }

  Future<File> rotateImage(File imageFile, int angle) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imageFile;
    image = img.copyRotate(image, angle: angle);
    final rotatedBytes = img.encodeJpg(image, quality: 95);
    await imageFile.writeAsBytes(rotatedBytes);
    return imageFile;
  }

  Future<File> createThumbnail(File imageFile, String thumbnailPath) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imageFile;

    // Resize to thumbnail size
    final thumbnail = img.copyResize(image, width: 200);
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);
    final thumbnailFile = File(thumbnailPath);
    await thumbnailFile.writeAsBytes(thumbnailBytes);
    return thumbnailFile;
  }

  Future<File> compressImage(File imageFile, {int quality = 85}) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return imageFile;
    final compressedBytes = img.encodeJpg(image, quality: quality);
    await imageFile.writeAsBytes(compressedBytes);
    return imageFile;
  }
}
