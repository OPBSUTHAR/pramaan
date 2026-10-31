import 'package:scam_engine/scam_engine.dart';
import 'package:test/test.dart';

void main() {
  final ScamScanner scanner = ScamScanner();

  group('Scam DNA corpus', () {
    test('ships a meaningful number of templates', () {
      expect(scanner.templateCount, greaterThanOrEqualTo(25));
    });

    // Self-consistency: every bundled script must be recognised as dangerous.
    // If a template ever stops matching itself, the corpus or the matcher broke.
    for (final ScamTemplate template in builtInTemplates) {
      test('recognises ${template.id}', () {
        final ScanReport report = scanner.scan(template.body);
        expect(
          report.score,
          greaterThanOrEqualTo(60),
          reason: '${template.id} scored only ${report.score}',
        );
        expect(
          report.level.index,
          greaterThanOrEqualTo(RiskLevel.dangerous.index),
        );
      });
    }
  });

  group('real-world scam messages', () {
    test('KYC block SMS with a fake bank domain', () {
      final ScanReport report = scanner.scan(
        'Dear SBI customer, your account will be BLOCKED today because KYC is '
        'pending. Update immediately at http://sbi-kyc-verify.online/update or '
        'call 9876543210.',
      );
      expect(report.score, greaterThanOrEqualTo(60));
      expect(
        report.signals.map((ScamSignal s) => s.ruleId),
        anyElement(anyOf('kyc_expiry', 'lookalike_domain', 'suspicious_link')),
      );
    });

    test('collect-request refund trap', () {
      final ScanReport report = scanner.scan(
        'You have received Rs 5,000 from Rahul. To accept the payment, approve '
        'the collect request in your UPI app and enter your UPI PIN.',
      );
      expect(report.score, greaterThanOrEqualTo(70));
      expect(
        report.signals.map((ScamSignal s) => s.ruleId),
        contains('upi_pin_request'),
      );
    });

    test('digital arrest call script', () {
      final ScanReport report = scanner.scan(
        'This is CBI officer Sharma. A parcel with drugs was found in your '
        'name. You are under digital arrest. Do not tell anyone about this '
        'call. Join the video call now or a warrant will be issued.',
      );
      expect(report.score, greaterThanOrEqualTo(60));
      expect(
        report.signals.map((ScamSignal s) => s.ruleId),
        contains('digital_arrest'),
      );
    });

    test('Hindi KYC message is understood without translation', () {
      final ScanReport report = scanner.scan(
        'प्रिय ग्राहक, आपका खाता आज बंद हो जाएगा। केवाईसी तुरंत अपडेट करें। '
        'अभी क्लिक करें।',
      );
      expect(report.score, greaterThanOrEqualTo(35));
      expect(
          report.level.index, greaterThanOrEqualTo(RiskLevel.suspicious.index));
    });

    test('remote-access support scam', () {
      final ScanReport report = scanner.scan(
        'Sir your parcel is stuck. Please install AnyDesk and share the 9 digit '
        'code so our executive can complete the refund process.',
      );
      expect(report.score, greaterThanOrEqualTo(60));
      expect(
        report.signals.map((ScamSignal s) => s.ruleId),
        contains('remote_access_app'),
      );
    });
  });

  group('false positives', () {
    const Map<String, String> benign = <String, String>{
      'family chat':
          'Hi mom, I will be late tonight. Please keep dinner aside.',
      'team chat': 'Team lunch is at 1pm in the cafeteria. See you there.',
      'delivery notice': 'Your Amazon order has been delivered. Thanks for '
          'shopping with us.',
      'birthday': 'Happy birthday! Let us catch up soon.',
      'salary slip': 'Your salary for September has been credited to your '
          'account ending 4432.',
    };

    benign.forEach((String name, String message) {
      test('does not alarm on $name', () {
        final ScanReport report = scanner.scan(message);
        expect(report.score, lessThan(35),
            reason: '$name scored ${report.score}');
      });
    });

    test('a genuine OTP advisory is not treated as an OTP request', () {
      final ScanReport report = scanner.scan(
        'Your OTP for login is 482913. Never share it with anyone, not even '
        'bank staff. - HDFC Bank',
      );
      expect(
        report.signals.map((ScamSignal s) => s.ruleId),
        isNot(contains('otp_request')),
      );
      expect(report.score, lessThan(60));
    });

    test('an official bank domain earns relief', () {
      final ScanReport report = scanner.scan(
        'Login to https://www.onlinesbi.sbi to view your statement.',
      );
      expect(
        report.signals.map((ScamSignal s) => s.ruleId),
        contains('trusted_official_domain'),
      );
      expect(report.score, lessThan(35));
    });
  });

  group('engine behaviour', () {
    test('empty input is safe and cheap', () {
      final ScanReport report = scanner.scan('   ');
      expect(report.score, 0);
      expect(report.level, RiskLevel.safe);
      expect(report.signals, isEmpty);
    });

    test('scoring is deterministic', () {
      const String message =
          'Urgent: your account will be blocked. Share OTP now.';
      final int a = scanner.scan(message).score;
      final int b = scanner.scan(message).score;
      expect(a, b);
    });

    test('scores always stay inside 0..100', () {
      final ScanReport report = scanner.scan(
        'URGENT!!! IMMEDIATELY share OTP, UPI PIN, CVV and Aadhaar right now '
        'or your account will be blocked. Click http://bit.ly/x and install '
        'AnyDesk. Do not tell anyone. You have won Rs 25,00,000 lottery.',
      );
      expect(report.score, inInclusiveRange(0, 100));
      expect(report.level, RiskLevel.critical);
    });

    test('scans a typical message in well under a frame', () {
      const String message =
          'Dear customer your KYC is pending, update at http://sbi-verify.xyz';
      final Stopwatch sw = Stopwatch()..start();
      for (int i = 0; i < 50; i++) {
        scanner.scan(message);
      }
      sw.stop();
      final double perScanMs = sw.elapsedMicroseconds / 50 / 1000;
      expect(perScanMs, lessThan(50));
    });
  });
}
