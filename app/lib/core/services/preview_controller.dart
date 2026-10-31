import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How the app is presented inside a desktop browser.
enum PreviewMode {
  /// 412 x 892 logical pixels - a modern Android phone.
  phone,

  /// 834 x 1112 logical pixels - a small Android tablet.
  tablet,

  /// No frame at all; the app fills the window.
  full,
}

/// Holds the chosen preview mode so the frame around the app and the settings
/// sheet always agree.
class PreviewController extends ChangeNotifier {
  static const String storageKey = 'pramaan.preview.mode';

  PreviewMode _mode = PreviewMode.phone;

  PreviewMode get mode => _mode;

  bool get isFramed => _mode != PreviewMode.full;

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final stored = prefs.getString(storageKey);
      if (stored == null) return;
      for (final mode in PreviewMode.values) {
        if (mode.name == stored) {
          _mode = mode;
          notifyListeners();
          return;
        }
      }
    } catch (_) {
      // A missing or unreadable store just means the default is used.
    }
  }

  Future<void> setMode(PreviewMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, mode.name);
    } catch (_) {
      // Persisting is best effort; the choice still applies for this session.
    }
  }
}

/// Makes the [PreviewController] reachable from both the frame above the
/// [Navigator] and the settings sheet inside it.
class PreviewScope extends InheritedNotifier<PreviewController> {
  const PreviewScope({
    required PreviewController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static PreviewController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PreviewScope>()?.notifier;
  }

  static PreviewController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No PreviewScope found in the widget tree');
    return controller!;
  }
}
