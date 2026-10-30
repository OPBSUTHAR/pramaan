/// Text cleanup and feature extraction.
///
/// Indian scam messages arrive in three flavours: English, Devanagari Hindi and
/// romanised Hindi ("Hinglish"). Rather than writing every rule three times, we
/// canonicalise the message once so a single pattern set can cover all three.
library;

/// Devanagari → canonical English tokens.
///
/// A match keeps the original word *and* appends the canonical token, so the UI
/// can still highlight the user's own text.
const Map<String, String> _devanagariMap = <String, String>{
  'तुरंत': 'immediately',
  'जल्दी': 'immediately',
  'अभी': 'immediately',
  'तत्काल': 'immediately',
  'खाता': 'account',
  'खाते': 'account',
  'खातों': 'account',
  'बंद': 'block',
  'ब्लॉक': 'block',
  'निलंबित': 'suspend',
  'निष्क्रिय': 'deactivate',
  'सत्यापित': 'verify',
  'सत्यापन': 'verify',
  'केवाईसी': 'kyc',
  'बैंक': 'bank',
  'पैसे': 'money',
  'पैसा': 'money',
  'राशि': 'money',
  'भेजें': 'send',
  'भेजिए': 'send',
  'भेजो': 'send',
  'ट्रांसफर': 'transfer',
  'ओटीपी': 'otp',
  'पिन': 'pin',
  'पासवर्ड': 'password',
  'आधार': 'aadhaar',
  'कार्ड': 'card',
  'लॉटरी': 'lottery',
  'इनाम': 'prize',
  'जीत': 'won',
  'जीता': 'won',
  'उपहार': 'gift',
  'मुफ्त': 'free',
  'कृपया': 'please',
  'लिंक': 'link',
  'क्लिक': 'click',
  'कॉल': 'call',
  'नंबर': 'number',
  'व्हाट्सएप': 'whatsapp',
  'पुलिस': 'police',
  'सीबीआई': 'cbi',
  'कोर्ट': 'court',
  'गिरफ्तार': 'arrest',
  'वारंट': 'warrant',
  'नोटिस': 'notice',
  'पार्सल': 'parcel',
  'कूरियर': 'courier',
  'अवैध': 'illegal',
  'गुप्त': 'secret',
  'रिफंड': 'refund',
  'कैशबैक': 'cashback',
  'नौकरी': 'job',
  'कमाई': 'earn',
  'रोज़': 'daily',
  'निवेश': 'investment',
  'मुनाफा': 'profit',
  'लोन': 'loan',
  'ऋण': 'loan',
  'अंतिम': 'last',
  'मौका': 'chance',
  'आज': 'today',
  'घंटे': 'hours',
  'मिनट': 'minutes',
  'अपडेट': 'update',
  'साझा': 'share',
  'बताएं': 'tell',
  'बताइए': 'tell',
  'मिलेगा': 'get',
  'आपका': 'your',
  'आपके': 'your',
  'आपकी': 'your',
  'सक्रिय': 'active',
  'रद्द': 'cancel',
  'सत्यापनकरें': 'verify',
  'धन्यवाद': 'thanks',
  'शिकायत': 'complaint',
  'ठगी': 'fraud',
  'धोखा': 'fraud',
  'प्रमाण': 'proof',
  'भुगतान': 'payment',
  'स्वीकार': 'accept',
  'अनुरोध': 'request',
  'प्राप्त': 'receive',
  'क्रेडिट': 'credit',
  'डेबिट': 'debit',
  'एजेंट': 'agent',
  'ग्राहक': 'customer',
  'सेवा': 'service',
  'बंदहोगा': 'block',
  'खाताबंद': 'block',
};

/// Cyrillic / Greek characters that render identically to Latin ones. Scammers
/// use them to slip past keyword filters ("аmazon" with a Cyrillic а).
const Map<String, String> _homoglyphs = <String, String>{
  'а': 'a', 'е': 'e', 'о': 'o', 'р': 'p', 'с': 'c', 'х': 'x',
  'у': 'y', 'і': 'i', 'ѕ': 's', 'ԁ': 'd', 'м': 'm', 'т': 't',
  'н': 'h', 'в': 'b', 'к': 'k', 'ѵ': 'v', 'ԛ': 'q', 'ԝ': 'w',
  'α': 'a', 'ο': 'o', 'ν': 'v', 'ρ': 'p', 'τ': 't', 'κ': 'k',
  'μ': 'u', 'χ': 'x', 'γ': 'y', 'ε': 'e', 'ι': 'i',
};

final RegExp _zeroWidth = RegExp(r'[\u200B-\u200F\u202A-\u202E\uFEFF]');
final RegExp _whitespace = RegExp(r'\s+');
final RegExp _emoji = RegExp(
  r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{1F000}-\u{1F2FF}]',
  unicode: true,
);
final RegExp _linkPattern = RegExp(
  r'(?:https?://|www\.)[^\s<>"' "'" r']+',
  caseSensitive: false,
);
final RegExp _bareDomain = RegExp(
  r'\b(?:[a-z0-9][a-z0-9-]{0,62}\.)+'
  r'(?:com|in|net|org|xyz|top|club|site|online|info|co|io|app|link|live|icu|'
  r'buzz|shop|vip|cc|tk|ml|ga|cf|gq|work|rest|fit|best|life|world|today|'
  r'space|fun|store|pro|dev|me|su|bid|win|download|zip|mov|help|click)\b'
  r'(?:/[^\s<>"' "'" r']*)?',
  caseSensitive: false,
);
final RegExp _upiAddress = RegExp(
  r'\b[a-zA-Z0-9][a-zA-Z0-9._-]{1,60}@[a-zA-Z]{2,32}(?![\w.])',
);
final RegExp _mobileNumber = RegExp(r'(?:\+91[\s-]?)?[6-9]\d{9}\b');
final RegExp _amountPattern = RegExp(
  r'(?:₹|rs\.?|inr)\s?([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

/// Stateless helper for turning messy input into scannable features.
abstract final class TextNormalizer {
  /// Lowercased, de-obfuscated, whitespace-collapsed text with Devanagari
  /// keywords duplicated as canonical English tokens.
  ///
  /// The original Devanagari words are preserved so evidence highlighting still
  /// points at the user's own characters.
  static String canonical(String input) {
    String out = input;
    out = out.replaceAll(_zeroWidth, '');
    out = _applyHomoglyphs(out);
    out = _expandDevanagari(out);
    out = out.toLowerCase();
    out = out.replaceAll(_whitespace, ' ');
    return out.trim();
  }

  static String _applyHomoglyphs(String input) {
    final StringBuffer buf = StringBuffer();
    for (final int rune in input.runes) {
      final String ch = String.fromCharCode(rune);
      // Upper-case Cyrillic/Greek is just as common as lower-case ("РАYTM"),
      // so fall back to the lower-case entry before giving up.
      buf.write(_homoglyphs[ch] ?? _homoglyphs[ch.toLowerCase()] ?? ch);
    }
    return buf.toString();
  }

  static String _expandDevanagari(String input) {
    String out = input;
    for (final MapEntry<String, String> e in _devanagariMap.entries) {
      if (out.contains(e.key)) {
        out = out.replaceAll(e.key, '${e.key} ${e.value} ');
      }
    }
    return out;
  }

  /// All URLs and bare domains found in the text, de-duplicated.
  static List<String> links(String input) {
    final Set<String> found = <String>{};
    for (final RegExpMatch m in _linkPattern.allMatches(input)) {
      found.add(m.group(0)!.toLowerCase());
    }
    for (final RegExpMatch m in _bareDomain.allMatches(input)) {
      final String value = m.group(0)!.toLowerCase();
      // Ignore things that are really UPI handles or file names.
      if (!value.contains('@')) found.add(value);
    }
    return found.toList(growable: false);
  }

  /// UPI addresses (`user@handle`) found in the text.
  static List<String> upiAddresses(String input) {
    final Set<String> found = <String>{};
    for (final RegExpMatch m in _upiAddress.allMatches(input)) {
      found.add(m.group(0)!.toLowerCase());
    }
    return found.toList(growable: false);
  }

  /// Indian mobile numbers in the text.
  static List<String> mobileNumbers(String input) {
    final Set<String> found = <String>{};
    for (final RegExpMatch m in _mobileNumber.allMatches(input)) {
      found.add(m.group(0)!);
    }
    return found.toList(growable: false);
  }

  /// Rupee amounts mentioned in the text.
  static List<double> amounts(String input) {
    final List<double> found = <double>[];
    for (final RegExpMatch m in _amountPattern.allMatches(input)) {
      final double? value =
          double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (value != null) found.add(value);
    }
    return found;
  }

  /// Fraction of letters that are upper case (0..1).
  static double capsRatio(String input) {
    int upper = 0;
    int letters = 0;
    for (final int rune in input.runes) {
      if (rune >= 65 && rune <= 90) {
        upper++;
        letters++;
      } else if (rune >= 97 && rune <= 122) {
        letters++;
      }
    }
    if (letters < 12) return 0;
    return upper / letters;
  }

  /// Number of emoji characters.
  static int emojiCount(String input) => _emoji.allMatches(input).length;

  /// Count of exclamation marks.
  static int exclamationCount(String input) => '!'.allMatches(input).length;

  /// True when the message mixes Devanagari and Latin script.
  static bool isMixedScript(String input) {
    final bool hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(input);
    final bool hasLatin = RegExp(r'[a-zA-Z]').hasMatch(input);
    return hasDevanagari && hasLatin;
  }

  /// True when the text contains any Devanagari.
  static bool hasDevanagari(String input) =>
      RegExp(r'[\u0900-\u097F]').hasMatch(input);

  /// Rough word count.
  static int wordCount(String input) =>
      input.trim().isEmpty ? 0 : input.trim().split(_whitespace).length;
}
