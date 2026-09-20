import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/app_controller.dart';
import 'data/content/content_repository.dart';
import 'data/progress/progress_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController(
    contentRepository: ContentRepository(),
    progressStore: SharedPreferencesProgressStore(),
  );
  await controller.load();
  runApp(KanjiApp(controller: controller));
}