// Тесты главного экрана.
//
// Синтез речи и камера живут на стороне платформы, поэтому канал
// `flutter_tts` подменяется заглушкой, а распознавание — фейковым
// `SceneRecognizer`. Проверяется поведение интерфейса, а не движки.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qamqor_vision/l10n/app_strings.dart';
import 'package:qamqor_vision/main.dart';
import 'package:qamqor_vision/services/vision_service.dart';

class FakeSceneRecognizer implements SceneRecognizer {
  FakeSceneRecognizer({this.labels = const [], this.error});

  final List<RecognizedLabel> labels;
  final SceneError? error;

  @override
  Future<List<RecognizedLabel>> describeScene() async {
    final failure = error;
    if (failure != null) throw SceneRecognitionException(failure);
    return labels;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  const channel = MethodChannel('flutter_tts');

  final russian = AppStrings.of(AppLanguage.russian);
  final kazakh = AppStrings.of(AppLanguage.kazakh);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'isLanguageAvailable') return true;
      return 1;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> pumpApp(WidgetTester tester, {SceneRecognizer? recognizer}) async {
    await tester.pumpWidget(
      QamqorVisionApp(recognizer: recognizer ?? FakeSceneRecognizer()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('стартует на русском и показывает оба действия', (tester) async {
    await pumpApp(tester);

    expect(find.text(russian.describeButton), findsOneWidget);
    expect(find.text(russian.readTextButton), findsOneWidget);
    expect(find.text(russian.stopButton), findsOneWidget);
  });

  testWidgets('описание обстановки перечисляет распознанное', (tester) async {
    await pumpApp(
      tester,
      recognizer: FakeSceneRecognizer(
        labels: const [
          RecognizedLabel('Table', 0.9),
          RecognizedLabel('Chair', 0.8),
        ],
      ),
    );

    await tester.tap(find.text(russian.describeButton));
    await tester.pumpAndSettle();

    expect(find.text('Вижу: стол, стул.'), findsOneWidget);
  });

  testWidgets('отказ в доступе к камере объясняется словами', (tester) async {
    await pumpApp(
      tester,
      recognizer: FakeSceneRecognizer(error: SceneError.permissionDenied),
    );

    await tester.tap(find.text(russian.describeButton));
    await tester.pumpAndSettle();

    expect(find.text(russian.cameraDenied), findsOneWidget);
  });

  testWidgets('модель ничего не узнала — приложение это признаёт',
      (tester) async {
    await pumpApp(tester, recognizer: FakeSceneRecognizer());

    await tester.tap(find.text(russian.describeButton));
    await tester.pumpAndSettle();

    expect(find.text(russian.nothingRecognized), findsOneWidget);
  });

  testWidgets('чтение текста честно сообщает, что не реализовано',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(russian.readTextButton));
    await tester.pumpAndSettle();

    expect(find.text(russian.readTextStub), findsOneWidget);
  });

  testWidgets('кнопки подписаны для скринридера', (tester) async {
    // Без этого дерево семантики в тестах не строится.
    final handle = tester.ensureSemantics();

    await pumpApp(tester);

    expect(find.bySemanticsLabel(russian.describeButton), findsOneWidget);
    expect(find.bySemanticsLabel(russian.readTextButton), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '${russian.languageButton}: ${AppLanguage.kazakh.label}',
      ),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('переключение языка меняет подписи на казахские',
      (tester) async {
    await pumpApp(tester);

    // Кнопка подписана языком, на который переключаемся.
    await tester.tap(find.text(AppLanguage.kazakh.label));
    await tester.pumpAndSettle();

    expect(find.text(kazakh.describeButton), findsOneWidget);
    expect(find.text(russian.describeButton), findsNothing);
    expect(find.text(AppLanguage.russian.label), findsOneWidget);
  });
}
