import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }
    _controller = CameraController(
      _cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
  }

  CameraController? get controller => _controller;
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    try {
      return await _controller!.takePicture();
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null) {
      await _controller!.setFlashMode(mode);
    }
  }

  FlashMode get currentFlashMode =>
      _controller?.value.flashMode ?? FlashMode.off;
}
