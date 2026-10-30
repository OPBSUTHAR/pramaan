import '../context/scan_context.dart';
import '../data/known_domains.dart';
import '../data/psp_handles.dart';
import '../models/scam_signal.dart';
import '../models/severity.dart';
import '../text/similarity.dart';
import 'scam_rule.dart';

/// The default detector set.
///
/// Ordering does not matter — the scorer sorts by strength — but grouping here
/// follows the typical anatomy of a fraud attempt: hook, pressure, ask.
List<ScamRule> buildDefaultRules() => <ScamRule>[
  ..._credentialRules,
  ..._paymentRules,
  ..._pressureRules,
  ..._impersonationRules,
  ..._lureRules,
  ..._linkRules,
  ..._upiRules,
  ..._formatRules,
  _trustedDomainRule,
];

// ---------------------------------------------------------------------------
// 1. Secrets: OTP, PIN, CVV. A legitimate organisation never asks.
// ---------------------------------------------------------------------------

const List<ScamRule> _credentialRules = <ScamRule>[
  DeclarativeRule(
    id: 'otp_request',
    category: RiskCategory.credential,
    severity: Severity.critical,
    weight: 0.92,
    titleEn: 'Someone is asking for your OTP',
    titleHi: 'आपसे OTP मांगा जा रहा है',
    explainEn:
        'No bank, wallet, delivery company or government office will ever ask '
        'you for an OTP. An OTP is the last lock on your money — the moment you '
        'share it, the payment is authorised by you.',
    explainHi:
        'कोई भी बैंक, वॉलेट, डिलीवरी कंपनी या सरकारी दफ्तर आपसे OTP नहीं मांगता। '
        'OTP आपके पैसे का आखिरी ताला है — एक बार बता दिया तो भुगतान आपके नाम पर '
        'हो जाएगा।',
    groups: <List<Pattern>>[
      <Pattern>['otp', 'one time password', 'o.t.p', 'verification code'],
      <Pattern>[
        'share', 'send', 'tell', 'forward', 'provide', 'give', 'enter',
        'bataye', 'batao', 'bhej', 'bolo', 'daal', 'de do', 'read out',
      ],
    ],
    suppress: _isSafetyAdvisory,
  ),
  DeclarativeRule(
    id: 'upi_pin_request',
    category: RiskCategory.credential,
    severity: Severity.critical,
    weight: 0.95,
    titleEn: 'Someone is asking for your UPI PIN',
    titleHi: 'आपसे UPI पिन मांगा जा रहा है',
    explainEn:
        'A UPI PIN is only ever typed into your own bank app to *send* money. '
        'If anyone asks you to enter or share your PIN to "receive" a refund, it '
        'is a debit in disguise.',
    explainHi:
        'UPI पिन सिर्फ अपने बैंक ऐप में पैसे *भेजने* के लिए डाला जाता है। अगर कोई '
        '"रिफंड लेने" के लिए पिन डालने को कहे, तो वह असल में आपके खाते से पैसे '
        'कटवा रहा है।',
    groups: <List<Pattern>>[
      <Pattern>[
        'upi pin', 'upi पिन', 'mpin', 'm-pin', 'atm pin', 'card pin',
        'secret pin', 'pin number', '4 digit pin', '6 digit pin', 'pin daal',
        'pin dalo', 'pin enter',
      ],
    ],
    minGroups: 1,
    suppress: _isSafetyAdvisory,
  ),
  DeclarativeRule(
    id: 'card_details_request',
    category: RiskCategory.credential,
    severity: Severity.critical,
    weight: 0.88,
    titleEn: 'Card number / CVV being collected',
    titleHi: 'कार्ड नंबर / CVV मांगा जा रहा है',
    explainEn:
        'Card number, expiry and CVV together let anyone drain the card online. '
        'No genuine refund, KYC update or delivery needs them over chat.',
    explainHi:
        'कार्ड नंबर, एक्सपायरी और CVV मिलकर किसी को भी ऑनलाइन भुगतान करने देते हैं। '
        'कोई असली रिफंड, KYC या डिलीवरी चैट पर ये नहीं मांगती।',
    groups: <List<Pattern>>[
      <Pattern>['cvv', 'card number', '16 digit', 'expiry date', 'valid thru'],
      <Pattern>[
        'share', 'send', 'tell', 'provide', 'enter', 'confirm', 'bataye',
        'bhej', 'daal', 'photo', 'screenshot', 'back side', 'front side',
      ],
    ],
    suppress: _isSafetyAdvisory,
  ),
  DeclarativeRule(
    id: 'aadhaar_share_request',
    category: RiskCategory.credential,
    severity: Severity.high,
    weight: 0.7,
    titleEn: 'Aadhaar details being collected over chat',
    titleHi: 'चैट पर आधार जानकारी मांगी जा रही है',
    explainEn:
        'Aadhaar numbers are used to open mule accounts and take loans in your '
        'name. Only share Aadhaar inside an official portal or at a bank branch.',
    explainHi:
        'आधार नंबर से आपके नाम पर फर्जी खाते और लोन खुलवाए जाते हैं। आधार सिर्फ '
        'आधिकारिक पोर्टल या बैंक शाखा में ही दें।',
    groups: <List<Pattern>>[
      <Pattern>['aadhaar', 'aadhar', 'आधार', 'uidai number', '12 digit'],
      <Pattern>[
        'send', 'share', 'photo', 'screenshot', 'whatsapp', 'forward',
        'bataye', 'bhej', 'daal', 'upload',
      ],
    ],
  ),
];

// ---------------------------------------------------------------------------
// 2. Payment traps: collect requests, QR-to-receive, APK installs.
// ---------------------------------------------------------------------------

const List<ScamRule> _paymentRules = <ScamRule>[
  DeclarativeRule(
    id: 'collect_request_trap',
    category: RiskCategory.payment,
    severity: Severity.critical,
    weight: 0.9,
    titleEn: 'A "collect request" that actually takes money',
    titleHi: '"कलेक्ट रिक्वेस्ट" जो असल में पैसे काटती है',
    explainEn:
        'Approving a UPI collect or mandate request moves money *out* of your '
        'account. Scammers frame it as "accept to receive". Money never arrives '
        'by approving a request — only by you receiving a credit notification.',
    explainHi:
        'UPI कलेक्ट या मैंडेट रिक्वेस्ट मंज़ूर करने पर पैसे आपके खाते से *कटते* हैं। '
        'ठग इसे "पैसे लेने के लिए एक्सेप्ट करें" बोलते हैं। रिक्वेस्ट मंज़ूर करने से '
        'पैसे कभी नहीं आते।',
    groups: <List<Pattern>>[
      <Pattern>[
        'collect request', 'payment request', 'request money', 'accept request',
        'approve request', 'mandate', 'autopay', 'auto-debit', 'autodebit',
        'auto debit', 'e-mandate', 'request bheja', 'request bheji',
      ],
      <Pattern>[
        'receive', 'refund', 'cashback', 'credit', 'paise aayenge', 'get money',
        'money will be credited', 'paisa milega', 'receive money', 'claim',
        'accept karo', 'approve karo',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'scan_qr_to_receive',
    category: RiskCategory.payment,
    severity: Severity.high,
    weight: 0.85,
    titleEn: 'Told to scan a QR code to "receive" money',
    titleHi: '"पैसे लेने" के लिए QR स्कैन करने को कहा गया',
    explainEn:
        'Scanning a QR code always *sends* money. There is no QR code in India '
        'that pays you. Anyone who says "scan this to receive" is taking money.',
    explainHi:
        'QR स्कैन करने से हमेशा पैसे *जाते* हैं। भारत में ऐसा कोई QR नहीं जो आपको '
        'पैसे दे। जो कहे "यह स्कैन करो पैसे लेने के लिए", वह पैसे ले रहा है।',
    groups: <List<Pattern>>[
      <Pattern>['qr', 'scan this', 'scan the code', 'qr code', 'scanner'],
      <Pattern>[
        'receive', 'refund', 'get money', 'paise lene', 'paisa lene',
        'credit', 'cashback', 'milega', 'aa jayenge', 'aayenge',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'apk_install_request',
    category: RiskCategory.payment,
    severity: Severity.critical,
    weight: 0.9,
    titleEn: 'An .apk file is being pushed at you',
    titleHi: 'आपको .apk फाइल भेजी जा रही है',
    explainEn:
        'Sideloaded APKs are how banking trojans get onto Indian phones. They '
        'read your SMS, steal OTPs and control your screen. Legitimate apps come '
        'from the Play Store only.',
    explainHi:
        '.apk फाइल से ही बैंकिंग ट्रोजन भारतीय फोन में घुसते हैं। ये आपके SMS पढ़ते '
        'हैं, OTP चुराते हैं और स्क्रीन कंट्रोल करते हैं। असली ऐप सिर्फ Play Store '
        'से आते हैं।',
    groups: <List<Pattern>>[
      <Pattern>['.apk', 'apk file', 'install this app', 'install the app'],
    ],
    minGroups: 1,
  ),
  DeclarativeRule(
    id: 'remote_access_app',
    category: RiskCategory.remoteAccess,
    severity: Severity.critical,
    weight: 0.95,
    titleEn: 'You are being asked to install a screen-sharing app',
    titleHi: 'आपसे स्क्रीन शेयरिंग ऐप इंस्टॉल करवाया जा रहा है',
    explainEn:
        'AnyDesk, TeamViewer, QuickSupport and RustDesk let a stranger watch and '
        'control your phone — including reading OTPs. This is the single most '
        'common step in high-value UPI fraud.',
    explainHi:
        'AnyDesk, TeamViewer, QuickSupport और RustDesk से अजनबी आपका फोन देख और '
        'चला सकता है — OTP भी पढ़ सकता है। बड़ी UPI ठगी में यही सबसे आम कदम है।',
    groups: <List<Pattern>>[
      <Pattern>[
        'anydesk', 'teamviewer', 'quick support', 'quicksupport', 'rustdesk',
        'airdroid', 'ultraviewer', 'vysor', 'screen share', 'screenshare',
        'screen sharing', 'mirror your screen', 'desktop share', 'remote access',
        'remote support', 'scrcpy',
      ],
    ],
    minGroups: 1,
  ),
  DeclarativeRule(
    id: 'money_already_sent',
    category: RiskCategory.payment,
    severity: Severity.high,
    weight: 0.72,
    titleEn: 'Pressure to re-send money that "did not arrive"',
    titleHi: '"पैसे नहीं पहुंचे" कहकर दोबारा भेजने का दबाव',
    explainEn:
        'A seller claiming your payment failed and asking for a second transfer '
        'is a classic double-dip. Check your bank app for the debit — never '
        'trust a screenshot.',
    explainHi:
        '"भुगतान फेल हो गया, दोबारा भेजो" कहना दोहरी ठगी की क्लासिक चाल है। अपने बैंक '
        'ऐप में डेबिट देखें — स्क्रीनशॉट पर भरोसा न करें।',
    groups: <List<Pattern>>[
      <Pattern>[
        'already sent', 'amount debited', 'payment done', 'i have paid',
        'transfer done', 'upi done', 'payment ho gaya', 'paisa bhej diya',
      ],
      <Pattern>[
        'not received', 'did not receive', 'nahi mila', 'not reflecting',
        'failed', 'pending', 'reverse', 'return', 'send again', 'dobara bhej',
        'resend',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'payment_screenshot_request',
    category: RiskCategory.payment,
    severity: Severity.medium,
    weight: 0.5,
    titleEn: 'Asking for a payment screenshot / UTR',
    titleHi: 'भुगतान का स्क्रीनशॉट / UTR मांगा जा रहा है',
    explainEn:
        'Screenshots are trivially edited. Genuine merchants reconcile payments '
        'from their own bank statement, not from a photo you send.',
    explainHi:
        'स्क्रीनशॉट आसानी से बदले जा सकते हैं। असली दुकानदार अपने बैंक स्टेटमेंट से '
        'भुगतान देखते हैं, आपकी फोटो से नहीं।',
    groups: <List<Pattern>>[
      <Pattern>[
        'send screenshot', 'share screenshot', 'payment screenshot',
        'send payment proof', 'screenshot of payment', 'transaction id',
        'utr number', 'send utr', 'payment proof',
      ],
      <Pattern>[
        'confirm', 'verify', 'order', 'delivery', 'refund', 'release', 'ship',
        'dispatch', 'approve',
      ],
    ],
  ),
];

// ---------------------------------------------------------------------------
// 3. Pressure: urgency, threats, secrecy, fake arrests.
// ---------------------------------------------------------------------------

const List<ScamRule> _pressureRules = <ScamRule>[
  DeclarativeRule(
    id: 'urgency_pressure',
    category: RiskCategory.urgency,
    severity: Severity.medium,
    weight: 0.42,
    titleEn: 'Manufactured urgency',
    titleHi: 'जानबूझकर बनाई गई जल्दबाज़ी',
    explainEn:
        'A deadline measured in hours exists to stop you from checking. Real '
        'institutions give you days and a reference number.',
    explainHi:
        '"कुछ घंटों में" जैसी समय-सीमा इसलिए होती है ताकि आप जाँच न कर सकें। असली '
        'संस्थाएँ कई दिन और एक संदर्भ नंबर देती हैं।',
    groups: <List<Pattern>>[
      <Pattern>[
        'immediately', 'urgent', 'within 24 hours', 'within 24 hrs',
        'within 2 hours', 'within 30 minutes', 'within 1 hour', 'last chance',
        'final notice', 'final warning', 'last date', 'today itself',
        'right now', 'act now', 'expires today', 'only few hours',
        'abhi', 'turant', 'jaldi', 'aaj hi', 'aaj tak', 'turant karein',
        'der mat karein', 'samay seema',
      ],
    ],
    minGroups: 1,
  ),
  DeclarativeRule(
    id: 'account_block_threat',
    category: RiskCategory.threat,
    severity: Severity.high,
    weight: 0.78,
    titleEn: 'Threat that your account will be blocked',
    titleHi: 'खाता बंद होने की धमकी',
    explainEn:
        'Banks freeze accounts through their own app or branch, never through a '
        'link in an SMS. "Account will be blocked today" is the oldest line in '
        'Indian SMS fraud.',
    explainHi:
        'बैंक खाता अपने ऐप या शाखा से बंद करते हैं, SMS के लिंक से नहीं। "आज खाता '
        'बंद हो जाएगा" भारतीय SMS ठगी की सबसे पुरानी लाइन है।',
    groups: <List<Pattern>>[
      <Pattern>[
        'account', 'a/c', 'khata', 'wallet', 'card', 'sim', 'connection',
      ],
      <Pattern>[
        'will be blocked', 'blocked', 'suspended', 'deactivated', 'frozen',
        'freeze', 'restricted', 'closed', 'band ho jayega', 'band ho jayega',
        'band kar diya', 'block ho jayega', 'deactivate ho', 'nilambit',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'kyc_expiry',
    category: RiskCategory.threat,
    severity: Severity.critical,
    weight: 0.82,
    titleEn: 'Fake KYC expiry notice',
    titleHi: 'नकली KYC एक्सपायरी नोटिस',
    explainEn:
        'KYC never expires via an SMS link. Banks update KYC in-app, at an ATM '
        'or in a branch. The "KYC expired, account blocked" SMS is the highest '
        'volume fraud message in India.',
    explainHi:
        'KYC कभी SMS लिंक से एक्सपायर नहीं होती। बैंक ऐप, ATM या शाखा में अपडेट '
        'करते हैं। "KYC एक्सपायर, खाता बंद" भारत का सबसे ज़्यादा भेजा जाने वाला '
        'ठगी संदेश है।',
    groups: <List<Pattern>>[
      <Pattern>['kyc', 'केवाईसी', 'know your customer', 're-kyc', 'ekyc'],
      <Pattern>[
        'expire', 'expiry', 'expired', 'block', 'suspend', 'deactivate',
        'band', 'update', 'verify', 'pending', 'complete', 'last date',
        'valid till',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'secrecy_pressure',
    category: RiskCategory.secrecy,
    severity: Severity.high,
    weight: 0.8,
    titleEn: 'Told to keep the conversation secret',
    titleHi: 'बात किसी को न बताने को कहा गया',
    explainEn:
        'Isolation is the core of every "digital arrest" fraud. No police officer, '
        'bank or government officer will ever ask you to hide a call from your '
        'family.',
    explainHi:
        '"डिजिटल अरेस्ट" ठगी की जड़ यही है — आपको अकेला करना। कोई पुलिसकर्मी, बैंक '
        'या सरकारी अधिकारी कभी नहीं कहेगा कि परिवार से बात छिपाएं।',
    groups: <List<Pattern>>[
      <Pattern>[
        'do not tell', "don't tell", 'do not inform', 'without informing',
        'kisi ko na bataye', 'kisi ko mat batana', 'kisi se na batao',
        'keep this confidential', 'strictly confidential', 'this is secret',
        'stay on the call', 'stay on call', 'do not disconnect',
        'disconnect mat karo', 'call par rahiye', 'phone mat rakho',
        'do not hang up', 'do not discuss', 'tell no one', 'between us',
      ],
    ],
    minGroups: 1,
  ),
  DeclarativeRule(
    id: 'digital_arrest',
    category: RiskCategory.impersonation,
    severity: Severity.critical,
    weight: 0.93,
    titleEn: 'Fake police / CBI "digital arrest" script',
    titleHi: 'नकली पुलिस / CBI "डिजिटल अरेस्ट" स्क्रिप्ट',
    explainEn:
        'There is no such thing as a digital arrest in Indian law. Police never '
        'conduct investigations over WhatsApp video, never demand money to close '
        'a case, and never ask you to stay on a call.',
    explainHi:
        'भारतीय कानून में "डिजिटल अरेस्ट" जैसा कुछ नहीं है। पुलिस WhatsApp वीडियो पर '
        'जाँच नहीं करती, केस बंद करने के पैसे नहीं मांगती और कॉल पर बने रहने को '
        'नहीं कहती।',
    groups: <List<Pattern>>[
      <Pattern>[
        'digital arrest', 'cbi', 'narcotics', 'money laundering', 'aadhaar misuse',
        'enforcement directorate', 'ed officer', 'customs department',
        'illegal items', 'drug parcel', 'warrant', 'non-bailable',
        'arrest warrant', 'fir registered', 'supreme court notice',
      ],
      <Pattern>[
        'video call', 'join the call', 'skype', 'stay on', 'do not tell',
        'pay fine', 'penalty', 'clearance amount', 'verify your identity',
        'case number', 'officer', 'station', 'notice',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'legal_threat',
    category: RiskCategory.threat,
    severity: Severity.medium,
    weight: 0.62,
    titleEn: 'Legal action threatened to force a payment',
    titleHi: 'भुगतान करवाने के लिए कानूनी कार्रवाई की धमकी',
    explainEn:
        'Recovery threats sent by SMS or WhatsApp are not court orders. Verify '
        'any real notice on the official court or bank website.',
    explainHi:
        'SMS या WhatsApp पर भेजी गई वसूली की धमकी अदालत का आदेश नहीं होती। असली '
        'नोटिस अदालत या बैंक की आधिकारिक वेबसाइट पर जाँचें।',
    groups: <List<Pattern>>[
      <Pattern>[
        'legal action', 'police complaint', 'court case', 'will be arrested',
        'recovery agent', 'loan recovery', 'legal notice', 'fir will be',
        'case will be filed', 'warrant issued', 'cyber cell complaint',
      ],
    ],
    minGroups: 1,
  ),
  DeclarativeRule(
    id: 'callback_pressure',
    category: RiskCategory.urgency,
    severity: Severity.medium,
    weight: 0.5,
    titleEn: 'Pushed to call a number in the message',
    titleHi: 'संदेश वाले नंबर पर कॉल करने का दबाव',
    explainEn:
        'The number in a scam SMS belongs to the scammer. Look up the real number '
        'on the back of your card or the official app instead.',
    explainHi:
        'ठगी वाले SMS का नंबर ठग का होता है। असली नंबर कार्ड के पीछे या आधिकारिक ऐप '
        'में देखें।',
    groups: <List<Pattern>>[
      <Pattern>[
        'call this number', 'call on this', 'call immediately',
        'contact immediately', 'call back', 'whatsapp me', 'whatsapp on',
        'reply now', 'contact on whatsapp', 'dial this', 'is number par call',
      ],
      <Pattern>[
        'urgent', 'immediately', 'block', 'kyc', 'refund', 'prize', 'verify',
        'today', 'last', 'turant', 'abhi',
      ],
    ],
  ),
];

// ---------------------------------------------------------------------------
// 4. Impersonation of institutions.
// ---------------------------------------------------------------------------

const List<ScamRule> _impersonationRules = <ScamRule>[
  DeclarativeRule(
    id: 'authority_impersonation',
    category: RiskCategory.impersonation,
    severity: Severity.high,
    weight: 0.7,
    titleEn: 'Claiming to be a government body',
    titleHi: 'सरकारी विभाग होने का दावा',
    explainEn:
        'RBI, Income Tax, GST, EPFO, UIDAI and PM-Kisan never send payment links '
        'over SMS. Every real government site ends in gov.in.',
    explainHi:
        'RBI, आयकर, GST, EPFO, UIDAI और PM-Kisan कभी SMS पर भुगतान लिंक नहीं भेजते। '
        'हर असली सरकारी साइट gov.in पर खत्म होती है।',
    groups: <List<Pattern>>[
      <Pattern>[
        'rbi', 'reserve bank of india', 'income tax department', 'gst department',
        'epfo', 'uidai', 'pm kisan', 'pm-kisan', 'npci', 'irdai', 'sebi',
        'ministry of', 'govt of india', 'government of india', 'trai',
        'aadhaar card', 'pan card department',
      ],
      <Pattern>[
        'notice', 'penalty', 'refund', 'verify', 'update', 'claim', 'payment',
        'block', 'due', 'compliance', 'action', 'link', 'click', 'submit',
        'last date', 'benefit', 'installment',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'bank_impersonation',
    category: RiskCategory.impersonation,
    severity: Severity.high,
    weight: 0.68,
    titleEn: 'Bank branding used in an unofficial message',
    titleHi: 'अनौपचारिक संदेश में बैंक का नाम',
    explainEn:
        'Banks send transactional SMS from registered sender IDs (like VM-SBIINB) '
        'and never include a login link. A bank name plus a link in a personal '
        'message is impersonation.',
    explainHi:
        'बैंक अपने संदेश रजिस्टर्ड सेंडर ID (जैसे VM-SBIINB) से भेजते हैं और कभी '
        'लॉगिन लिंक नहीं देते। निजी संदेश में बैंक का नाम और लिंक = नकल।',
    groups: <List<Pattern>>[
      <Pattern>[
        'sbi', 'state bank', 'hdfc', 'icici', 'axis bank', 'kotak', 'pnb',
        'bank of baroda', 'canara', 'union bank', 'yes bank', 'idfc',
        'indusind', 'paytm bank', 'airtel bank', 'jio bank',
      ],
      <Pattern>[
        'dear customer', 'dear user', 'dear sir/madam', 'valued customer',
        'account holder', 'your account', 'aapka account', 'priya grahak',
      ],
      <Pattern>['link', 'click', 'login', 'update', 'verify', 'kyc', 'http'],
    ],
    minGroups: 3,
  ),
];

// ---------------------------------------------------------------------------
// 5. Lures: prize, job, investment, loan, cashback.
// ---------------------------------------------------------------------------

const List<ScamRule> _lureRules = <ScamRule>[
  DeclarativeRule(
    id: 'prize_lottery',
    category: RiskCategory.prize,
    severity: Severity.high,
    weight: 0.76,
    titleEn: 'You have "won" something you never entered for',
    titleHi: 'जिसमें भाग नहीं लिया, उसका "इनाम"',
    explainEn:
        'You cannot win a lottery you never bought a ticket for. Any prize that '
        'needs a "processing fee", "tax" or "courier charge" first is a fee scam.',
    explainHi:
        'जिस लॉटरी का टिकट नहीं खरीदा, उसे जीता नहीं जा सकता। जो इनाम पहले '
        '"प्रोसेसिंग फीस", "टैक्स" या "कूरियर चार्ज" मांगे, वह फीस ठगी है।',
    groups: <List<Pattern>>[
      <Pattern>[
        'lottery', 'lucky draw', 'you have won', 'you won', 'congratulations',
        'winner', 'prize', 'scratch card', 'kbc', 'jeeta', 'inaam',
        'gift worth', 'jackpot', 'lucky winner', 'selected winner',
        'crorepati', 'bumper',
      ],
      <Pattern>[
        'claim', 'receive', 'send', 'pay', 'fee', 'processing fee', 'tax',
        'courier', 'contact', 'whatsapp', 'click', 'link', 'number',
        'registration', 'deposit',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'job_scam',
    category: RiskCategory.job,
    severity: Severity.medium,
    weight: 0.66,
    titleEn: '"Part-time job" that pays for liking things',
    titleHi: '"पार्ट टाइम नौकरी" जो लाइक करने पर पैसे देती है',
    explainEn:
        'Task-based "jobs" on Telegram pay small amounts first, then ask you to '
        'deposit money for a bigger task and vanish. No real employer charges you '
        'to work.',
    explainHi:
        'Telegram पर "टास्क जॉब" पहले थोड़ा पैसा देती है, फिर बड़े टास्क के लिए '
        '"डिपॉजिट" मांगती है और गायब हो जाती है। असली नियोक्ता काम के पैसे नहीं '
        'लेता।',
    groups: <List<Pattern>>[
      <Pattern>[
        'part time job', 'part-time job', 'work from home', 'daily income',
        'earn daily', 'earn per day', 'typing job', 'copy paste job',
        'telegram', 'no experience', 'simple task', 'like and earn',
        'review job', 'hotel booking job', 'data entry', 'form filling',
        'ad posting', 'youtube like',
      ],
      <Pattern>[
        'earn', 'income', 'salary', 'daily', '₹', 'rs.', 'paid', 'payment',
        'deposit', 'registration fee', 'join', 'per day', 'per task',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'investment_scam',
    category: RiskCategory.investment,
    severity: Severity.high,
    weight: 0.74,
    titleEn: 'Guaranteed returns on an "investment"',
    titleHi: '"निवेश" पर गारंटीड रिटर्न',
    explainEn:
        'No regulated investment guarantees a fixed daily profit. SEBI-registered '
        'advisors are listed on sebi.gov.in — anyone on WhatsApp is not one.',
    explainHi:
        'कोई भी विनियमित निवेश रोज़ का तय मुनाफ़ा गारंटी नहीं देता। SEBI-पंजीकृत '
        'सलाहकार sebi.gov.in पर होते हैं — WhatsApp वाला कोई नहीं।',
    groups: <List<Pattern>>[
      <Pattern>[
        'guaranteed return', 'guaranteed profit', 'double your money',
        'double in', 'trading signal', 'sure shot', 'no risk', 'risk free',
        'fixed return', 'daily profit', 'forex', 'crypto', 'ipo allotment',
        'assured return', 'nifty tip', 'bank nifty', 'intraday tip',
      ],
      <Pattern>[
        'invest', 'profit', 'return', 'earn', 'deposit', 'minimum', 'join',
        'group', 'whatsapp', 'telegram', 'link', 'capital', 'withdraw',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'loan_app_scam',
    category: RiskCategory.loan,
    severity: Severity.medium,
    weight: 0.6,
    titleEn: 'Instant loan offer with no paperwork',
    titleHi: 'बिना कागज़ात वाला तुरंत लोन ऑफर',
    explainEn:
        'Predatory loan apps harvest your contacts and photos, then blackmail you. '
        'Check the lender on the RBI list of registered NBFCs before installing.',
    explainHi:
        'शोषक लोन ऐप आपके कॉन्टैक्ट और फोटो चुराकर ब्लैकमेल करते हैं। इंस्टॉल से पहले '
        'RBI की पंजीकृत NBFC सूची में जाँचें।',
    groups: <List<Pattern>>[
      <Pattern>[
        'instant loan', 'loan approved', 'pre-approved', 'no documents',
        'without documents', '5 minute', 'cibil', 'loan offer', 'personal loan',
        'loan in 10 minutes', 'zero interest loan',
      ],
      <Pattern>[
        'apply', 'click', 'download', 'app', 'approve', 'disburse',
        'processing fee', 'aadhaar', 'pan', 'link',
      ],
    ],
  ),
  DeclarativeRule(
    id: 'cashback_lure',
    category: RiskCategory.prize,
    severity: Severity.medium,
    weight: 0.58,
    titleEn: 'Cashback / reward that needs your details first',
    titleHi: 'कैशबैक / रिवॉर्ड जिसके लिए पहले जानकारी चाहिए',
    explainEn:
        'Real cashback lands in your account automatically. It never needs a '
        'link, a code from a stranger, or your card details.',
    explainHi:
        'असली कैशबैक अपने आप खाते में आता है। उसके लिए लिंक, किसी अजनबी का कोड या '
        'कार्ड डिटेल नहीं चाहिए।',
    groups: <List<Pattern>>[
      <Pattern>[
        'cashback', 'refund', 'reward points', 'free recharge', 'free data',
        'free gift', 'free iphone', 'free laptop', 'free mobile',
        'scratch card', 'spin and win', 'spin the wheel',
      ],
      <Pattern>[
        'claim', 'click', 'link', 'code', 'apply', 'receive', 'get',
        'confirm', 'verify', 'limited',
      ],
    ],
  ),
];

// ---------------------------------------------------------------------------
// 6. Links and domains.
// ---------------------------------------------------------------------------

final List<ScamRule> _linkRules = <ScamRule>[
  const CustomRule(
    id: 'suspicious_link',
    category: RiskCategory.link,
    severity: Severity.high,
    weight: 0.75,
    titleEn: 'A link with red flags',
    titleHi: 'संदिग्ध लिंक',
    explainEn:
        'Shortened links hide where they really go, free TLDs (.xyz, .top, .tk) '
        'are used almost exclusively by fraud, and no Indian bank sends an APK or '
        'an http:// login page.',
    explainHi:
        'छोटे किए गए लिंक छिपाते हैं कि वे कहाँ जाते हैं, मुफ्त TLD (.xyz, .top, .tk) '
        'लगभग सिर्फ ठगी में उपयोग होते हैं, और कोई भारतीय बैंक APK या http:// '
        'लॉगिन पेज नहीं भेजता।',
    detect: _detectSuspiciousLinks,
  ),
  const CustomRule(
    id: 'lookalike_domain',
    category: RiskCategory.link,
    severity: Severity.critical,
    weight: 0.88,
    titleEn: 'Domain imitating a real brand',
    titleHi: 'असली ब्रांड की नकल करने वाला डोमेन',
    explainEn:
        'The domain is one or two characters away from a real bank or government '
        'site. Check the spelling letter by letter before you log in anywhere.',
    explainHi:
        'यह डोमेन असली बैंक या सरकारी साइट से एक-दो अक्षर ही अलग है। कहीं भी लॉगिन '
        'करने से पहले हर अक्षर जाँचें।',
    detect: _detectLookalikeDomains,
  ),
  const CustomRule(
    id: 'brand_subdomain_trick',
    category: RiskCategory.link,
    severity: Severity.critical,
    weight: 0.85,
    titleEn: 'Brand name hidden in a subdomain',
    titleHi: 'सबडोमेन में छिपाया गया ब्रांड नाम',
    explainEn:
        'In `sbi.secure-login.xyz` the real site is `secure-login.xyz`, not SBI. '
        'Read a URL right to left: the last two parts are the actual owner.',
    explainHi:
        '`sbi.secure-login.xyz` में असली साइट `secure-login.xyz` है, SBI नहीं। URL को '
        'दाएँ से पढ़ें: आखिरी दो हिस्से ही असली मालिक हैं।',
    detect: _detectBrandSubdomain,
  ),
];

// ---------------------------------------------------------------------------
// 7. UPI address quality.
// ---------------------------------------------------------------------------

final List<ScamRule> _upiRules = <ScamRule>[
  const CustomRule(
    id: 'upi_handle_unknown',
    category: RiskCategory.upi,
    severity: Severity.high,
    weight: 0.68,
    titleEn: 'UPI handle is not issued by a known bank',
    titleHi: 'UPI हैंडल किसी जाने-माने बैंक का नहीं है',
    explainEn:
        'The part after "@" is chosen by the bank, not the user. A handle that no '
        'regulated PSP issues is a strong sign of a mule account.',
    explainHi:
        '"@" के बाद वाला हिस्सा बैंक तय करता है, यूज़र नहीं। जो हैंडल किसी '
        'विनियमित PSP का नहीं, वह म्यूल खाते का संकेत है।',
    detect: _detectUnknownUpiHandles,
  ),
  const CustomRule(
    id: 'upi_handle_typosquat',
    category: RiskCategory.upi,
    severity: Severity.critical,
    weight: 0.9,
    titleEn: 'UPI handle is a typo of a real bank',
    titleHi: 'UPI हैंडल असली बैंक का गलत-वर्तनी रूप है',
    explainEn:
        'Handles like `okhdfcbnak` or `paytmm` are registered by fraudsters to '
        'mimic HDFC and Paytm. Your money goes to a stranger, and UPI transfers '
        'cannot be reversed.',
    explainHi:
        '`okhdfcbnak` या `paytmm` जैसे हैंडल ठग HDFC और Paytm की नकल के लिए बनाते हैं। '
        'पैसा अजनबी के पास जाता है, और UPI ट्रांसफर वापस नहीं होते।',
    detect: _detectUpiTyposquats,
  ),
  CustomRule(
    id: 'upi_link_present',
    category: RiskCategory.upi,
    severity: Severity.medium,
    weight: 0.45,
    titleEn: 'Message contains a ready-to-pay UPI link',
    titleHi: 'संदेश में सीधे भुगतान वाला UPI लिंक है',
    explainEn:
        'A pre-built UPI link can carry a fixed amount and a payee you did not '
        'choose. Always pay by typing the VPA or scanning a QR you can see is the '
        'merchant\u2019s own.',
    explainHi:
        'तैयार UPI लिंक में तय रकम और ऐसा पाने वाला हो सकता है जिसे आपने चुना ही नहीं। '
        'हमेशा VPA टाइप करके या दुकानदार का अपना QR देखकर भुगतान करें।',
    detect: (ScanContext context) {
      if (!context.containsUpiLink) return const <String>[];
      return <String>['upi://'];
    },
  ),
];

// ---------------------------------------------------------------------------
// 8. Message shape.
// ---------------------------------------------------------------------------

final List<ScamRule> _formatRules = <ScamRule>[
  CustomRule(
    id: 'shouting_format',
    category: RiskCategory.format,
    severity: Severity.low,
    weight: 0.3,
    titleEn: 'Shouting: caps, emoji and exclamation marks',
    titleHi: 'चिल्लाता संदेश: बड़े अक्षर, इमोजी, विस्मयादिबोधक',
    explainEn:
        'Banks and government offices write in calm, plain language. Walls of caps '
        'and emoji exist to create panic.',
    explainHi:
        'बैंक और सरकारी दफ्तर शांत, सादी भाषा में लिखते हैं। बड़े अक्षर और इमोजी '
        'घबराहट पैदा करने के लिए होते हैं।',
    detect: (ScanContext context) {
      final List<String> reasons = <String>[];
      if (context.capsRatio > 0.6 && context.wordCount >= 5) {
        reasons.add('ALL CAPS');
      }
      if (context.emojiCount >= 5) {
        reasons.add('${context.emojiCount} emoji');
      }
      if (context.exclamationCount >= 4) {
        reasons.add('${context.exclamationCount} exclamation marks');
      }
      return reasons;
    },
  ),
  CustomRule(
    id: 'homoglyph_obfuscation',
    category: RiskCategory.format,
    severity: Severity.medium,
    weight: 0.55,
    titleEn: 'Foreign look-alike letters used to dodge filters',
    titleHi: 'फिल्टर से बचने के लिए विदेशी मिलते-जुलते अक्षर',
    explainEn:
        'The message contains Cyrillic or Greek characters that look like Latin '
        'letters. This is done deliberately so spam filters do not recognise the '
        'brand name.',
    explainHi:
        'संदेश में सिरिलिक या ग्रीक अक्षर हैं जो अंग्रेज़ी अक्षरों जैसे दिखते हैं। यह '
        'जानबूझकर किया जाता है ताकि स्पैम फिल्टर ब्रांड का नाम न पहचानें।',
    detect: (ScanContext context) {
      final RegExpMatch? m = RegExp(r'[\u0400-\u04FF\u0370-\u03FF]+')
          .firstMatch(context.raw);
      if (m == null) return const <String>[];
      return <String>[m.group(0)!];
    },
  ),
  CustomRule(
    id: 'too_many_numbers',
    category: RiskCategory.format,
    severity: Severity.low,
    weight: 0.28,
    titleEn: 'Several phone numbers crammed into one message',
    titleHi: 'एक संदेश में कई फोन नंबर',
    explainEn:
        'Fraud messages rotate contact numbers so that when one is blocked the '
        'others still work.',
    explainHi:
        'ठगी संदेशों में कई नंबर होते हैं ताकि एक ब्लॉक होने पर भी बाकी चलते रहें।',
    detect: (ScanContext context) =>
        context.mobileNumbers.length >= 2 ? context.mobileNumbers : const <String>[],
  ),
];

// ---------------------------------------------------------------------------
// 9. Whitelist: an official domain in the message lowers the score.
// ---------------------------------------------------------------------------

final ScamRule _trustedDomainRule = CustomRule(
  id: 'trusted_official_domain',
  category: RiskCategory.link,
  severity: Severity.info,
  weight: -0.55,
  titleEn: 'Link points to a verified official domain',
  titleHi: 'लिंक सत्यापित आधिकारिक डोमेन पर जाता है',
  explainEn:
        'The domain in this message exactly matches a known official bank or '
        'government site. That is a good sign, but still open the app yourself '
        'rather than tapping a link.',
  explainHi:
        'इस संदेश का डोमेन किसी जाने-माने आधिकारिक बैंक या सरकारी साइट से पूरी तरह '
        'मेल खाता है। यह अच्छा संकेत है, फिर भी लिंक दबाने के बजाय ऐप खुद खोलें।',
  detect: (ScanContext context) {
    final List<String> hits = <String>[];
    for (final String link in context.links) {
      final String host = _hostOf(link);
      if (host.isEmpty) continue;
      if (KnownDomains.official.contains(host)) hits.add(host);
      if (KnownDomains.official.contains(_registrable(host))) {
        hits.add(_registrable(host));
      }
    }
    return hits.toSet().toList(growable: false);
  },
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Detects a bank's own "never share your OTP" advisory so we do not flag it.
bool _isSafetyAdvisory(ScanContext context) {
  return context.hasAny(const <String>[
    'never share', 'do not share', 'dont share', "don't share",
    'never disclose', 'do not disclose', 'kabhi na bataye', 'kabhi share na',
    'never ask', 'we never ask', 'will never ask', 'beware of', 'avoid sharing',
    'do not reveal', 'keep it secret from others',
  ]);
}

/// Extracts the host from a link, dropping scheme, path, port and userinfo.
String _hostOf(String link) {
  String value = link.trim().toLowerCase();
  final int schemeEnd = value.indexOf('://');
  if (schemeEnd != -1) value = value.substring(schemeEnd + 3);
  if (value.startsWith('www.')) value = value.substring(4);
  final int slash = value.indexOf('/');
  if (slash != -1) value = value.substring(0, slash);
  final int at = value.lastIndexOf('@');
  if (at != -1) value = value.substring(at + 1);
  final int colon = value.indexOf(':');
  if (colon != -1) value = value.substring(0, colon);
  final int question = value.indexOf('?');
  if (question != -1) value = value.substring(0, question);
  return value.trim();
}

/// Keeps the last two labels (`a.b.co.in` → `co.in`, `x.y.com` → `y.com`).
String _registrable(String host) {
  final List<String> parts = host.split('.').where((String p) => p.isNotEmpty).toList();
  if (parts.length <= 2) return host;
  final String lastTwo = '${parts[parts.length - 2]}.${parts.last}';
  // Handle common two-level public suffixes used in India.
  const Set<String> secondLevel = <String>{
    'co.in', 'org.in', 'net.in', 'gov.in', 'ac.in', 'edu.in', 'nic.in',
    'co.uk', 'org.uk', 'gov.uk', 'ac.uk',
  };
  if (secondLevel.contains(lastTwo) && parts.length >= 3) {
    return '${parts[parts.length - 3]}.$lastTwo';
  }
  return lastTwo;
}

/// True when the host is a bare IPv4 address.
bool _isIpHost(String host) =>
    RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host);

List<String> _detectSuspiciousLinks(ScanContext context) {
  final List<String> hits = <String>[];
  for (final String link in context.links) {
    final String host = _hostOf(link);
    if (host.isEmpty) continue;

    if (KnownDomains.shorteners.contains(host)) {
      hits.add('$host (shortened link)');
      continue;
    }
    if (_isIpHost(host)) {
      hits.add('$host (raw IP address)');
      continue;
    }
    if (link.startsWith('http://')) {
      hits.add('$host (no HTTPS)');
    }
    if (link.contains('.apk')) {
      hits.add('$host (.apk download)');
    }
    if (host.startsWith('xn--') || link.contains('.xn--')) {
      hits.add('$host (punycode lookalike)');
    }
    final String tld = host.split('.').last;
    if (KnownDomains.disposableTlds.contains(tld)) {
      hits.add('$host (.$tld domain)');
    }
    if (link.contains('%2f') || link.contains('%2e')) {
      hits.add('$host (encoded URL)');
    }
    // A "gov" or bank word bolted onto a non-gov domain.
    if ((host.contains('gov') || host.contains('bank') || host.contains('kyc')) &&
        !host.endsWith('gov.in') &&
        !host.endsWith('nic.in') &&
        !KnownDomains.official.contains(_registrable(host))) {
      hits.add('$host (fake authority domain)');
    }
  }
  return hits.toSet().toList(growable: false);
}

List<String> _detectLookalikeDomains(ScanContext context) {
  final List<String> hits = <String>[];
  for (final String link in context.links) {
    final String host = _hostOf(link);
    if (host.isEmpty) continue;
    final String registrable = _registrable(host);
    if (KnownDomains.official.contains(registrable)) continue;

    final List<String> hostLabels = registrable.split('.');
    if (hostLabels.length < 2) continue;
    final String label = hostLabels[hostLabels.length - 2];

    for (final String brand in KnownDomains.brandLabels) {
      if (label == brand) continue;
      final double score = handleSimilarity(label, brand);
      if (score >= 0.82 && score < 1.0) {
        hits.add('$registrable ≈ $brand');
        break;
      }
    }
  }
  return hits.toSet().toList(growable: false);
}

List<String> _detectBrandSubdomain(ScanContext context) {
  final List<String> hits = <String>[];
  for (final String link in context.links) {
    final String host = _hostOf(link);
    if (host.isEmpty) continue;
    final String registrable = _registrable(host);
    if (KnownDomains.official.contains(registrable)) continue;

    final String prefix = host.endsWith(registrable)
        ? host.substring(0, host.length - registrable.length)
        : '';
    if (prefix.isEmpty) continue;

    for (final String brand in KnownDomains.brandLabels) {
      if (prefix.contains(brand)) {
        hits.add('$host → owner is $registrable');
        break;
      }
    }
  }
  return hits.toSet().toList(growable: false);
}

List<String> _detectUnknownUpiHandles(ScanContext context) {
  final List<String> hits = <String>[];
  for (final String address in context.upiAddresses) {
    final int at = address.indexOf('@');
    if (at <= 0) continue;
    final String handle = address.substring(at + 1);
    if (PspRegistry.isKnown(handle)) continue;
    if (PspRegistry.lookalikes(handle).isNotEmpty) continue; // handled elsewhere
    hits.add(address);
  }
  return hits;
}

List<String> _detectUpiTyposquats(ScanContext context) {
  final List<String> hits = <String>[];
  for (final String address in context.upiAddresses) {
    final int at = address.indexOf('@');
    if (at <= 0) continue;
    final String handle = address.substring(at + 1);
    if (PspRegistry.isKnown(handle)) continue;
    final List<String> near = PspRegistry.lookalikes(handle);
    if (near.isEmpty) continue;
    hits.add('$address ≈ @${near.first}');
  }
  return hits.toSet().toList(growable: false);
}
