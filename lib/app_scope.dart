import 'package:flutter/widgets.dart';

import 'controllers/app_controller.dart';

/// Exposes the single [AppController] to the widget tree (Flutter SDK only).
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.app, required super.child});

  final AppController app;

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in the widget tree');
    return scope!.app;
  }

  /// Reads the controller without establishing a dependency (safe to call
  /// from `initState`).
  static AppController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in the widget tree');
    return scope!.app;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.app != app;
}