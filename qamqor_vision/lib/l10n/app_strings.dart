/// Поддерживаемые языки интерфейса и голосового движка.
enum AppLanguage {
  kazakh('kk-KZ', 'Қазақша'),
  russian('ru-RU', 'Русский');

  const AppLanguage(this.localeTag, this.label);

  /// BCP 47 тег, который передаётся в движок синтеза речи.
  final String localeTag;

  /// Название языка на нём самом — для кнопки переключения.
  final String label;

  AppLanguage get toggled =>
      this == AppLanguage.kazakh ? AppLanguage.russian : AppLanguage.kazakh;
}

/// Строки интерфейса. Отдельного пакета локализации пока нет:
/// на двух языках и одном экране простая таблица читается яснее.
class AppStrings {
  const AppStrings._(this._values);

  final Map<_Key, String> _values;

  static const AppStrings _kazakh = AppStrings._({
    _Key.appTitle: 'Qamqor Vision',
    _Key.demoBanner: 'Демо-режим: тану әлі іске қосылған жоқ',
    _Key.describeButton: 'Айналаны сипаттау',
    _Key.readTextButton: 'Мәтінді оқу',
    _Key.stopButton: 'Тоқтату',
    _Key.languageButton: 'Тілді ауыстыру',
    _Key.greeting: 'Сәлеметсіз бе. Qamqor Vision қосылды.',
    _Key.describeStub:
        'Бұл — дыбыстық шығудың демонстрациясы. Нақты нұсқада мұнда '
        'камера көрген заттардың сипаттамасы айтылады.',
    _Key.readTextStub:
        'Бұл — дыбыстық шығудың демонстрациясы. Нақты нұсқада мұнда '
        'камераға түскен мәтін оқылады.',
    _Key.stopped: 'Тоқтатылды.',
    _Key.languageSwitched: 'Тіл қазақ тіліне ауыстырылды.',
    _Key.voiceUnavailable:
        'Құрылғыда қазақ тілінің дауысы жоқ. Орыс тіліндегі дауыс қолданылады.',
    _Key.lastSpokenLabel: 'Соңғы айтылған:',
  });

  static const AppStrings _russian = AppStrings._({
    _Key.appTitle: 'Qamqor Vision',
    _Key.demoBanner: 'Демо-режим: распознавание пока не реализовано',
    _Key.describeButton: 'Описать обстановку',
    _Key.readTextButton: 'Прочитать текст',
    _Key.stopButton: 'Остановить',
    _Key.languageButton: 'Сменить язык',
    _Key.greeting: 'Здравствуйте. Qamqor Vision запущен.',
    _Key.describeStub:
        'Это демонстрация голосового вывода. В рабочей версии здесь будет '
        'описание предметов, которые видит камера.',
    _Key.readTextStub:
        'Это демонстрация голосового вывода. В рабочей версии здесь будет '
        'прочитан текст, попавший в кадр.',
    _Key.stopped: 'Остановлено.',
    _Key.languageSwitched: 'Язык переключён на русский.',
    _Key.voiceUnavailable:
        'На устройстве нет казахского голоса. Используется русский.',
    _Key.lastSpokenLabel: 'Последнее озвученное:',
  });

  static AppStrings of(AppLanguage language) =>
      language == AppLanguage.kazakh ? _kazakh : _russian;

  String get appTitle => _values[_Key.appTitle]!;
  String get demoBanner => _values[_Key.demoBanner]!;
  String get describeButton => _values[_Key.describeButton]!;
  String get readTextButton => _values[_Key.readTextButton]!;
  String get stopButton => _values[_Key.stopButton]!;
  String get languageButton => _values[_Key.languageButton]!;
  String get greeting => _values[_Key.greeting]!;
  String get describeStub => _values[_Key.describeStub]!;
  String get readTextStub => _values[_Key.readTextStub]!;
  String get stopped => _values[_Key.stopped]!;
  String get languageSwitched => _values[_Key.languageSwitched]!;
  String get voiceUnavailable => _values[_Key.voiceUnavailable]!;
  String get lastSpokenLabel => _values[_Key.lastSpokenLabel]!;
}

enum _Key {
  appTitle,
  demoBanner,
  describeButton,
  readTextButton,
  stopButton,
  languageButton,
  greeting,
  describeStub,
  readTextStub,
  stopped,
  languageSwitched,
  voiceUnavailable,
  lastSpokenLabel,
}
