// Тесты главного экрана.
//
// Синтез речи живёт на стороне платформы, поэтому канал `flutter_tts`
// подменяется заглушкой: проверяется поведение интерфейса, а не движок.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qamqor_vision/l10n/app_strings.dart';
import 'package:qamqor_vision/main.dart';

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

  testWidgets('стартует на русском и показывает оба действия', (tester) async {
    await tester.pumpWidget(const QamqorVisionApp());
    await tester.pumpAndSettle();

    expect(find.text(russian.describeButton), findsOneWidget);
    expect(find.text(russian.readTextButton), findsOneWidget);
    expect(find.text(russian.stopButton), findsOneWidget);
  });

  testWidgets('честно предупреждает, что распознавания пока нет',
      (tester) async {
    await tester.pumpWidget(const QamqorVisionApp());
    await tester.pumpAndSettle();

    expect(find.text(russian.demoBanner), findsOneWidget);
  });

  testWidgets('кнопка описания выводит текст на экран', (tester) async {
    await tester.pumpWidget(const QamqorVisionApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(russian.describeButton));
    await tester.pumpAndSettle();

    expect(find.text(russian.describeStub), findsOneWidget);
  });

  testWidgets('кнопки подписаны для скринридера', (tester) async {
    // Без этого дерево семантики в тестах не строится.
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(const QamqorVisionApp());
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(const QamqorVisionApp());
    await tester.pumpAndSettle();

    // Кнопка подписана языком, на который переключаемся.
    await tester.tap(find.text(AppLanguage.kazakh.label));
    await tester.pumpAndSettle();

    expect(find.text(kazakh.describeButton), findsOneWidget);
    expect(find.text(russian.describeButton), findsNothing);
    expect(find.text(AppLanguage.russian.label), findsOneWidget);
  });
}
