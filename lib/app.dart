import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'controllers/app_controller.dart';
import 'ui/screens/error_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/learning_screen.dart';
import 'ui/screens/progress_screen.dart';
import 'ui/screens/review_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/topic_detail_screen.dart';

const appTitle = 'Kanji Beginner';

/// Root of the app. Switches the home screen by [AppController.status] and
/// wires up the flat named-route table.
class KanjiApp extends StatelessWidget {
  const KanjiApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      app: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: appTitle,
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            home: switch (controller.status) {
              AppStatus.loading => const SplashScreen(),
              AppStatus.error => ErrorScreen(
                  message: controller.errorMessage,
                  onRetry: controller.load,
                ),
              AppStatus.ready => const HomeScreen(),
            },
            routes: {
              '/topic': (_) => const TopicDetailScreen(),
              '/learning': (_) => const LearningScreen(),
              '/review': (_) => const ReviewScreen(),
              '/progress': (_) => const ProgressScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB));
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surfaceContainerLowest,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: scheme.surface,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}