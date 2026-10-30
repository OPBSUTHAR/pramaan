/// Every user-facing string in Pramaan, in English and Hindi.
///
/// Kept as a plain map instead of generated ARB files so the whole app stays
/// buildable with `flutter pub get` alone — no code generation step, no
/// network, nothing to regenerate before a release build.
abstract final class AppStrings {
  static const Map<String, String> en = {
    'app.name': 'Pramaan',
    'app.tagline': 'Proof before you pay.',
    'app.subtitle': 'Offline UPI scam shield',
    'nav.scan': 'Scan',
    'nav.upi': 'UPI',
    'nav.learn': 'Learn',
    'nav.emergency': 'Help',
    'nav.history': 'History',
    // Scan
    'scan.hero.title': 'Check before you pay',
    'scan.hero.body':
        'Paste any suspicious SMS, WhatsApp message or UPI request. Every check runs on this phone — nothing is uploaded, ever.',
    'scan.input.hint': 'Paste the message here…',
    'scan.action.scan': 'Check this message',
    'scan.action.paste': 'Paste',
    'scan.action.clear': 'Clear',
    'scan.action.example': 'Try a real scam',
    'scan.badge.offline': '100% on-device',
    'scan.badge.airplane': 'Works in airplane mode',
    'scan.stats.rules': 'fraud rules',
    'scan.stats.patterns': 'scam patterns',
    'scan.stats.languages': 'Hindi + English',
    'scan.recent': 'Recent checks',
    'scan.recent.empty':
        'Your checks will appear here. Nothing leaves this phone.',
    'scan.dna.title': 'Scam DNA',
    'scan.dna.body':
        'Pramaan fingerprints how known scams are worded. A reworded fraud still matches.',
    'scan.tooShort': 'Add a little more text to check.',
    'scan.clipboardEmpty': 'Clipboard is empty.',
    'scan.pasted': 'Pasted from clipboard.',
    // Result
    'result.title': 'Verdict',
    'result.score': 'Risk score',
    'result.of100': 'out of 100',
    'result.why': 'Why this was flagged',
    'result.dna': 'Scam DNA match',
    'result.dna.family': 'Pattern family',
    'result.confidence': 'confidence',
    'result.upi': 'UPI details found',
    'result.clean': 'No fraud signals found',
    'result.clean.body':
        'Still stay careful. No genuine bank ever asks for an OTP, UPI PIN, or screen access.',
    'result.copy': 'Copy verdict',
    'result.copied': 'Verdict copied',
    'result.newScan': 'Check another',
    'result.share': 'Share warning',
    'result.evidence': 'Matched text',
    'result.signals': 'signals',
    'result.templateSource': 'Compared against the full scam-script library',
    // UPI
    'upi.title': 'UPI inspector',
    'upi.body':
        'Paste a UPI link, QR payload or VPA. Pramaan decodes it offline and shows exactly what you are about to approve.',
    'upi.hint': 'upi://pay?pa=… or name@bank',
    'upi.action': 'Inspect',
    'upi.operation': 'Operation',
    'upi.payee': 'Payee',
    'upi.payeeName': 'Payee name',
    'upi.amount': 'Amount',
    'upi.note': 'Note',
    'upi.merchant': 'Merchant code',
    'upi.ref': 'Reference',
    'upi.warnings': 'Warnings',
    'upi.noWarnings':
        'No structural red flags. That does not make the payee trustworthy — money sent on UPI cannot be pulled back.',
    'upi.notUpi': 'That does not look like a UPI link or address.',
    'upi.empty': 'Paste a UPI link or VPA first.',
    'upi.handle.known': 'Registered UPI handle',
    'upi.handle.unknown': 'Unrecognised handle',
    'upi.handle.typosquat': 'Look-alike handle',
    'upi.sample': 'Try a sample',
    // Learn
    'learn.title': 'Scam library',
    'learn.body':
        'Every pattern is stored inside the app. Read once, recognise forever.',
    'learn.search': 'Search scams',
    'learn.redFlags': 'Red flags',
    'learn.example': 'Real message',
    'learn.action': 'What to do',
    'learn.empty': 'No pattern matches that search.',
    'learn.all': 'All',
    // Emergency
    'emergency.title': 'Money already gone?',
    'emergency.body':
        'The first 30 minutes decide whether you get it back. Do these in order.',
    'emergency.helpline': 'National cyber fraud helpline',
    'emergency.call': 'Call 1930',
    'emergency.portal': 'cybercrime.gov.in',
    'emergency.step1.title': 'Call 1930 now',
    'emergency.step1.body':
        'Report the transaction ID. The sooner it is logged, the higher the chance the receiving account gets frozen.',
    'emergency.step2.title': 'Ask your bank to freeze',
    'emergency.step2.body':
        "Call your bank's fraud line and ask them to freeze the beneficiary account — not just your card.",
    'emergency.step3.title': 'File on the portal',
    'emergency.step3.body':
        'cybercrime.gov.in → Report Financial Fraud. Keep the acknowledgement number.',
    'emergency.step4.title': 'Secure your accounts',
    'emergency.step4.body':
        'Change your UPI PIN and banking passwords from a different device. Uninstall any screen-sharing app you were asked to install.',
    'emergency.step5.title': "Never pay a 'recovery agent'",
    'emergency.step5.body':
        'Anyone who promises to get your money back for a fee is running the second half of the same scam.',
    'emergency.remember': 'Remember',
    'emergency.tip1':
        'A bank will never call and ask for your UPI PIN or OTP. Not once.',
    'emergency.tip2':
        'Receiving money never needs a PIN. If you are asked for one, it is a payment.',
    'emergency.tip3':
        'No government agency arrests people over a video call.',
    'emergency.tip4':
        'Screenshot and save the message before blocking the sender.',
    'emergency.copy': 'Copy checklist',
    'emergency.copied': 'Checklist copied',
    // History
    'history.title': 'Check history',
    'history.body':
        'Stored only on this phone. Deleting the app deletes it.',
    'history.clear': 'Clear all',
    'history.clear.confirm': 'Delete every saved check?',
    'history.empty': 'Nothing saved yet.',
    // Common
    'common.cancel': 'Cancel',
    'common.delete': 'Delete',
    'common.close': 'Close',
    'common.settings': 'Settings',
    'common.language': 'Language',
    'common.about': 'About Pramaan',
    'common.about.body':
        'Pramaan is free, open source, and has no servers. It cannot see your messages, your contacts, or your money.',
    'common.score': 'score',
    'common.now': 'now',
    'common.today': 'today',
    'common.yesterday': 'yesterday',
    'common.offline': 'Offline',
    'common.demo': 'Sample',
  };

  static const Map<String, String> hi = {
    'app.name': 'प्रमाण',
    'app.tagline': 'भुगतान से पहले प्रमाण।',
    'app.subtitle': 'ऑफ़लाइन UPI ठगी कवच',
    'nav.scan': 'जाँच',
    'nav.upi': 'UPI',
    'nav.learn': 'सीखें',
    'nav.emergency': 'मदद',
    'nav.history': 'इतिहास',
    // Scan
    'scan.hero.title': 'भेजने से पहले जाँचें',
    'scan.hero.body':
        'कोई भी संदिग्ध SMS, WhatsApp संदेश या UPI अनुरोध पेस्ट करें। हर जाँच इसी फ़ोन पर होती है — कुछ भी अपलोड नहीं होता।',
    'scan.input.hint': 'संदेश यहाँ पेस्ट करें…',
    'scan.action.scan': 'इस संदेश की जाँच करें',
    'scan.action.paste': 'पेस्ट करें',
    'scan.action.clear': 'साफ़ करें',
    'scan.action.example': 'असली ठगी आज़माएँ',
    'scan.badge.offline': '100% फ़ोन पर',
    'scan.badge.airplane': 'हवाई जहाज़ मोड में भी',
    'scan.stats.rules': 'ठगी नियम',
    'scan.stats.patterns': 'ठगी नमूने',
    'scan.stats.languages': 'हिंदी + अंग्रेज़ी',
    'scan.recent': 'हाल की जाँच',
    'scan.recent.empty':
        'आपकी जाँच यहाँ दिखेगी। कुछ भी इस फ़ोन से बाहर नहीं जाता।',
    'scan.dna.title': 'ठगी का डीएनए',
    'scan.dna.body':
        'प्रमाण जानी-पहचानी ठगी की शब्दावली की छाप लेता है। बदले शब्दों वाली ठगी भी पकड़ी जाती है।',
    'scan.tooShort': 'जाँच के लिए थोड़ा और पाठ जोड़ें।',
    'scan.clipboardEmpty': 'क्लिपबोर्ड खाली है।',
    'scan.pasted': 'क्लिपबोर्ड से पेस्ट हो गया।',
    // Result
    'result.title': 'निर्णय',
    'result.score': 'जोखिम स्कोर',
    'result.of100': '100 में से',
    'result.why': 'यह क्यों चिह्नित हुआ',
    'result.dna': 'ठगी डीएनए मिलान',
    'result.dna.family': 'नमूना परिवार',
    'result.confidence': 'विश्वास',
    'result.upi': 'मिले UPI विवरण',
    'result.clean': 'कोई ठगी संकेत नहीं मिला',
    'result.clean.body':
        'फिर भी सावधान रहें। कोई असली बैंक OTP, UPI पिन या स्क्रीन एक्सेस नहीं माँगता।',
    'result.copy': 'निर्णय कॉपी करें',
    'result.copied': 'निर्णय कॉपी हो गया',
    'result.newScan': 'दूसरा जाँचें',
    'result.share': 'चेतावनी भेजें',
    'result.evidence': 'मिला हुआ पाठ',
    'result.signals': 'संकेत',
    'result.templateSource': 'पूरी ठगी-स्क्रिप्ट लाइब्रेरी से तुलना',
    // UPI
    'upi.title': 'UPI जाँच',
    'upi.body':
        'UPI लिंक, QR पेलोड या VPA पेस्ट करें। प्रमाण इसे ऑफ़लाइन पढ़कर दिखाता है कि आप क्या मंज़ूर करने जा रहे हैं।',
    'upi.hint': 'upi://pay?pa=… या name@bank',
    'upi.action': 'जाँचें',
    'upi.operation': 'कार्य',
    'upi.payee': 'प्राप्तकर्ता',
    'upi.payeeName': 'प्राप्तकर्ता का नाम',
    'upi.amount': 'राशि',
    'upi.note': 'टिप्पणी',
    'upi.merchant': 'मर्चेंट कोड',
    'upi.ref': 'संदर्भ',
    'upi.warnings': 'चेतावनियाँ',
    'upi.noWarnings':
        'ढाँचे में कोई खतरा नहीं मिला। इसका मतलब यह नहीं कि प्राप्तकर्ता भरोसेमंद है — UPI से भेजा पैसा वापस नहीं आता।',
    'upi.notUpi': 'यह UPI लिंक या पता नहीं लगता।',
    'upi.empty': 'पहले UPI लिंक या VPA पेस्ट करें।',
    'upi.handle.known': 'पंजीकृत UPI हैंडल',
    'upi.handle.unknown': 'अनजाना हैंडल',
    'upi.handle.typosquat': 'मिलता-जुलता हैंडल',
    'upi.sample': 'नमूना आज़माएँ',
    // Learn
    'learn.title': 'ठगी पुस्तकालय',
    'learn.body':
        'हर नमूना ऐप के अंदर ही है। एक बार पढ़ें, हमेशा पहचानें।',
    'learn.search': 'ठगी खोजें',
    'learn.redFlags': 'खतरे के संकेत',
    'learn.example': 'असली संदेश',
    'learn.action': 'क्या करें',
    'learn.empty': 'इस खोज से कोई नमूना नहीं मिला।',
    'learn.all': 'सभी',
    // Emergency
    'emergency.title': 'पैसा चला गया?',
    'emergency.body':
        'पहले 30 मिनट तय करते हैं कि पैसा वापस मिलेगा या नहीं। ये क्रम से करें।',
    'emergency.helpline': 'राष्ट्रीय साइबर ठगी हेल्पलाइन',
    'emergency.call': '1930 पर कॉल करें',
    'emergency.portal': 'cybercrime.gov.in',
    'emergency.step1.title': 'अभी 1930 पर कॉल करें',
    'emergency.step1.body':
        'लेन-देन आईडी बताएँ। जितनी जल्दी शिकायत दर्ज होगी, उतनी जल्दी पैसा लेने वाला खाता फ्रीज़ हो सकता है।',
    'emergency.step2.title': 'बैंक से रोकें',
    'emergency.step2.body':
        'अपने बैंक की फ्रॉड लाइन पर कॉल करें और पैसा लेने वाला खाता फ्रीज़ करने को कहें — सिर्फ़ कार्ड नहीं।',
    'emergency.step3.title': 'पोर्टल पर शिकायत',
    'emergency.step3.body':
        'cybercrime.gov.in → Report Financial Fraud। पावती संख्या संभालकर रखें।',
    'emergency.step4.title': 'खाते सुरक्षित करें',
    'emergency.step4.body':
        'दूसरे डिवाइस से UPI पिन और बैंक पासवर्ड बदलें। जो स्क्रीन-शेयरिंग ऐप इंस्टॉल किया था उसे हटाएँ।',
    'emergency.step5.title': "'रिकवरी एजेंट' को पैसा न दें",
    'emergency.step5.body':
        'फीस लेकर पैसा वापस दिलाने का वादा करने वाले उसी ठगी का दूसरा हिस्सा हैं।',
    'emergency.remember': 'याद रखें',
    'emergency.tip1':
        'बैंक कभी फ़ोन करके UPI पिन या OTP नहीं माँगता। कभी नहीं।',
    'emergency.tip2':
        'पैसा लेने के लिए पिन कभी नहीं लगता। अगर पिन माँगा जाए, तो वह भुगतान है।',
    'emergency.tip3':
        'कोई सरकारी एजेंसी वीडियो कॉल पर गिरफ़्तार नहीं करती।',
    'emergency.tip4':
        'भेजने वाले को ब्लॉक करने से पहले संदेश का स्क्रीनशॉट रखें।',
    'emergency.copy': 'सूची कॉपी करें',
    'emergency.copied': 'सूची कॉपी हो गई',
    // History
    'history.title': 'जाँच इतिहास',
    'history.body':
        'सिर्फ़ इसी फ़ोन पर संग्रहीत। ऐप हटाने पर मिट जाएगा।',
    'history.clear': 'सब मिटाएँ',
    'history.clear.confirm': 'सभी सहेजी गई जाँच मिटाएँ?',
    'history.empty': 'अभी कुछ सहेजा नहीं गया।',
    // Common
    'common.cancel': 'रद्द करें',
    'common.delete': 'मिटाएँ',
    'common.close': 'बंद करें',
    'common.settings': 'सेटिंग्स',
    'common.language': 'भाषा',
    'common.about': 'प्रमाण के बारे में',
    'common.about.body':
        'प्रमाण मुफ़्त, ओपन सोर्स और बिना सर्वर है। यह आपके संदेश, संपर्क या पैसे नहीं देख सकता।',
    'common.score': 'स्कोर',
    'common.now': 'अभी',
    'common.today': 'आज',
    'common.yesterday': 'कल',
    'common.offline': 'ऑफ़लाइन',
    'common.demo': 'नमूना',
  };

  static String lookup(String key, {required bool hindi}) {
    final map = hindi ? hi : en;
    return map[key] ?? en[key] ?? key;
  }
}
