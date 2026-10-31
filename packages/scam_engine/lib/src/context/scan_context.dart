import '../text/normalizer.dart';

/// Everything a rule might want to know about one message, computed once.
///
/// Rules receive this instead of the raw string so expensive work (regex
/// tokenising, link extraction, Unicode folding) happens exactly once per scan.
class ScanContext {
  ScanContext(String raw)
      : raw = raw.trim(),
        text = TextNormalizer.canonical(raw);

  /// The message exactly as the user pasted it. Used for evidence highlighting.
  final String raw;

  /// Lowercased, homoglyph-folded, whitespace-collapsed, Devanagari-expanded
  /// version of [raw]. All rule matching runs against this.
  final String text;

  late final List<String> links = TextNormalizer.links(raw);
  late final List<String> upiAddresses = TextNormalizer.upiAddresses(raw);
  late final List<String> mobileNumbers = TextNormalizer.mobileNumbers(raw);
  late final List<double> amounts = TextNormalizer.amounts(raw);
  late final double capsRatio = TextNormalizer.capsRatio(raw);
  late final int emojiCount = TextNormalizer.emojiCount(raw);
  late final int exclamationCount = TextNormalizer.exclamationCount(raw);
  late final int wordCount = TextNormalizer.wordCount(raw);
  late final bool isMixedScript = TextNormalizer.isMixedScript(raw);
  late final bool hasDevanagari = TextNormalizer.hasDevanagari(raw);

  /// True when the message is empty or too short to say anything useful.
  bool get isEmpty => text.isEmpty;

  /// True when the message contains [needle] (already lower case).
  bool has(String needle) => text.contains(needle);

  /// True when *any* of [needles] appears.
  bool hasAny(Iterable<String> needles) {
    for (final String n in needles) {
      if (text.contains(n)) return true;
    }
    return false;
  }

  /// True when *all* of [needles] appear somewhere in the message.
  bool hasAll(Iterable<String> needles) {
    for (final String n in needles) {
      if (!text.contains(n)) return false;
    }
    return true;
  }

  /// Number of distinct needles that appear.
  int countOf(Iterable<String> needles) {
    int count = 0;
    for (final String n in needles) {
      if (text.contains(n)) count++;
    }
    return count;
  }

  /// True when [pattern] matches anywhere.
  bool matches(RegExp pattern) => pattern.hasMatch(text);

  /// All matched substrings for [pattern], de-duplicated and trimmed.
  List<String> findAll(RegExp pattern) {
    final Set<String> out = <String>{};
    for (final RegExpMatch m in pattern.allMatches(text)) {
      final String value = m.group(0)?.trim() ?? '';
      if (value.isNotEmpty) out.add(value);
    }
    return out.toList(growable: false);
  }

  /// The first matched substring for [pattern], or null.
  String? findFirst(RegExp pattern) =>
      pattern.firstMatch(text)?.group(0)?.trim();

  /// Largest rupee amount mentioned, or null.
  double? get largestAmount => amounts.isEmpty
      ? null
      : amounts.reduce((double a, double b) => a > b ? a : b);

  /// True when the message contains a UPI deep link or QR payload.
  bool get containsUpiLink =>
      text.contains('upi://') || text.contains('upi%3a%2f%2f');

  /// Every link plus every bare UPI address, for the link rules.
  List<String> get allReferences => <String>[...links, ...upiAddresses];

  @override
  String toString() => 'ScanContext(${text.length} chars, '
      '${links.length} links, ${upiAddresses.length} vpa)';
}
