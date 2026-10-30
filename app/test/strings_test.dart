import 'package:flutter_test/flutter_test.dart';
import 'package:pramaan/core/l10n/app_strings.dart';

void main() {
  test('every English key has a Hindi translation', () {
    final missing = AppStrings.en.keys
        .where((key) => !AppStrings.hi.containsKey(key))
        .toList();
    expect(missing, isEmpty, reason: 'Missing Hindi keys: $missing');
  });

  test('Hindi does not define keys English lacks', () {
    final extra = AppStrings.hi.keys
        .where((key) => !AppStrings.en.containsKey(key))
        .toList();
    expect(extra, isEmpty, reason: 'Unknown Hindi keys: $extra');
  });

  test('no translation is empty', () {
    for (final entry in AppStrings.en.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: 'Empty en: ${entry.key}');
      expect(
        AppStrings.hi[entry.key]!.trim(),
        isNotEmpty,
        reason: 'Empty hi: ${entry.key}',
      );
    }
  });

  test('lookup falls back to English and then the key', () {
    expect(AppStrings.lookup('nav.scan', hindi: false), 'Scan');
    expect(AppStrings.lookup('nav.scan', hindi: true), 'जाँच');
    expect(AppStrings.lookup('missing.key', hindi: true), 'missing.key');
  });
}
