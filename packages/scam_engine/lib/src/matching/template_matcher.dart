import '../data/scam_templates.dart';
import '../models/scan_report.dart';
import '../text/similarity.dart';

/// Fuzzy matcher that recognises a message as a reworded version of a known
/// scam script.
///
/// This is the trick that makes the app useful without any cloud service or
/// trained model: character trigrams are robust to word substitutions, so
/// "your account will be blocked" and "account block ho jayega" land close
/// together in trigram space. Adding token overlap recovers cases where the
/// scammer swapped only names and numbers.
class TemplateMatcher {
  TemplateMatcher(List<ScamTemplate> templates)
      : _entries = templates
            .map(
              (ScamTemplate t) => _Entry(
                template: t,
                normalized: _normalize(t.body),
              ),
            )
            .toList(growable: false);

  /// Matcher pre-loaded with the bundled corpus.
  factory TemplateMatcher.builtIn() => TemplateMatcher(builtInTemplates);

  final List<_Entry> _entries;

  /// How many scam scripts are in the bundled corpus.
  int get templateCount => _entries.length;

  /// Default cut-off. Below this we say nothing rather than cry wolf.
  static const double defaultThreshold = 0.5;

  /// Finds the closest template, or null when nothing is close enough.
  TemplateMatch? match(String canonicalInput,
      {double threshold = defaultThreshold}) {
    final String normalizedInput = _normalize(canonicalInput);
    if (normalizedInput.length < 24) return null;

    final List<String> variants = _variants(normalizedInput);
    _Entry? best;
    double bestScore = 0;

    for (final _Entry entry in _entries) {
      for (final String variant in variants) {
        final double score = _score(variant, entry.normalized);
        if (score > bestScore) {
          bestScore = score;
          best = entry;
        }
      }
    }

    if (best == null || bestScore < threshold) return null;

    return TemplateMatch(
      templateId: best.template.id,
      titleEn: best.template.titleEn,
      titleHi: best.template.titleHi,
      similarity: double.parse(bestScore.toStringAsFixed(3)),
      familyEn: best.template.familyEn,
      familyHi: best.template.familyHi,
    );
  }

  /// Every template with its score, sorted best first. Used by the "why" screen
  /// and by tests.
  List<MapEntry<ScamTemplate, double>> ranked(String canonicalInput) {
    final List<String> variants = _variants(_normalize(canonicalInput));
    final List<MapEntry<ScamTemplate, double>> out =
        <MapEntry<ScamTemplate, double>>[];
    for (final _Entry entry in _entries) {
      double best = 0;
      for (final String variant in variants) {
        final double score = _score(variant, entry.normalized);
        if (score > best) best = score;
      }
      out.add(MapEntry<ScamTemplate, double>(entry.template, best));
    }
    out.sort(
        (MapEntry<ScamTemplate, double> a, MapEntry<ScamTemplate, double> b) =>
            b.value.compareTo(a.value));
    return out;
  }

  /// Compares the whole message plus its head and tail, so a scam script
  /// forwarded into a long chat thread still matches.
  static List<String> _variants(String input) {
    if (input.length <= 220) return <String>[input];
    return <String>[
      input,
      input.substring(0, 200),
      input.substring(input.length - 200),
    ];
  }

  static double _score(String a, String b) => blendedSimilarity(a, b);

  static String _normalize(String body) {
    return body
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0900-\u097F\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _Entry {
  const _Entry({required this.template, required this.normalized});

  final ScamTemplate template;
  final String normalized;
}
