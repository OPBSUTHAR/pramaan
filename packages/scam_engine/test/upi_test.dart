import 'package:scam_engine/scam_engine.dart';
import 'package:test/test.dart';

void main() {
  group('UPI deep links', () {
    test('parses a merchant pay link', () {
      final UpiIntent intent = UpiLinkParser.parse(
        'upi://pay?pa=shop@okhdfcbank&pn=Sharma%20Store&am=499.00&cu=INR&mc=5411',
      );

      expect(intent.operation, UpiOperation.pay);
      expect(intent.payeeAddress, 'shop@okhdfcbank');
      expect(intent.payeeName, 'Sharma Store');
      expect(intent.amount, 499.0);
      expect(intent.currency, 'INR');
      expect(intent.merchantCode, '5411');
      expect(intent.hasPrefilledAmount, isTrue);
      expect(intent.looksLikeRegisteredMerchant, isTrue);
      expect(intent.isAnonymousPayee, isFalse);
    });

    test('a collect request is flagged critical', () {
      final UpiIntent intent = UpiLinkParser.parse(
        'upi://collect?pa=refund@okaxis&pn=Refund%20Dept',
      );

      expect(intent.operation, UpiOperation.collect);
      expect(
        intent.warnings.map((UpiWarning w) => w.code),
        contains('collect_operation'),
      );
      expect(intent.worstSeverity, Severity.critical);
    });

    test('a mandate is flagged critical', () {
      final UpiIntent intent = UpiLinkParser.parse(
        'upi://mandate?pa=vendor@ybl&am=199&cu=INR',
      );

      expect(intent.operation, UpiOperation.mandate);
      expect(
        intent.warnings.map((UpiWarning w) => w.code),
        contains('mandate_operation'),
      );
      expect(intent.worstSeverity, Severity.critical);
    });

    test('a huge pre-filled amount is called out', () {
      final UpiIntent intent = UpiLinkParser.parse(
        'upi://pay?pa=x@okhdfcbank&am=250000&cu=INR',
      );

      expect(intent.hasPrefilledAmount, isTrue);
      expect(
        intent.warnings.map((UpiWarning w) => w.code),
        contains('large_amount'),
      );
    });

    test('an unsigned link is noted but not fatal', () {
      final UpiIntent intent = UpiLinkParser.parse(
        'upi://pay?pa=shop@okhdfcbank&am=10&cu=INR',
      );

      expect(intent.signaturePresent, isFalse);
      expect(
        intent.warnings.map((UpiWarning w) => w.code),
        contains('unsigned_link'),
      );
      expect(intent.worstSeverity.index, lessThan(Severity.critical.index));
    });

    test('a link with no payee is critical', () {
      final UpiIntent intent = UpiLinkParser.parse('upi://pay?am=500&cu=INR');

      expect(intent.payeeAddress, isNull);
      expect(
        intent.warnings.map((UpiWarning w) => w.code),
        contains('no_payee'),
      );
    });

    test('percent-encoded payloads are decoded', () {
      final UpiIntent intent = UpiLinkParser.parse(
        'upi%3A%2F%2Fpay%3Fpa%3Dshop%40okhdfcbank%26am%3D99',
      );

      expect(intent.operation, UpiOperation.pay);
      expect(intent.payeeAddress, 'shop@okhdfcbank');
      expect(intent.amount, 99.0);
    });

    test('a bare VPA is treated as a personal payment', () {
      final UpiIntent intent = UpiLinkParser.parse('omprakash@okhdfcbank');

      expect(intent.operation, UpiOperation.pay);
      expect(intent.payeeAddress, 'omprakash@okhdfcbank');
      expect(
        intent.warnings.map((UpiWarning w) => w.code),
        contains('p2p_no_chargeback'),
      );
    });

    test('garbage never throws', () {
      final UpiIntent intent = UpiLinkParser.parse('hello world, pay me');

      expect(intent.operation, UpiOperation.unknown);
      expect(
        intent.warnings.map((UpiWarning w) => w.code),
        contains('not_a_upi_link'),
      );
    });
  });

  group('VPA inspection', () {
    test('recognises a real PSP handle', () {
      final List<UpiWarning> warnings = VpaInspector.inspect('rahul@okhdfcbank');
      expect(
        warnings.map((UpiWarning w) => w.code),
        isNot(anyOf(contains('unknown_handle'), contains('typosquat_handle'))),
      );
    });

    test('catches a one-character typosquat of a bank handle', () {
      // 'okhdfbank' is missing the 'c' from the real HDFC handle.
      final List<UpiWarning> warnings = VpaInspector.inspect('rahul@okhdfbank');
      expect(
        warnings.map((UpiWarning w) => w.code),
        contains('typosquat_handle'),
      );
    });

    test('catches an invented handle', () {
      final List<UpiWarning> warnings =
          VpaInspector.inspect('rahul@fakebankxyz');
      expect(
        warnings.map((UpiWarning w) => w.code),
        contains('unknown_handle'),
      );
    });

    test('flags a bank name used as a personal username', () {
      final List<UpiWarning> warnings =
          VpaInspector.inspect('sbi.helpdesk@ybl');
      expect(
        warnings.map((UpiWarning w) => w.code),
        contains('brand_in_username'),
      );
    });

    test('rejects malformed addresses', () {
      expect(VpaInspector.isValid('not-a-vpa'), isFalse);
      expect(VpaInspector.isValid('a@b'), isFalse);
      expect(VpaInspector.isValid('rahul@okhdfcbank'), isTrue);
      expect(
        VpaInspector.inspect('not-a-vpa').map((UpiWarning w) => w.code),
        contains('malformed'),
      );
    });

    test('the PSP registry is populated', () {
      expect(PspRegistry.handles.length, greaterThan(80));
      expect(PspRegistry.isKnown('okhdfcbank'), isTrue);
      expect(PspRegistry.isKnown('definitely-not-a-psp'), isFalse);
    });
  });

  group('link heuristics', () {
    test('looksLikeUpi accepts links and bare VPAs', () {
      expect(UpiLinkParser.looksLikeUpi('upi://pay?pa=a@okhdfcbank'), isTrue);
      expect(UpiLinkParser.looksLikeUpi('rahul@okhdfcbank'), isTrue);
      expect(UpiLinkParser.looksLikeUpi('https://example.com'), isFalse);
    });

    test('known official domains are catalogued', () {
      expect(KnownDomains.official, contains('sbi.co.in'));
      expect(KnownDomains.shorteners, contains('bit.ly'));
    });
  });
}
