import 'package:flutter_test/flutter_test.dart';
import 'package:qamqor_vision/l10n/app_strings.dart';
import 'package:qamqor_vision/l10n/object_labels.dart';
import 'package:qamqor_vision/services/scene_narrator.dart';
import 'package:qamqor_vision/services/vision_service.dart';

void main() {
  const russian = AppLanguage.russian;
  const kazakh = AppLanguage.kazakh;

  group('SceneNarrator', () {
    test('перечисляет распознанные предметы', () {
      final phrase = SceneNarrator.describe(const [
        RecognizedLabel('Table', 0.92),
        RecognizedLabel('Chair', 0.81),
      ], russian);

      expect(phrase, 'Вижу: стол, стул.');
    });

    test('озвучивает на казахском', () {
      final phrase = SceneNarrator.describe(const [
        RecognizedLabel('Door', 0.9),
      ], kazakh);

      expect(phrase, 'Көріп тұрмын: есік.');
    });

    test('не повторяет слово, если две метки переводятся одинаково', () {
      final phrase = SceneNarrator.describe(const [
        RecognizedLabel('Tree', 0.9),
        RecognizedLabel('Wood', 0.7),
      ], russian);

      expect(phrase, 'Вижу: дерево.');
    });

    test('пропускает метки, которых нет в словаре', () {
      final phrase = SceneNarrator.describe(const [
        RecognizedLabel('Table', 0.9),
        RecognizedLabel('Rugby', 0.8),
      ], russian);

      expect(phrase, 'Вижу: стол.');
    });

    test('честно сообщает, когда сказать нечего', () {
      // Модель что-то нашла, но ни одну метку мы не умеем перевести.
      // Выдумывать предметы в такой ситуации нельзя.
      final phrase = SceneNarrator.describe(const [
        RecognizedLabel('Rugby', 0.9),
      ], russian);

      expect(phrase, AppStrings.of(russian).nothingRecognized);
    });

    test('пустой список тоже даёт понятную фразу', () {
      expect(
        SceneNarrator.describe(const [], russian),
        AppStrings.of(russian).nothingRecognized,
      );
    });

    test('каждая ошибка объясняется по-своему', () {
      final strings = AppStrings.of(russian);

      expect(
        SceneNarrator.errorFor(SceneError.permissionDenied, russian),
        strings.cameraDenied,
      );
      expect(
        SceneNarrator.errorFor(SceneError.noCamera, russian),
        strings.cameraMissing,
      );
      expect(
        SceneNarrator.errorFor(SceneError.failed, russian),
        strings.recognitionFailed,
      );
    });
  });

  group('ObjectLabels', () {
    test('метка ищется независимо от регистра и пробелов', () {
      expect(ObjectLabels.translate('  TABLE ', russian), 'стол');
    });

    test('неизвестная метка не переводится', () {
      expect(ObjectLabels.translate('quasar', russian), isNull);
    });

    test('каждая метка переведена на оба языка', () {
      expect(ObjectLabels.size, greaterThan(100));
      expect(ObjectLabels.translate('window', russian), 'окно');
      expect(ObjectLabels.translate('window', kazakh), 'терезе');
    });
  });
}
