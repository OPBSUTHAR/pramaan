import 'severity.dart';

/// The fraud "family" a signal belongs to. Used for grouping in the UI and for
/// letting the scorer cap how much any single family can contribute.
enum RiskCategory {
  urgency('Urgency'),
  threat('Threat'),
  payment('Payment request'),
  credential('Secret asked'),
  impersonation('Fake authority'),
  prize('Too good to be true'),
  link('Link'),
  remoteAccess('Remote access'),
  secrecy('Secrecy pressure'),
  job('Job offer'),
  investment('Investment'),
  loan('Loan'),
  upi('UPI detail'),
  format('Message shape'),
  knownPattern('Known scam template');

  const RiskCategory(this.labelEn);

  final String labelEn;

  /// Devanagari label for the category chip.
  String get labelHi => switch (this) {
    RiskCategory.urgency => 'जल्दबाज़ी',
    RiskCategory.threat => 'धमकी',
    RiskCategory.payment => 'पैसे की मांग',
    RiskCategory.credential => 'गोपनीय जानकारी',
    RiskCategory.impersonation => 'नकली अधिकारी',
    RiskCategory.prize => 'लालच',
    RiskCategory.link => 'लिंक',
    RiskCategory.remoteAccess => 'रिमोट एक्सेस',
    RiskCategory.secrecy => 'गोपनीयता का दबाव',
    RiskCategory.job => 'नौकरी का ऑफर',
    RiskCategory.investment => 'निवेश',
    RiskCategory.loan => 'लोन',
    RiskCategory.upi => 'UPI जानकारी',
    RiskCategory.format => 'संदेश की बनावट',
    RiskCategory.knownPattern => 'ज्ञात ठगी टेम्पलेट',
  };
}

/// A single reason the engine flagged (or cleared) a message.
///
/// Signals are deliberately explainable: every one carries the exact matched
/// text in [evidence] so the UI can highlight it in the original message.
class ScamSignal {
  const ScamSignal({
    required this.ruleId,
    required this.category,
    required this.severity,
    required this.weight,
    required this.titleEn,
    required this.titleHi,
    required this.explainEn,
    required this.explainHi,
    this.evidence = const <String>[],
  });

  /// Stable machine id, e.g. `otp_request`. Safe to log and to use as a key.
  final String ruleId;

  final RiskCategory category;
  final Severity severity;

  /// Base weight in 0..1 before the severity multiplier is applied.
  final double weight;

  final String titleEn;
  final String titleHi;
  final String explainEn;
  final String explainHi;

  /// Exact substrings from the input that triggered this signal.
  final List<String> evidence;

  /// Effective contribution used by the scorer.
  ///
  /// Positive for risk signals, negative for whitelist signals. Capped at 0.95
  /// so that no single rule can ever produce a flat 100 on its own.
  double get effectiveWeight {
    final double raw = weight * severity.multiplier;
    if (raw < 0) return raw < -1.0 ? -1.0 : raw;
    return raw > 0.95 ? 0.95 : raw;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'ruleId': ruleId,
    'category': category.name,
    'severity': severity.name,
    'weight': weight,
    'titleEn': titleEn,
    'titleHi': titleHi,
    'explainEn': explainEn,
    'explainHi': explainHi,
    'evidence': evidence,
  };

  @override
  String toString() =>
      'ScamSignal($ruleId, ${severity.name}, w=$weight, evidence=$evidence)';
}
