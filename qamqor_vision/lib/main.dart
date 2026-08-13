import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/vision_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QamqorVisionApp());
}

class QamqorVisionApp extends StatelessWidget {
  const QamqorVisionApp({super.key, this.recognizer});

  /// Подменяется в тестах, чтобы обойтись без камеры.
  final SceneRecognizer? recognizer;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qamqor Vision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: HomeScreen(recognizer: recognizer),
    );
  }
}
