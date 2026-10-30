import '../context/scan_context.dart';
import '../models/risk_level.dart';
import '../models/scan_report.dart';
import '../models/scam_signal.dart';
import '../models/severity.dart';

/// Turns a bag of signals into a single 0-100 risk score.
///
/// The maths is a noisy-OR rather than a sum. Summing would let three weak
/// signals outrank one decisive one ("asks for OTP"); noisy-OR means each extra
/// signal adds less, and the total can never exceed 100. That mirrors how
/// investigators actually reason: one hard fact beats five soft hints, but five
/// soft hints together still matter.
abstract final class RiskScorer {
  /// No single category may contribute more than this many signals, so a
  /// message stuffed with twenty urgency words cannot drown out everything else.
  static const int maxSignalsPerCategory = 3;

  /// Minimum score once a `critical` signal has fired.
  static const int criticalFloor = 70;

  /// Blends template similarity into the score. A perfect template match adds
  /// roughly as much as a strong rule.
  static const double templateWeight = 0.75;

  static ScanReport score({
    required ScanContext context,
    required List<ScamSignal> signals,
    TemplateMatch? templateMatch,
    List<String> upiFindings = const <String>[],
    int durationMicros = 0,
  }) {
    final List<ScamSignal> positives = <ScamSignal>[];
    final List<ScamSignal> negatives = <ScamSignal>[];
    for (final ScamSignal s in signals) {
      if (s.effectiveWeight >= 0) {
        positives.add(s);
      } else {
        negatives.add(s);
      }
    }

    positives.sort(
      (ScamSignal a, ScamSignal b) =>
          b.effectiveWeight.compareTo(a.effectiveWeight),
    );

    // Cap per category, keeping the strongest.
    final Map<RiskCategory, int> seen = <RiskCategory, int>{};
    final List<ScamSignal> kept = <ScamSignal>[];
    for (final ScamSignal s in positives) {
      final int count = seen[s.category] ?? 0;
      if (count >= maxSignalsPerCategory) continue;
      seen[s.category] = count + 1;
      kept.add(s);
    }

    double remaining = 1.0;
    for (final ScamSignal s in kept) {
      remaining *= 1 - s.effectiveWeight;
    }

    if (templateMatch != null) {
      final double w =
          (templateMatch.similarity * templateWeight).clamp(0.0, 0.95).toDouble();
      remaining *= 1 - w;
    }

    double score = (1 - remaining) * 100;

    // Whitelist signals: an exact official domain genuinely lowers risk.
    double relief = 0;
    for (final ScamSignal s in negatives) {
      relief += -s.effectiveWeight;
    }
    if (relief > 0) {
      final double capped = relief > 0.6 ? 0.6 : relief;
      score = score * (1 - capped);
    }

    // Hard floor: anything asking for a secret is dangerous, full stop.
    final bool hasCritical = kept.any(
      (ScamSignal s) => s.severity == Severity.critical,
    );
    if (hasCritical && score < criticalFloor) {
      score = criticalFloor.toDouble();
    }

    final int finalScore = score.round().clamp(0, 100).toInt();

    final List<ScamSignal> ordered = <ScamSignal>[
      ...kept,
      ...negatives,
    ];

    return ScanReport(
      input: context.raw,
      signals: ordered,
      score: finalScore,
      level: RiskLevel.fromScore(finalScore),
      templateMatch: templateMatch,
      upiFindings: upiFindings,
      durationMicros: durationMicros,
    );
  }
}
