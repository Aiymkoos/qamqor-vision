import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/scene_narrator.dart';
import '../services/speech_service.dart';
import '../services/vision_service.dart';
import '../theme/app_theme.dart';
import '../widgets/big_action_button.dart';

/// Главный экран: описание обстановки, чтение текста, остановка речи
/// и переключение языка.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.recognizer});

  /// Подменяется в тестах, чтобы обойтись без камеры.
  final SceneRecognizer? recognizer;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speech = SpeechService();

  // Камера открывается лениво: держать её включённой, пока пользователь
  // ничего не снимает, значит зря сажать батарею.
  SceneRecognizer? _recognizerInstance;
  SceneRecognizer get _recognizer =>
      _recognizerInstance ??= widget.recognizer ?? CameraSceneRecognizer();

  AppLanguage _language = AppLanguage.russian;
  String _lastSpoken = '';
  bool _isRecognizing = false;

  AppStrings get _strings => AppStrings.of(_language);

  @override
  void initState() {
    super.initState();
    _speech.addListener(_onSpeechChanged);
    _startUp();
  }

  Future<void> _startUp() async {
    await _speech.init();
    if (!mounted) return;
    await _say(_strings.greeting);
  }

  void _onSpeechChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _say(String text) async {
    setState(() => _lastSpoken = text);
    await _speech.speak(text);
  }

  Future<void> _describeScene() async {
    // Повторное нажатие во время съёмки сбросило бы кадр на полпути.
    if (_isRecognizing) return;
    setState(() => _isRecognizing = true);

    // Пользователь не видит индикатор загрузки, поэтому о начале работы
    // сообщаем голосом.
    await _say(_strings.analyzing);

    try {
      final labels = await _recognizer.describeScene();
      if (!mounted) return;
      await _say(SceneNarrator.describe(labels, _language));
    } on SceneRecognitionException catch (e) {
      if (!mounted) return;
      await _say(SceneNarrator.errorFor(e.kind, _language));
    } finally {
      if (mounted) setState(() => _isRecognizing = false);
    }
  }

  Future<void> _stop() async {
    await _speech.stop();
    if (mounted) setState(() => _lastSpoken = _strings.stopped);
  }

  Future<void> _switchLanguage() async {
    final next = _language.toggled;
    setState(() => _language = next);
    await _speech.setLanguage(next);
    if (!mounted) return;

    final strings = AppStrings.of(next);
    await _say(
      _speech.usingFallbackVoice
          ? '${strings.languageSwitched} ${strings.voiceUnavailable}'
          : strings.languageSwitched,
    );
  }

  @override
  void dispose() {
    _speech.removeListener(_onSpeechChanged);
    _speech.dispose();
    _recognizerInstance?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          // Подпись языком, на который переключаемся, а не текущим:
          // кнопка отвечает на вопрос «что будет, если нажать».
          Semantics(
            button: true,
            label: '${strings.languageButton}: ${_language.toggled.label}',
            excludeSemantics: true,
            child: TextButton(
              onPressed: _switchLanguage,
              child: Text(
                _language.toggled.label,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SpokenTextPanel(
                  label: strings.lastSpokenLabel,
                  text: _lastSpoken,
                ),
              ),
              const SizedBox(height: 20),
              BigActionButton(
                label: strings.describeButton,
                icon: Icons.visibility,
                onPressed: _describeScene,
              ),
              const SizedBox(height: 16),
              BigActionButton(
                label: strings.readTextButton,
                icon: Icons.text_fields,
                filled: false,
                semanticHint: strings.ocrNotReady,
                onPressed: () => _say(strings.readTextStub),
              ),
              const SizedBox(height: 16),
              // Кнопка остановки нужна всегда: если её прятать во время
              // молчания, пользователь не найдёт её на ощупь по памяти.
              BigActionButton(
                label: strings.stopButton,
                icon: Icons.stop_circle,
                filled: false,
                onPressed: _speech.isSpeaking ? _stop : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpokenTextPanel extends StatelessWidget {
  const _SpokenTextPanel({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Дублирование речи на экране — для слабовидящих пользователей
            // с остатком зрения и для зрячих помощников рядом.
            Text(text, style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
      ),
    );
  }
}
