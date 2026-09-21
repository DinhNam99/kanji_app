import 'package:flutter_test/flutter_test.dart';

import 'package:kanji_app/app.dart';

/// Guards GitHub issue #4: the app-wide theme must use the bundled
/// Noto Sans JP font so kanji/kana render identically on Android and iOS
/// instead of relying on OS fallback fonts.
void main() {
  group('buildTheme', () {
    test('uses the bundled Noto Sans JP font as the app-wide default', () {
      final theme = buildTheme();

      // ThemeData(fontFamily:) applies the family to every text style.
      expect(theme.textTheme.bodyMedium?.fontFamily, 'NotoSansJP');
      expect(theme.textTheme.titleMedium?.fontFamily, 'NotoSansJP');
      expect(theme.appBarTheme.titleTextStyle?.fontFamily, 'NotoSansJP');
    });
  });
}