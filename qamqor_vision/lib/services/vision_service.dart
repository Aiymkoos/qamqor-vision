import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Распознанный предмет и уверенность модели от 0 до 1.
class RecognizedLabel {
  const RecognizedLabel(this.label, this.confidence);

  /// Метка ML Kit на английском — переводится через `ObjectLabels`.
  final String label;
  final double confidence;
}

/// Причина, по которой распознать не удалось.
enum SceneError { noCamera, permissionDenied, failed }

class SceneRecognitionException implements Exception {
  const SceneRecognitionException(this.kind);

  final SceneError kind;

  @override
  String toString() => 'SceneRecognitionException($kind)';
}

/// Источник описания обстановки.
///
/// Интерфейс отделён от реализации, чтобы экран можно было тестировать
/// без камеры: в тестах подставляется заглушка.
abstract class SceneRecognizer {
  Future<List<RecognizedLabel>> describeScene();

  Future<void> dispose();
}

/// Снимает кадр с камеры и распознаёт предметы моделью ML Kit на устройстве.
///
/// Работает офлайн: ни снимок, ни результат никуда не отправляются.
class CameraSceneRecognizer implements SceneRecognizer {
  CameraSceneRecognizer({double confidenceThreshold = 0.65})
    : _labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: confidenceThreshold),
      );

  final ImageLabeler _labeler;
  CameraController? _controller;

  @override
  Future<List<RecognizedLabel>> describeScene() async {
    await _ensureCamera();

    XFile? shot;
    try {
      shot = await _controller!.takePicture();
      final labels = await _labeler.processImage(
        InputImage.fromFilePath(shot.path),
      );
      // ML Kit отдаёт метки по убыванию уверенности; берём первые несколько,
      // потому что длинный список на слух не удержать.
      return labels
          .take(4)
          .map((l) => RecognizedLabel(l.label, l.confidence))
          .toList();
    } on CameraException catch (e) {
      throw SceneRecognitionException(_kindFor(e));
    } catch (_) {
      throw const SceneRecognitionException(SceneError.failed);
    } finally {
      // Снимок нужен только на время распознавания. Хранить фотографии
      // квартиры пользователя приложению незачем.
      if (shot != null) {
        try {
          await File(shot.path).delete();
        } catch (_) {
          // Файл мог быть уже убран системой — это не повод падать.
        }
      }
    }
  }

  Future<void> _ensureCamera() async {
    if (_controller != null) return;

    final List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      throw SceneRecognitionException(_kindFor(e));
    }
    if (cameras.isEmpty) {
      throw const SceneRecognitionException(SceneError.noCamera);
    }

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      camera,
      // Высокое разрешение точность меток почти не поднимает, а кадр
      // готовится заметно дольше — пользователь ждёт ответа.
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      await controller.dispose();
      throw SceneRecognitionException(_kindFor(e));
    }
    _controller = controller;
  }

  SceneError _kindFor(CameraException e) {
    final code = e.code.toLowerCase();
    if (code.contains('permission') || code.contains('denied')) {
      return SceneError.permissionDenied;
    }
    if (code.contains('nocamera') || code.contains('notfound')) {
      return SceneError.noCamera;
    }
    return SceneError.failed;
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    await _labeler.close();
  }
}
