import '../models/severity.dart';
import '../models/upi_intent.dart';
import 'vpa.dart';

/// Reads UPI deep links and QR payloads offline.
///
/// A QR code is just text. Decoding it locally (rather than opening a payment
/// app straight away) is what lets the app show the user the payee, the amount
/// and the request type *before* any money moves.
abstract final class UpiLinkParser {
  /// Words a genuine merchant would not need in its display name.
  static const List<String> _suspiciousPayeeWords = <String>[
    'refund', 'support', 'helpdesk', 'helpline', 'kyc', 'verify',
    'verification', 'official', 'rbi', 'customs', 'police', 'cbi',
    'lottery', 'prize', 'cashback', 'reward', 'claim', 'customer care',
    'government', 'govt', 'income tax',
  ];

  /// True when [raw] looks like something we can inspect.
  static bool looksLikeUpi(String raw) {
    final String value = _decoded(raw).toLowerCase();
    return value.contains('upi://') ||
        value.contains('upi:') ||
        VpaInspector.isValid(raw.trim());
  }

  /// Parses a UPI link, QR payload or bare VPA into a [UpiIntent].
  ///
  /// Never throws: malformed input comes back as an intent with a warning.
  static UpiIntent parse(String raw) {
    final String trimmed = raw.trim();
    final String decoded = _decoded(trimmed);

    // Bare VPA: "name@okhdfcbank"
    if (!decoded.toLowerCase().contains('upi:') && VpaInspector.isValid(trimmed)) {
      return UpiIntent(
        raw: trimmed,
        operation: UpiOperation.pay,
        payeeAddress: trimmed.toLowerCase(),
        warnings: <UpiWarning>[
          ...VpaInspector.inspect(trimmed),
          const UpiWarning(
            code: 'p2p_no_chargeback',
            severity: Severity.info,
            messageEn:
                'This is a personal UPI ID, not a registered merchant. UPI '
                'transfers to individuals are final — there is no chargeback.',
            messageHi:
                'यह निजी UPI ID है, पंजीकृत दुकानदार नहीं। किसी व्यक्ति को भेजा गया '
                'UPI पैसा वापस नहीं होता — कोई चार्जबैक नहीं।',
          ),
        ],
      );
    }

    final int start = decoded.toLowerCase().indexOf('upi:');
    if (start == -1) {
      return UpiIntent(
        raw: trimmed,
        operation: UpiOperation.unknown,
        warnings: const <UpiWarning>[
          UpiWarning(
            code: 'not_a_upi_link',
            severity: Severity.medium,
            messageEn:
                'This does not contain a UPI link or a valid UPI ID, so there is '
                'nothing to inspect.',
            messageHi:
                'इसमें कोई UPI लिंक या मान्य UPI ID नहीं है, इसलिए जाँचने के लिए कुछ '
                'नहीं है।',
          ),
        ],
      );
    }

    final String link = decoded.substring(start);
    final Uri? uri = Uri.tryParse(link);

    if (uri == null) {
      return UpiIntent(
        raw: trimmed,
        operation: UpiOperation.unknown,
        warnings: const <UpiWarning>[
          UpiWarning(
            code: 'unparseable',
            severity: Severity.high,
            messageEn:
                'This link claims to be a UPI link but is malformed. Do not open '
                'it in a payment app.',
            messageHi:
                'यह लिंक UPI का दावा करता है पर टूटा हुआ है। इसे किसी पेमेंट ऐप में '
                'न खोलें।',
          ),
        ],
      );
    }

    final Map<String, String> q = uri.queryParameters;
    final UpiOperation operation = _operationOf(uri);
    final String? pa = _nonEmpty(q['pa']);
    final String? pn = _nonEmpty(q['pn']);
    final String? am = _nonEmpty(q['am']);
    final String? mc = _nonEmpty(q['mc']);
    final String? cu = _nonEmpty(q['cu']);
    final String? tn = _nonEmpty(q['tn']);
    final String? tr = _nonEmpty(q['tr']) ?? _nonEmpty(q['tid']);
    final bool hasSign = _nonEmpty(q['sign']) != null;

    final double? amount = am == null ? null : double.tryParse(am);

    final List<UpiWarning> warnings = <UpiWarning>[];

    if (operation == UpiOperation.collect) {
      warnings.add(
        const UpiWarning(
          code: 'collect_operation',
          severity: Severity.critical,
          messageEn:
              'This is a collect (pull) request. Approving it moves money OUT of '
              'your account, even if the sender calls it a refund.',
          messageHi:
              'यह कलेक्ट (पुल) रिक्वेस्ट है। इसे मंज़ूर करने पर आपके खाते से पैसे '
              'कटेंगे, चाहे भेजने वाला इसे रिफंड कहे।',
        ),
      );
    }
    if (operation == UpiOperation.mandate) {
      warnings.add(
        const UpiWarning(
          code: 'mandate_operation',
          severity: Severity.critical,
          messageEn:
              'This sets up an auto-debit mandate: your account will be charged '
              'repeatedly without asking you again. Only accept mandates you '
              'created yourself in your own bank app.',
          messageHi:
              'यह ऑटो-डेबिट मैंडेट बनाता है: आपके खाते से बार-बार पैसे कटेंगे, दोबारा '
              'पूछे बिना। सिर्फ वही मैंडेट मंज़ूर करें जो आपने खुद अपने बैंक ऐप में '
              'बनाया हो।',
        ),
      );
    }
    if (amount != null && amount > 0) {
      warnings.add(
        UpiWarning(
          code: 'prefilled_amount',
          severity: Severity.medium,
          messageEn:
              'This link already fills in ${_rupees(amount)}. You did not choose '
              'that amount — check it before you approve.',
          messageHi:
              'यह लिंक पहले से ${_rupees(amount)} भर देता है। यह रकम आपने नहीं चुनी — '
              'मंज़ूर करने से पहले जाँचें।',
        ),
      );
    }
    if (amount != null && amount >= 100000) {
      warnings.add(
        const UpiWarning(
          code: 'large_amount',
          severity: Severity.high,
          messageEn:
              'The pre-filled amount is over ₹1,00,000. Fraudsters use large '
              'round numbers to look like official fees.',
          messageHi:
              'पहले से भरी रकम ₹1,00,000 से ज़्यादा है। ठग बड़ी गोल रकम को सरकारी फीस '
              'बताते हैं।',
        ),
      );
    }
    if (pa == null) {
      warnings.add(
        const UpiWarning(
          code: 'no_payee',
          severity: Severity.critical,
          messageEn:
              'The link has no payee address at all. A real UPI link always names '
              'who is being paid.',
          messageHi:
              'लिंक में पाने वाले का UPI पता ही नहीं है। असली UPI लिंक में हमेशा होता '
              'है कि पैसा किसे जा रहा है।',
        ),
      );
    }
    if (pn != null) {
      final String lower = pn.toLowerCase();
      for (final String word in _suspiciousPayeeWords) {
        if (lower.contains(word)) {
          warnings.add(
            UpiWarning(
              code: 'suspicious_payee_name',
              severity: Severity.high,
              messageEn:
                  'The payee calls itself "$pn". Official desks never take '
                  'payments through a personal UPI name.',
              messageHi:
                  'पाने वाले का नाम "$pn" है। सरकारी या बैंक डेस्क कभी निजी UPI नाम से '
                  'भुगतान नहीं लेते।',
            ),
          );
          break;
        }
      }
    }
    if (pa != null) {
      warnings.addAll(VpaInspector.inspect(pa));
    }
    if (!hasSign) {
      warnings.add(
        const UpiWarning(
          code: 'unsigned_link',
          severity: Severity.info,
          messageEn:
              'This link is not signed, so any field in it — including the amount '
              'and the payee — can be edited by whoever sent it.',
          messageHi:
              'यह लिंक साइन नहीं है, इसलिए इसमें रकम और पाने वाले सहित कोई भी जानकारी '
              'भेजने वाला बदल सकता है।',
        ),
      );
    }
    if (mc == null) {
      warnings.add(
        const UpiWarning(
          code: 'no_merchant_code',
          severity: Severity.info,
          messageEn:
              'No merchant code, so this is a person-to-person payment. P2P '
              'payments cannot be reversed or disputed.',
          messageHi:
              'मर्चेंट कोड नहीं है, इसलिए यह व्यक्ति-से-व्यक्ति भुगतान है। ऐसे भुगतान '
              'वापस या विवादित नहीं हो सकते।',
        ),
      );
    }

    return UpiIntent(
      raw: trimmed,
      operation: operation,
      payeeAddress: pa,
      payeeName: pn,
      amount: amount,
      currency: cu ?? 'INR',
      transactionNote: tn,
      merchantCode: mc,
      transactionRef: tr,
      signaturePresent: hasSign,
      warnings: _dedupeWarnings(warnings),
    );
  }

  static UpiOperation _operationOf(Uri uri) {
    final String host = uri.host.toLowerCase();
    if (host == 'pay') return UpiOperation.pay;
    if (host == 'mandate') return UpiOperation.mandate;
    if (host == 'collect' || host == 'pull') return UpiOperation.collect;
    // Some apps use upi://?pa=... with no host at all.
    if (host.isEmpty) return UpiOperation.pay;
    return UpiOperation.unknown;
  }

  static String _decoded(String raw) {
    final String lower = raw.toLowerCase();
    if (lower.contains('upi%3a') || lower.contains('%3fpa%3d')) {
      try {
        return Uri.decodeComponent(raw);
      } on ArgumentError {
        return raw;
      }
    }
    return raw;
  }

  static String? _nonEmpty(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<UpiWarning> _dedupeWarnings(List<UpiWarning> warnings) {
    final Map<String, UpiWarning> byCode = <String, UpiWarning>{};
    for (final UpiWarning w in warnings) {
      final UpiWarning? existing = byCode[w.code];
      if (existing == null || w.severity.index > existing.severity.index) {
        byCode[w.code] = w;
      }
    }
    return byCode.values.toList(growable: false);
  }

  static String _rupees(double amount) {
    final String text = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    // Indian digit grouping.
    if (text.length <= 3) return '₹$text';
    final String last3 = text.substring(text.length - 3);
    String rest = text.substring(0, text.length - 3);
    final List<String> parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${parts.join(',')},$last3';
  }
}
