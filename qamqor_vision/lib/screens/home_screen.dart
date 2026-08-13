import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/big_action_button.dart';

/// Главный экран: два действия, остановка речи и переключение языка.
///
/// Распознавание пока не подключено — кнопки озвучивают демонстрационный
/// текст, который прямо говорит об этом. Показывать выдуманный результат
/// распознавания нельзя: пользователь не может проверить его глазами.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speech = SpeechService();

  AppLanguage _language = AppLanguage.russian;
  String _lastSpoken = '';

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
              _DemoBanner(text: strings.demoBanner),
              const SizedBox(height: 20),
              Expanded(child: _SpokenTextPanel(
                label: strings.lastSpokenLabel,
                text: _lastSpoken,
              )),
              const SizedBox(height: 20),
              BigActionButton(
                label: strings.describeButton,
                icon: Icons.visibility,
                semanticHint: strings.demoBanner,
                onPressed: () => _say(strings.describeStub),
              ),
              const SizedBox(height: 16),
              BigActionButton(
                label: strings.readTextButton,
                icon: Icons.text_fields,
                filled: false,
                semanticHint: strings.demoBanner,
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

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
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
