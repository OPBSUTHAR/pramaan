import 'risk_level.dart';
import 'scam_signal.dart';

/// The complete result of scanning one message.
class ScanReport {
  const ScanReport({
    required this.input,
    required this.signals,
    required this.score,
    required this.level,
    this.templateMatch,
    this.upiFindings = const <String>[],
    this.durationMicros = 0,
  });

  /// The raw text that was scanned.
  final String input;

  /// Every signal that fired, strongest first.
  final List<ScamSignal> signals;

  /// Aggregate risk, 0-100.
  final int score;

  final RiskLevel level;

  /// Set when the fuzzy matcher found a close known scam template.
  final TemplateMatch? templateMatch;

  /// Plain-language notes produced by the UPI inspector, if any.
  final List<String> upiFindings;

  /// How long the scan took. Shown in the UI to prove it is on-device.
  final int durationMicros;

  bool get hasSignals => signals.isNotEmpty;

  /// True when nothing at all matched.
  bool get isClean => signals.isEmpty && templateMatch == null;

  /// Signals grouped by category, preserving the strength ordering.
  Map<RiskCategory, List<ScamSignal>> get grouped {
    final Map<RiskCategory, List<ScamSignal>> out =
        <RiskCategory, List<ScamSignal>>{};
    for (final ScamSignal s in signals) {
      out.putIfAbsent(s.category, () => <ScamSignal>[]).add(s);
    }
    return out;
  }

  /// The single strongest signal, used for the headline.
  ScamSignal? get topSignal => signals.isEmpty ? null : signals.first;

  Map<String, Object?> toJson() => <String, Object?>{
        'score': score,
        'level': level.name,
        'signals': signals.map((ScamSignal s) => s.toJson()).toList(),
        'templateMatch': templateMatch?.toJson(),
        'upiFindings': upiFindings,
      };
}

/// A near-duplicate match against a bundled scam template.
class TemplateMatch {
  const TemplateMatch({
    required this.templateId,
    required this.titleEn,
    required this.titleHi,
    required this.similarity,
    required this.familyEn,
    required this.familyHi,
  });

  final String templateId;
  final String titleEn;
  final String titleHi;

  /// 0..1 similarity from the trigram + token blend.
  final double similarity;

  final String familyEn;
  final String familyHi;

  /// Human readable confidence band.
  String get confidenceLabel => similarity >= 0.72
      ? 'strong'
      : (similarity >= 0.55 ? 'moderate' : 'weak');

  Map<String, Object?> toJson() => <String, Object?>{
        'templateId': templateId,
        'titleEn': titleEn,
        'similarity': similarity,
      };
}
