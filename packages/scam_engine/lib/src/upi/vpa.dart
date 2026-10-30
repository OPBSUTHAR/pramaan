import '../data/psp_handles.dart';
import '../models/severity.dart';
import '../models/upi_intent.dart';
import '../text/similarity.dart';

/// Validates and vets `name@handle` UPI addresses without any network call.
abstract final class VpaInspector {
  /// RFC-ish shape: a user part, one `@`, and an alphabetic PSP handle.
  static final RegExp _shape = RegExp(
    r'^[a-zA-Z0-9][a-zA-Z0-9._-]{0,60}@[a-zA-Z][a-zA-Z]{1,31}$',
  );

  /// Usernames that impersonate a bank or support desk.
  static const List<String> _brandWords = <String>[
    'sbi', 'hdfc', 'icici', 'axis', 'kotak', 'paytm', 'phonepe', 'gpay',
    'googlepay', 'amazon', 'flipkart', 'irctc', 'rbi', 'npci', 'uidai',
    'helpdesk', 'customercare', 'support', 'refund', 'kyc', 'official',
    'verify', 'bank', 'payments', 'wallet',
  ];

  /// Parses [raw] into a [Vpa], or null when the shape is invalid.
  static Vpa? parse(String raw) {
    final String value = raw.trim();
    if (!_shape.hasMatch(value)) return null;
    final int at = value.indexOf('@');
    return Vpa(
      address: value,
      username: value.substring(0, at),
      handle: value.substring(at + 1).toLowerCase(),
    );
  }

  /// True when [raw] is a syntactically valid UPI address.
  static bool isValid(String raw) => parse(raw) != null;

  /// Every concern worth surfacing about [raw]. Empty means "nothing wrong".
  static List<UpiWarning> inspect(String raw) {
    final String value = raw.trim();
    final Vpa? vpa = parse(value);

    if (vpa == null) {
      return const <UpiWarning>[
        UpiWarning(
          code: 'malformed',
          severity: Severity.high,
          messageEn:
              'This is not a valid UPI ID. A real one looks like name@okhdfcbank '
              '— exactly one @ and an alphabetic bank handle.',
          messageHi:
              'यह मान्य UPI ID नहीं है। असली UPI ID ऐसी दिखती है: name@okhdfcbank — '
              'एक ही @ और अक्षरों वाला बैंक हैंडल।',
        ),
      ];
    }

    final List<UpiWarning> warnings = <UpiWarning>[];
    final String handle = vpa.handle;

    if (!PspRegistry.isKnown(handle)) {
      final List<String> near = PspRegistry.lookalikes(handle);
      if (near.isNotEmpty) {
        warnings.add(
          UpiWarning(
            code: 'typosquat_handle',
            severity: Severity.critical,
            messageEn:
                'The handle "@$handle" is one or two letters away from '
                '"@${near.first}", which is a real bank. Fraudsters register '
                'these look-alikes so your money lands with them.',
            messageHi:
                'हैंडल "@$handle" असली बैंक के "@${near.first}" से एक-दो अक्षर ही अलग '
                'है। ठग ऐसे मिलते-जुलते हैंडल बनाते हैं ताकि पैसा उनके पास जाए।',
          ),
        );
      } else {
        warnings.add(
          UpiWarning(
            code: 'unknown_handle',
            severity: Severity.high,
            messageEn:
                'No regulated bank or wallet issues the handle "@$handle". The '
                'part after @ is set by the bank, not by the user, so this is '
                'likely a mule account.',
            messageHi:
                '"@$handle" हैंडल कोई विनियमित बैंक या वॉलेट नहीं देता। @ के बाद का '
                'हिस्सा बैंक तय करता है, यूज़र नहीं — यह म्यूल खाता हो सकता है।',
          ),
        );
      }
    }

    // Brand name sitting in the username while the handle is a generic wallet.
    final String username = vpa.username.toLowerCase();
    for (final String word in _brandWords) {
      if (username.contains(word) && word.length >= 3) {
        warnings.add(
          UpiWarning(
            code: 'brand_in_username',
            severity: Severity.medium,
            messageEn:
                'The name "$username" borrows the word "$word", but a UPI '
                'username is chosen freely by whoever owns the account. It proves '
                'nothing about who they are.',
            messageHi:
                'नाम "$username" में "$word" शब्द जोड़ा गया है, लेकिन UPI यूज़रनेम '
                'खाताधारक खुद चुनता है। इससे यह साबित नहीं होता कि वे कौन हैं।',
          ),
        );
        break;
      }
    }

    // A single-character difference in a short username is meaningless, so only
    // flag near-duplicates against the *same* handle family.
    if (username.length >= 6) {
      for (final String word in _brandWords) {
        if (username == word) continue;
        if (username.length - word.length > 3) continue;
        final double sim = handleSimilarity(username, word);
        if (sim >= 0.9 && sim < 1.0 && username.contains(word) == false) {
          warnings.add(
            UpiWarning(
              code: 'lookalike_username',
              severity: Severity.medium,
              messageEn:
                  'The username "$username" is one keystroke away from "$word". '
                  'Check every letter before you pay.',
              messageHi:
                  'यूज़रनेम "$username" "$word" से एक अक्षर ही अलग है। भुगतान से पहले '
                  'हर अक्षर जाँचें।',
            ),
          );
          break;
        }
      }
    }

    return warnings;
  }
}
