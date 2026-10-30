import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pramaan/core/l10n/l10n.dart';
import 'package:pramaan/core/services/history_store.dart';
import 'package:pramaan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final locale = LocaleController();
  final history = HistoryStore();
  await history.load();

  await tester.pumpWidget(PramaanApp(locale: locale, history: history));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('opens on the scan screen', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Check before you pay'), findsOneWidget);
    expect(find.text('Pramaan'), findsOneWidget);
    expect(find.text('100% on-device'), findsOneWidget);
  });

  testWidgets('flags a KYC-block scam and opens the verdict', (tester) async {
    await _pumpApp(tester);

    await tester.enterText(
      find.byType(TextField).first,
      'Dear Customer, your account will be BLOCKED today because KYC is not '
      'updated. Update immediately within 24 hours: '
      'http://sbi-kyc-verify.online/update',
    );
    await tester.pump();

    final button = find.text('Check this message');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Verdict'), findsOneWidget);
    expect(find.text('Why this was flagged'), findsOneWidget);
  });

  testWidgets('switches the whole app to Hindi', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('भेजने से पहले जाँचें'), findsOneWidget);
    expect(find.text('जाँच'), findsOneWidget);
  });
}
