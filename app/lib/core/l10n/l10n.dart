import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_strings.dart';

/// Holds the chosen language and survives app restarts.
class LocaleController extends ChangeNotifier {
  LocaleController({bool startInHindi = false})
    : _hindi = startInHindi,
      _locale = Locale(startInHindi ? 'hi' : 'en');

  static const String _prefsKey = 'pramaan.language';

  bool _hindi;
  Locale _locale;

  bool get isHindi => _hindi;
  Locale get locale => _locale;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == null) return;
      setLanguage(saved == 'hi');
    } on Exception {
      // Storage is a convenience, never a requirement.
    }
  }

  void toggle() => setLanguage(!_hindi);

  void setLanguage(bool hindi) {
    if (_hindi == hindi) return;
    _hindi = hindi;
    _locale = Locale(hindi ? 'hi' : 'en');
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _hindi ? 'hi' : 'en');
    } on Exception {
      // Ignore: the choice still applies for this session.
    }
  }
}

/// Makes the controller reachable without a third-party state package.
class AppScope extends InheritedNotifier<LocaleController> {
  const AppScope({
    required LocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget.');
    return scope!.notifier!;
  }

  static LocaleController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing above this widget.');
    return scope!.notifier!;
  }
}

extension PramaanL10n on BuildContext {
  bool get isHindi => AppScope.of(this).isHindi;

  String t(String key) => AppStrings.lookup(key, hindi: isHindi);

  /// Picks the Hindi variant when the app is in Hindi and one exists.
  String pick(String english, String hindi) => isHindi ? hindi : english;
}
