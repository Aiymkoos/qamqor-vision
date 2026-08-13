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
    _Key.ocrNotReady: 'Мәтінді оқу әлі іске қосылған жоқ',
    _Key.describeButton: 'Айналаны сипаттау',
    _Key.readTextButton: 'Мәтінді оқу',
    _Key.stopButton: 'Тоқтату',
    _Key.languageButton: 'Тілді ауыстыру',
    _Key.greeting: 'Сәлеметсіз бе. Qamqor Vision қосылды.',
    _Key.analyzing: 'Қарап тұрмын',
    _Key.seeIntro: 'Көріп тұрмын:',
    _Key.nothingRecognized:
        'Не бар екенін ажырата алмадым. Жақынырақ келіңіз немесе '
        'жарықты қосыңыз.',
    _Key.cameraDenied:
        'Камераға рұқсат жоқ. Қолданба параметрлерінен рұқсат беріңіз.',
    _Key.cameraMissing: 'Құрылғыда камера табылмады.',
    _Key.recognitionFailed: 'Тану сәтсіз аяқталды. Қайталап көріңіз.',
    _Key.readTextStub:
        'Мәтінді оқу әлі іске қосылған жоқ. Бұл — дыбыстық шығудың '
        'демонстрациясы.',
    _Key.stopped: 'Тоқтатылды.',
    _Key.languageSwitched: 'Тіл қазақ тіліне ауыстырылды.',
    _Key.voiceUnavailable:
        'Құрылғыда қазақ тілінің дауысы жоқ. Орыс тіліндегі дауыс қолданылады.',
    _Key.lastSpokenLabel: 'Соңғы айтылған:',
  });

  static const AppStrings _russian = AppStrings._({
    _Key.appTitle: 'Qamqor Vision',
    _Key.ocrNotReady: 'Чтение текста пока не реализовано',
    _Key.describeButton: 'Описать обстановку',
    _Key.readTextButton: 'Прочитать текст',
    _Key.stopButton: 'Остановить',
    _Key.languageButton: 'Сменить язык',
    _Key.greeting: 'Здравствуйте. Qamqor Vision запущен.',
    _Key.analyzing: 'Смотрю',
    _Key.seeIntro: 'Вижу:',
    _Key.nothingRecognized:
        'Не могу разобрать, что передо мной. Подойдите ближе или '
        'включите свет.',
    _Key.cameraDenied:
        'Нет доступа к камере. Разрешите его в настройках приложения.',
    _Key.cameraMissing: 'Камера на устройстве не найдена.',
    _Key.recognitionFailed: 'Не удалось распознать. Попробуйте ещё раз.',
    _Key.readTextStub:
        'Чтение текста пока не реализовано. Это демонстрация голосового '
        'вывода.',
    _Key.stopped: 'Остановлено.',
    _Key.languageSwitched: 'Язык переключён на русский.',
    _Key.voiceUnavailable:
        'На устройстве нет казахского голоса. Используется русский.',
    _Key.lastSpokenLabel: 'Последнее озвученное:',
  });

  static AppStrings of(AppLanguage language) =>
      language == AppLanguage.kazakh ? _kazakh : _russian;

  String get appTitle => _values[_Key.appTitle]!;
  String get ocrNotReady => _values[_Key.ocrNotReady]!;
  String get describeButton => _values[_Key.describeButton]!;
  String get readTextButton => _values[_Key.readTextButton]!;
  String get stopButton => _values[_Key.stopButton]!;
  String get languageButton => _values[_Key.languageButton]!;
  String get greeting => _values[_Key.greeting]!;
  String get analyzing => _values[_Key.analyzing]!;
  String get seeIntro => _values[_Key.seeIntro]!;
  String get nothingRecognized => _values[_Key.nothingRecognized]!;
  String get cameraDenied => _values[_Key.cameraDenied]!;
  String get cameraMissing => _values[_Key.cameraMissing]!;
  String get recognitionFailed => _values[_Key.recognitionFailed]!;
  String get readTextStub => _values[_Key.readTextStub]!;
  String get stopped => _values[_Key.stopped]!;
  String get languageSwitched => _values[_Key.languageSwitched]!;
  String get voiceUnavailable => _values[_Key.voiceUnavailable]!;
  String get lastSpokenLabel => _values[_Key.lastSpokenLabel]!;
}

enum _Key {
  appTitle,
  ocrNotReady,
  describeButton,
  readTextButton,
  stopButton,
  languageButton,
  greeting,
  analyzing,
  seeIntro,
  nothingRecognized,
  cameraDenied,
  cameraMissing,
  recognitionFailed,
  readTextStub,
  stopped,
  languageSwitched,
  voiceUnavailable,
  lastSpokenLabel,
}
