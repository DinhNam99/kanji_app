import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/app.dart';
import 'package:kanji_app/controllers/app_controller.dart';
import 'package:kanji_app/data/content/content_repository.dart';
import 'package:kanji_app/data/progress/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds and fully loads an app controller using the real bundled assets.
///
/// Real async (asset bundle + SharedPreferences) must run inside
/// `tester.runAsync` when called from a `testWidgets` body.
Future<AppController> createLoadedController() async {
  final controller = AppController(
    contentRepository: ContentRepository(),
    progressStore: SharedPreferencesProgressStore(),
  );
  await controller.load();
  return controller;
}

/// Pumps a fully loaded [KanjiApp] and settles it.
Future<AppController> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final controller = (await tester.runAsync(createLoadedController))!;
  await tester.pumpWidget(KanjiApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}