import 'severity.dart';

/// The overall verdict for a scanned message.
enum RiskLevel {
  /// Nothing suspicious found. Still not a guarantee of legitimacy.
  safe,

  /// Some weak signals. Probably fine, but read it twice.
  caution,

  /// Multiple signals line up. Treat with real suspicion.
  suspicious,

  /// Strong scam shape. Do not act on this message.
  dangerous,

  /// Matches known fraud patterns or asks for secrets. Stop immediately.
  critical;

  /// Maps a 0-100 score onto a verdict band.
  static RiskLevel fromScore(int score) {
    if (score >= 80) return RiskLevel.critical;
    if (score >= 60) return RiskLevel.dangerous;
    if (score >= 35) return RiskLevel.suspicious;
    if (score >= 15) return RiskLevel.caution;
    return RiskLevel.safe;
  }

  /// Short English label.
  String get labelEn => switch (this) {
        RiskLevel.safe => 'Looks safe',
        RiskLevel.caution => 'Be careful',
        RiskLevel.suspicious => 'Suspicious',
        RiskLevel.dangerous => 'Dangerous',
        RiskLevel.critical => 'Stop — scam pattern',
      };

  /// Short Hindi label (Devanagari).
  String get labelHi => switch (this) {
        RiskLevel.safe => 'सुरक्षित लगता है',
        RiskLevel.caution => 'सावधान रहें',
        RiskLevel.suspicious => 'संदिग्ध',
        RiskLevel.dangerous => 'खतरनाक',
        RiskLevel.critical => 'रुकें — ठगी का पैटर्न',
      };

  /// One-line explanation of what the user should do next.
  String get adviceEn => switch (this) {
        RiskLevel.safe =>
          'No scam patterns matched. That does not prove the sender is genuine — '
              'never share an OTP or UPI PIN with anyone.',
        RiskLevel.caution =>
          'A couple of weak signals showed up. Verify the sender through an '
              'official number you looked up yourself.',
        RiskLevel.suspicious =>
          'Several fraud indicators are present. Do not click links, do not call '
              'the number in the message, and check your bank app directly.',
        RiskLevel.dangerous =>
          'This message has the shape of a known scam. Do not pay, do not share '
              'anything, and report it.',
        RiskLevel.critical =>
          'This matches fraud patterns that are actively draining accounts. Stop '
              'all contact and report immediately.',
      };

  /// One-line Hindi explanation of what the user should do next.
  String get adviceHi => switch (this) {
        RiskLevel.safe =>
          'कोई ठगी पैटर्न नहीं मिला। इसका मतलब यह नहीं कि भेजने वाला असली है — '
              'OTP या UPI पिन कभी किसी को न बताएं।',
        RiskLevel.caution =>
          'कुछ कमज़ोर संकेत मिले हैं। भेजने वाले की पुष्टि खुद खोजे गए आधिकारिक '
              'नंबर से करें।',
        RiskLevel.suspicious =>
          'कई ठगी के संकेत हैं। लिंक पर क्लिक न करें, संदेश वाले नंबर पर कॉल न करें, '
              'सीधे बैंक ऐप में जाँचें।',
        RiskLevel.dangerous =>
          'यह जानी-पहचानी ठगी जैसा है। पैसे न भेजें, कोई जानकारी न दें, और रिपोर्ट करें।',
        RiskLevel.critical =>
          'यह उन ठगी पैटर्न से मेल खाता है जिनसे खाते खाली हो रहे हैं। तुरंत संपर्क '
              'रोकें और शिकायत करें।',
      };

  /// Severity used for colour coding in the UI.
  Severity get severity => switch (this) {
        RiskLevel.safe => Severity.info,
        RiskLevel.caution => Severity.low,
        RiskLevel.suspicious => Severity.medium,
        RiskLevel.dangerous => Severity.high,
        RiskLevel.critical => Severity.critical,
      };
}
