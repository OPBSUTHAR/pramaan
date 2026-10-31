import 'severity.dart';

/// Which UPI operation a deep link is asking for. This distinction is the whole
/// ballgame in the "collect request" scam: a link that *looks* like it will pay
/// you can actually be a debit request.
enum UpiOperation {
  /// `upi://pay` — money leaves the payer. The common QR / link form.
  pay,

  /// `upi://mandate` — sets up an auto-debit (e-Mandate / UPI AutoPay).
  mandate,

  /// A collect / pull request. You approve it and money leaves your account.
  collect,

  /// `upi://intent` or unknown scheme.
  unknown;

  String get labelEn => switch (this) {
        UpiOperation.pay => 'Pay request',
        UpiOperation.mandate => 'Auto-debit mandate',
        UpiOperation.collect => 'Collect (debit) request',
        UpiOperation.unknown => 'Unknown request',
      };

  String get labelHi => switch (this) {
        UpiOperation.pay => 'भुगतान अनुरोध',
        UpiOperation.mandate => 'ऑटो-डेबिट मैंडेट',
        UpiOperation.collect => 'कलेक्ट (डेबिट) अनुरोध',
        UpiOperation.unknown => 'अज्ञात अनुरोध',
      };
}

/// A parsed `name@handle` UPI address.
class Vpa {
  const Vpa(
      {required this.address, required this.username, required this.handle});

  /// The full address as written, e.g. `omprakash@okhdfcbank`.
  final String address;

  /// The part before the `@`.
  final String username;

  /// The PSP handle after the `@`, lowercased.
  final String handle;

  @override
  String toString() => address;
}

/// Something worth telling the user about a UPI address or link.
class UpiWarning {
  const UpiWarning({
    required this.code,
    required this.severity,
    required this.messageEn,
    required this.messageHi,
  });

  /// Stable id, e.g. `unknown_handle`.
  final String code;

  final Severity severity;
  final String messageEn;
  final String messageHi;

  Map<String, Object?> toJson() => <String, Object?>{
        'code': code,
        'severity': severity.name,
      };
}

/// Everything we could pull out of a UPI link or QR payload, fully offline.
class UpiIntent {
  const UpiIntent({
    required this.raw,
    required this.operation,
    this.payeeAddress,
    this.payeeName,
    this.amount,
    this.currency,
    this.transactionNote,
    this.merchantCode,
    this.transactionRef,
    this.signaturePresent = false,
    this.warnings = const <UpiWarning>[],
  });

  final String raw;
  final UpiOperation operation;
  final String? payeeAddress;
  final String? payeeName;

  /// Amount pre-filled by the link, if any.
  final double? amount;

  final String? currency;
  final String? transactionNote;
  final String? merchantCode;
  final String? transactionRef;

  /// Whether the link carried a `sign` parameter. Unsigned links are editable.
  final bool signaturePresent;

  final List<UpiWarning> warnings;

  /// True when the link forces an amount the user did not choose.
  bool get hasPrefilledAmount => amount != null && amount! > 0;

  /// True when the payee never identified itself — a classic mule-account tell.
  bool get isAnonymousPayee =>
      (payeeName == null || payeeName!.trim().isEmpty) &&
      (merchantCode == null || merchantCode!.trim().isEmpty);

  /// A merchant code starting with `5` is a real registered merchant (MCC).
  bool get looksLikeRegisteredMerchant =>
      merchantCode != null && RegExp(r'^\d{4}$').hasMatch(merchantCode!);

  /// Highest severity among the collected warnings.
  Severity get worstSeverity {
    Severity worst = Severity.info;
    for (final UpiWarning w in warnings) {
      if (w.severity.index > worst.index) worst = w.severity;
    }
    return worst;
  }
}
