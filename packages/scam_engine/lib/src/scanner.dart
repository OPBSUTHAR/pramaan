import 'context/scan_context.dart';
import 'matching/template_matcher.dart';
import 'models/scan_report.dart';
import 'models/scam_signal.dart';
import 'models/upi_intent.dart';
import 'rules/rule_catalog.dart';
import 'rules/scam_rule.dart';
import 'scoring/risk_scorer.dart';
import 'upi/upi_link_parser.dart';

/// The single entry point the app talks to.
///
/// Everything here runs in-process, on-device, with no network calls, no
/// model downloads and no permissions. A scan of a typical forwarded SMS takes
/// well under 10 ms, which is fast enough to run on every paste.
///
/// ```dart
/// final ScamScanner scanner = ScamScanner();
/// final ScanReport report = scanner.scan(message);
/// if (report.level.index >= RiskLevel.dangerous.index) { ... }
/// ```
class ScamScanner {
  ScamScanner({List<ScamRule>? rules, TemplateMatcher? matcher})
      : _rules = List<ScamRule>.unmodifiable(rules ?? buildDefaultRules()),
        _matcher = matcher ?? TemplateMatcher.builtIn();

  final List<ScamRule> _rules;
  final TemplateMatcher _matcher;

  /// The rule set in play. Exposed so the UI can explain *why* something fired.
  List<ScamRule> get rules => _rules;

  /// Number of distinct fraud templates in the bundled "Scam DNA" corpus.
  int get templateCount => _matcher.templateCount;

  /// Scans free text: an SMS, a WhatsApp forward, an email body, a screenshot's
  /// OCR text, a job offer, anything.
  ScanReport scan(String input) {
    final Stopwatch stopwatch = Stopwatch()..start();
    final ScanContext context = ScanContext(input);

    if (context.isEmpty) {
      stopwatch.stop();
      return RiskScorer.score(
        context: context,
        signals: const <ScamSignal>[],
        durationMicros: stopwatch.elapsedMicroseconds,
      );
    }

    final List<ScamSignal> signals = <ScamSignal>[];
    for (final ScamRule rule in _rules) {
      final ScamSignal? signal = rule.evaluate(context);
      if (signal != null) signals.add(signal);
    }

    // A template match is scored on the canonical text so that Hindi and
    // English spellings of the same scam land on the same fingerprint.
    final TemplateMatch? match = _matcher.match(context.text);

    stopwatch.stop();

    return RiskScorer.score(
      context: context,
      signals: signals,
      templateMatch: match,
      upiFindings: context.upiAddresses,
      durationMicros: stopwatch.elapsedMicroseconds,
    );
  }

  /// Parses and audits a UPI payment string without paying anything.
  ///
  /// Accepts a full `upi://pay?...` deep link, a bare VPA like `name@okhdfcbank`,
  /// or the raw text of a QR code. Nothing is executed; this is pure inspection.
  UpiIntent inspectUpi(String input) => UpiLinkParser.parse(input);
}
