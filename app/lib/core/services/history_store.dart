import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:scam_engine/scam_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A check the user chose to keep. Deliberately small: no raw signal dump, no
/// sender identity, no phone numbers beyond what the user pasted.
@immutable
class SavedScan {
  const SavedScan({
    required this.id,
    required this.input,
    required this.score,
    required this.signalCount,
    required this.at,
    this.topTitleEn,
    this.topTitleHi,
    this.templateTitleEn,
    this.templateTitleHi,
  });

  final String id;
  final String input;
  final int score;
  final int signalCount;
  final DateTime at;
  final String? topTitleEn;
  final String? topTitleHi;
  final String? templateTitleEn;
  final String? templateTitleHi;

  RiskLevel get level => RiskLevel.fromScore(score);

  String get preview {
    final flat = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    return flat.length <= 120 ? flat : '${flat.substring(0, 117)}…';
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'input': input,
        'score': score,
        'signals': signalCount,
        'at': at.toIso8601String(),
        'topEn': topTitleEn,
        'topHi': topTitleHi,
        'tplEn': templateTitleEn,
        'tplHi': templateTitleHi,
      };

  static SavedScan? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final input = json['input'];
    final at = json['at'];
    if (id is! String || input is! String || at is! String) return null;
    final parsedAt = DateTime.tryParse(at);
    if (parsedAt == null) return null;
    return SavedScan(
      id: id,
      input: input,
      score: (json['score'] as num?)?.toInt() ?? 0,
      signalCount: (json['signals'] as num?)?.toInt() ?? 0,
      at: parsedAt,
      topTitleEn: json['topEn'] as String?,
      topTitleHi: json['topHi'] as String?,
      templateTitleEn: json['tplEn'] as String?,
      templateTitleHi: json['tplHi'] as String?,
    );
  }

  static SavedScan fromReport(ScanReport report, {DateTime? at}) {
    final top = report.topSignal;
    final tpl = report.templateMatch;
    return SavedScan(
      id: '${(at ?? DateTime.now()).microsecondsSinceEpoch}',
      input: report.input,
      score: report.score,
      signalCount: report.signals.length,
      at: at ?? DateTime.now(),
      topTitleEn: top?.titleEn,
      topTitleHi: top?.titleHi,
      templateTitleEn: tpl?.titleEn,
      templateTitleHi: tpl?.titleHi,
    );
  }
}

/// Persists the last [maxEntries] checks on the device only.
class HistoryStore extends ChangeNotifier {
  HistoryStore();

  static const int maxEntries = 60;
  static const String _prefsKey = 'pramaan.history.v1';

  final List<SavedScan> _items = <SavedScan>[];
  bool _loaded = false;

  List<SavedScan> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;
  bool get isEmpty => _items.isEmpty;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final entry in decoded) {
            if (entry is Map<String, Object?>) {
              final saved = SavedScan.fromJson(entry);
              if (saved != null) _items.add(saved);
            }
          }
        }
      }
    } on Exception {
      // A corrupt or unavailable store must never block the app.
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(SavedScan scan) async {
    _items.insert(0, scan);
    if (_items.length > maxEntries) {
      _items.removeRange(maxEntries, _items.length);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _items.map((item) => item.toJson()).toList(growable: false),
      );
      await prefs.setString(_prefsKey, encoded);
    } on Exception {
      // Keep working in memory if storage is denied.
    }
  }
}

class HistoryScope extends InheritedNotifier<HistoryStore> {
  const HistoryScope({
    required HistoryStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static HistoryStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HistoryScope>();
    assert(scope != null, 'HistoryScope is missing above this widget.');
    return scope!.notifier!;
  }

  static HistoryStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<HistoryScope>();
    assert(scope != null, 'HistoryScope is missing above this widget.');
    return scope!.notifier!;
  }
}
