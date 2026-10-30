/// Cheap, allocation-light string similarity used by the fuzzy scam-template
/// matcher. Everything here is O(n) or O(n*m) on short strings, which is fine
/// for on-device use on a phone.
library;

/// Levenshtein edit distance between two strings.
///
/// Uses the two-row dynamic-programming trick, so memory is O(min(a,b)).
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  String s = a;
  String t = b;
  if (s.length > t.length) {
    final String tmp = s;
    s = t;
    t = tmp;
  }

  final List<int> prev = List<int>.generate(s.length + 1, (int i) => i);
  final List<int> curr = List<int>.filled(s.length + 1, 0);

  for (int j = 1; j <= t.length; j++) {
    curr[0] = j;
    final int tc = t.codeUnitAt(j - 1);
    for (int i = 1; i <= s.length; i++) {
      final int cost = s.codeUnitAt(i - 1) == tc ? 0 : 1;
      final int deletion = prev[i] + 1;
      final int insertion = curr[i - 1] + 1;
      final int substitution = prev[i - 1] + cost;
      int best = deletion < insertion ? deletion : insertion;
      if (substitution < best) best = substitution;
      curr[i] = best;
    }
    for (int i = 0; i <= s.length; i++) {
      prev[i] = curr[i];
    }
  }
  return prev[s.length];
}

/// Character trigram set of a normalised string.
///
/// Padding with two sentinels lets the beginning and end of words carry weight,
/// which matters for short strings like UPI handles.
Set<String> trigrams(String input) {
  final String padded = '  $input ';
  final Set<String> out = <String>{};
  for (int i = 0; i + 3 <= padded.length; i++) {
    out.add(padded.substring(i, i + 3));
  }
  return out;
}

/// Jaccard similarity between the trigram sets of [a] and [b], 0..1.
double trigramJaccard(String a, String b) {
  final Set<String> ta = trigrams(a);
  final Set<String> tb = trigrams(b);
  if (ta.isEmpty && tb.isEmpty) return 1;
  if (ta.isEmpty || tb.isEmpty) return 0;

  final Set<String> smaller = ta.length <= tb.length ? ta : tb;
  final Set<String> larger = identical(smaller, ta) ? tb : ta;

  int intersection = 0;
  for (final String g in smaller) {
    if (larger.contains(g)) intersection++;
  }
  final int union = ta.length + tb.length - intersection;
  return union == 0 ? 0 : intersection / union;
}

/// Overlap of the *word* sets, ignoring order. 0..1.
///
/// Uses the overlap coefficient rather than Jaccard so that a short scam note
/// pasted into a long chat thread still scores highly.
double tokenOverlap(String a, String b) {
  final Set<String> ta = _tokens(a);
  final Set<String> tb = _tokens(b);
  if (ta.isEmpty && tb.isEmpty) return 1;
  if (ta.isEmpty || tb.isEmpty) return 0;

  int shared = 0;
  for (final String t in ta) {
    if (tb.contains(t)) shared++;
  }
  final int denom = ta.length < tb.length ? ta.length : tb.length;
  return denom == 0 ? 0 : shared / denom;
}

/// Blended similarity used by the template matcher.
///
/// Trigrams catch rewording ("your account will be blocked" vs "account block
/// ho jayega"), token overlap catches substituted words (numbers, names).
double blendedSimilarity(String a, String b) {
  final double tri = trigramJaccard(a, b);
  final double tok = tokenOverlap(a, b);
  return (tri * 0.62) + (tok * 0.38);
}

Set<String> _tokens(String input) {
  return input
      .split(RegExp(r'[^a-z0-9\u0900-\u097F]+'))
      .where((String t) => t.isNotEmpty)
      .toSet();
}

/// Similarity of two UPI handles, normalised for length so that short handles
/// are not unfairly penalised. Returns 0..1.
double handleSimilarity(String a, String b) {
  if (a == b) return 1;
  final int distance = levenshtein(a, b);
  final int longest = a.length > b.length ? a.length : b.length;
  if (longest == 0) return 1;
  final double ratio = 1 - (distance / longest);
  return ratio < 0 ? 0 : ratio;
}
