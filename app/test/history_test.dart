import 'package:flutter_test/flutter_test.dart';
import 'package:pramaan/core/services/history_store.dart';
import 'package:scam_engine/scam_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SavedScan', () {
    test('survives a JSON round trip', () {
      final report = ScamScanner().scan(
        'Your KYC is expiring today. Update now at http://sbi-verify.online '
        'or your account will be blocked.',
      );
      final saved = SavedScan.fromReport(report, at: DateTime(2026, 10, 30, 9));

      final restored = SavedScan.fromJson(saved.toJson());

      expect(restored, isNotNull);
      expect(restored!.id, saved.id);
      expect(restored.input, report.input);
      expect(restored.score, report.score);
      expect(restored.signalCount, report.signals.length);
      expect(restored.at, saved.at);
      expect(restored.level, report.level);
    });

    test('rejects malformed entries instead of throwing', () {
      expect(SavedScan.fromJson(const {}), isNull);
      expect(
        SavedScan.fromJson(const {'id': 'x', 'input': 'y', 'at': 'not-a-date'}),
        isNull,
      );
    });

    test('preview is flattened and bounded', () {
      final saved = SavedScan(
        id: '1',
        input: 'line one\n\nline   two ${'x' * 200}',
        score: 10,
        signalCount: 0,
        at: DateTime(2026),
      );
      expect(saved.preview, isNot(contains('\n')));
      expect(saved.preview.length, lessThanOrEqualTo(120));
    });
  });

  group('HistoryStore', () {
    test('keeps the newest entries first and caps the list', () async {
      final store = HistoryStore();
      for (var i = 0; i < HistoryStore.maxEntries + 5; i++) {
        await store.add(
          SavedScan(
            id: '$i',
            input: 'message $i',
            score: i % 100,
            signalCount: 1,
            at: DateTime(2026, 1, 1).add(Duration(minutes: i)),
          ),
        );
      }

      expect(store.items.length, HistoryStore.maxEntries);
      expect(store.items.first.id, '${HistoryStore.maxEntries + 4}');
    });

    test('clear removes everything', () async {
      final store = HistoryStore();
      await store.add(
        SavedScan(
          id: 'a',
          input: 'hello',
          score: 5,
          signalCount: 0,
          at: DateTime(2026),
        ),
      );
      await store.clear();
      expect(store.isEmpty, isTrue);
    });
  });
}
