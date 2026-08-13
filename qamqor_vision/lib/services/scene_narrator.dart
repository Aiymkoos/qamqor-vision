import '../l10n/app_strings.dart';
import '../l10n/object_labels.dart';
import 'vision_service.dart';

/// Собирает из меток модели фразу, которую услышит пользователь.
///
/// Вынесено из экрана отдельно: это чистая функция, её можно проверить
/// тестами без камеры и без синтеза речи.
class SceneNarrator {
  SceneNarrator._();

  static String describe(
    List<RecognizedLabel> labels,
    AppLanguage language,
  ) {
    final strings = AppStrings.of(language);

    // Множество убирает повторы: разные метки модели переводятся одним
    // словом — например, «tree» и «wood» это оба «дерево».
    final names = labels
        .map((l) => ObjectLabels.translate(l.label, language))
        .whereType<String>()
        .toSet();

    // Пусто и когда модель ничего не увидела, и когда все метки оказались
    // вне словаря. Для пользователя разницы нет: описать нечем.
    if (names.isEmpty) return strings.nothingRecognized;

    return '${strings.seeIntro} ${names.join(', ')}.';
  }

  static String errorFor(SceneError error, AppLanguage language) {
    final strings = AppStrings.of(language);
    return switch (error) {
      SceneError.permissionDenied => strings.cameraDenied,
      SceneError.noCamera => strings.cameraMissing,
      SceneError.failed => strings.recognitionFailed,
    };
  }
}
