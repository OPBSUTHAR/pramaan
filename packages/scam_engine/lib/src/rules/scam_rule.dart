import '../context/scan_context.dart';
import '../models/scam_signal.dart';
import '../models/severity.dart';

/// One detector. Returns null when the message does not trip it.
abstract class ScamRule {
  const ScamRule();

  String get id;

  /// Evaluates the rule against a pre-computed context.
  ScamSignal? evaluate(ScanContext context);
}

/// A rule built from groups of patterns.
///
/// Each group is an OR-list: it "matches" when any one of its patterns is
/// present. The rule fires when at least [minGroups] groups match. That is
/// enough to express almost every real scam tell without writing imperative
/// code, e.g. "mentions KYC" AND "mentions blocking".
class DeclarativeRule extends ScamRule {
  const DeclarativeRule({
    required this.id,
    required this.category,
    required this.severity,
    required this.weight,
    required this.titleEn,
    required this.titleHi,
    required this.explainEn,
    required this.explainHi,
    required this.groups,
    this.minGroups = 2,
    this.suppress,
  });

  @override
  final String id;
  final RiskCategory category;
  final Severity severity;

  /// Base contribution in 0..1. Negative values *reduce* the final score and
  /// are used for whitelist signals.
  final double weight;

  final String titleEn;
  final String titleHi;
  final String explainEn;
  final String explainHi;

  /// OR-groups that are AND-ed together.
  final List<List<Pattern>> groups;

  /// How many groups must match for the rule to fire.
  final int minGroups;

  /// Optional escape hatch for legit look-alike messages, e.g. a bank's own
  /// "never share your OTP" advisory.
  final bool Function(ScanContext context)? suppress;

  @override
  ScamSignal? evaluate(ScanContext context) {
    if (context.isEmpty) return null;
    if (suppress != null && suppress!(context)) return null;

    final List<String> evidence = <String>[];
    int matched = 0;

    for (final List<Pattern> group in groups) {
      final List<String> hits = _matchGroup(context, group);
      if (hits.isNotEmpty) {
        matched++;
        evidence.addAll(hits);
      }
    }

    if (matched < minGroups) return null;

    return ScamSignal(
      ruleId: id,
      category: category,
      severity: severity,
      weight: weight,
      titleEn: titleEn,
      titleHi: titleHi,
      explainEn: explainEn,
      explainHi: explainHi,
      evidence: _dedupe(evidence),
    );
  }

  static List<String> _matchGroup(ScanContext context, List<Pattern> group) {
    final List<String> hits = <String>[];
    for (final Pattern pattern in group) {
      if (pattern is String) {
        if (context.has(pattern)) hits.add(pattern);
      } else if (pattern is RegExp) {
        hits.addAll(context.findAll(pattern));
      }
    }
    return hits;
  }

  static List<String> _dedupe(List<String> values) {
    final List<String> out = <String>[];
    for (final String v in values) {
      final String trimmed = v.trim();
      if (trimmed.isEmpty) continue;
      if (out.any((String e) => e.toLowerCase() == trimmed.toLowerCase())) {
        continue;
      }
      out.add(trimmed);
      if (out.length >= 6) break;
    }
    return out;
  }
}

/// Rule whose logic is easier to express in code than in patterns — used by the
/// link, domain and UPI-address detectors.
class CustomRule extends ScamRule {
  const CustomRule({
    required this.id,
    required this.category,
    required this.severity,
    required this.weight,
    required this.titleEn,
    required this.titleHi,
    required this.explainEn,
    required this.explainHi,
    required this.detect,
  });

  @override
  final String id;
  final RiskCategory category;
  final Severity severity;
  final double weight;
  final String titleEn;
  final String titleHi;
  final String explainEn;
  final String explainHi;

  /// Returns evidence strings. Empty means "no hit".
  final List<String> Function(ScanContext context) detect;

  @override
  ScamSignal? evaluate(ScanContext context) {
    if (context.isEmpty) return null;
    final List<String> evidence = detect(context);
    if (evidence.isEmpty) return null;
    return ScamSignal(
      ruleId: id,
      category: category,
      severity: severity,
      weight: weight,
      titleEn: titleEn,
      titleHi: titleHi,
      explainEn: explainEn,
      explainHi: explainHi,
      evidence: evidence.take(6).toList(growable: false),
    );
  }
}
