import 'package:flutter/foundation.dart';

/// The advice attached to each Scam DNA family. The scam examples themselves
/// come from the engine's built-in corpus, so this file only adds the human
/// part: what the pattern looks like and what to do about it.
@immutable
class FamilyGuide {
  const FamilyGuide({
    required this.family,
    required this.adviceEn,
    required this.adviceHi,
    required this.flagsEn,
    required this.flagsHi,
  });

  final String family;
  final String adviceEn;
  final String adviceHi;
  final List<String> flagsEn;
  final List<String> flagsHi;
}

const FamilyGuide _fallback = FamilyGuide(
  family: 'Other',
  adviceEn:
      'Slow down. Any message that pushes you to act within minutes, pay a '
      'small fee, install an app or share a code is designed to bypass your '
      'judgement. Verify through the official app or a number you looked up '
      'yourself.',
  adviceHi:
      'रुकिए। जो संदेश आपको मिनटों में कुछ करने, छोटी फीस देने, ऐप इंस्टॉल करने '
      'या कोड बताने पर मजबूर करे, वह आपकी सोच को बायपास करने के लिए है। असली ऐप '
      'या खुद खोजे गए नंबर से पुष्टि करें।',
  flagsEn: ['Urgency', 'A fee before a benefit', 'A link or app to install'],
  flagsHi: ['जल्दबाज़ी', 'फ़ायदे से पहले फीस', 'लिंक या ऐप इंस्टॉल करने को कहना'],
);

const Map<String, FamilyGuide> familyGuides = {
  'KYC / account block': FamilyGuide(
    family: 'KYC / account block',
    adviceEn:
        'Your bank never sends a link to update KYC. Open the bank\'s own app or '
        'visit the branch. A blocked account is reopened by the bank, not by a '
        'website.',
    adviceHi:
        'बैंक KYC अपडेट के लिए कभी लिंक नहीं भेजता। बैंक का अपना ऐप खोलें या '
        'शाखा जाएँ। बंद खाता बैंक खोलता है, कोई वेबसाइट नहीं।',
    flagsEn: [
      'The bank name sits inside a strange domain',
      'A deadline of "today" or "24 hours"',
      'Threat of permanent block',
      'Aadhaar, PAN, card or PIN asked on a web page',
    ],
    flagsHi: [
      'बैंक का नाम किसी अजीब डोमेन में',
      '"आज" या "24 घंटे" की समय-सीमा',
      'हमेशा के लिए बंद होने की धमकी',
      'वेब पेज पर आधार, पैन, कार्ड या पिन माँगना',
    ],
  ),
  'Collect request / QR': FamilyGuide(
    family: 'Collect request / QR',
    adviceEn:
        'Money coming in never needs approval. A collect request, or a QR you '
        'scan, can only take money out. Decline it and check the balance inside '
        'your own app.',
    adviceHi:
        'पैसा आने के लिए मंज़ूरी नहीं लगती। कलेक्ट अनुरोध या स्कैन किया QR सिर्फ़ '
        'पैसा लेता है। उसे अस्वीकार करें और अपने ऐप में बैलेंस देखें।',
    flagsEn: [
      '"Approve to receive"',
      'A QR sent so you can "receive" money',
      'Refund, cashback or prize attached',
      'The request already has an amount filled in',
    ],
    flagsHi: [
      '"पैसा लेने के लिए अप्रूव करें"',
      '"पैसा लेने" के लिए भेजा गया QR',
      'साथ में रिफ़ंड, कैशबैक या इनाम',
      'अनुरोध में राशि पहले से भरी हुई',
    ],
  ),
  'Digital arrest': FamilyGuide(
    family: 'Digital arrest',
    adviceEn:
        'No police, CBI, ED or customs officer arrests anyone over a video call. '
        'Hang up. If you are unsure, call 1930 yourself from a number you looked '
        'up.',
    adviceHi:
        'कोई पुलिस, CBI, ED या कस्टम अधिकारी वीडियो कॉल पर गिरफ़्तार नहीं करता। '
        'कॉल काटें। संदेह हो तो खुद खोजे गए नंबर से 1930 पर कॉल करें।',
    flagsEn: [
      'A uniform, badge and "case file" on camera',
      'Orders you to stay on the call',
      'Asks for a "verification transfer"',
      'Says a warrant is minutes away',
    ],
    flagsHi: [
      'कैमरे पर वर्दी, बैज और "केस फ़ाइल"',
      'कॉल पर बने रहने का आदेश',
      '"सत्यापन के लिए ट्रांसफर" माँगना',
      'मिनटों में वारंट की बात',
    ],
  ),
  'Job & task': FamilyGuide(
    family: 'Job & task',
    adviceEn:
        'Real employers pay you; they never ask you to pay first. Any "task" that '
        'needs a deposit, a recharge or a Telegram group is a scam.',
    adviceHi:
        'असली नियोक्ता आपको पैसा देते हैं, पहले पैसा नहीं माँगते। जिस "टास्क" में '
        'जमा, रिचार्ज या Telegram ग्रुप चाहिए, वह ठगी है।',
    flagsEn: [
      '"Earn ₹3,000 a day liking videos"',
      'Join a Telegram group to start',
      'Small payouts first, then a big deposit',
      '"Level upgrade" or "VIP task"',
    ],
    flagsHi: [
      '"वीडियो लाइक करके रोज़ ₹3,000 कमाएँ"',
      'शुरू करने के लिए Telegram ग्रुप जॉइन करना',
      'पहले छोटा भुगतान, फिर बड़ी जमा',
      '"लेवल अपग्रेड" या "VIP टास्क"',
    ],
  ),
  'Bill & subsidy': FamilyGuide(
    family: 'Bill & subsidy',
    adviceEn:
        'Pay bills only inside your bank app, the biller\'s own app, or BBPS. '
        'Subsidy money is credited automatically — nobody calls to "release" it.',
    adviceHi:
        'बिल सिर्फ़ अपने बैंक ऐप, बिलर के ऐप या BBPS से भरें। सब्सिडी अपने आप आती '
        'है — उसे "छुड़ाने" के लिए कोई फ़ोन नहीं करता।',
    flagsEn: [
      'Disconnection "tonight"',
      'A ₹10 reconnection fee',
      'AnyDesk or TeamViewer link',
      'PM-KISAN or LPG subsidy "released" through a link',
    ],
    flagsHi: [
      '"आज रात" कनेक्शन कटने की बात',
      '₹10 रीकनेक्शन फीस',
      'AnyDesk या TeamViewer लिंक',
      'लिंक से PM-KISAN या LPG सब्सिडी "छुड़ाना"',
    ],
  ),
  'Refund': FamilyGuide(
    family: 'Refund',
    adviceEn:
        'Refunds arrive on their own. Anyone who asks you to scan, approve or '
        'share a screen to get a refund is taking money, not returning it.',
    adviceHi:
        'रिफ़ंड अपने आप आता है। जो रिफ़ंड के लिए स्कैन, अप्रूव या स्क्रीन शेयर करने '
        'को कहे, वह पैसा ले रहा है, दे नहीं रहा।',
    flagsEn: [
      'Refund bigger than what you paid',
      '"Enter UPI PIN to receive"',
      'Screen sharing to "process" the refund',
      'An order ID you never placed',
    ],
    flagsHi: [
      'दिए गए पैसे से ज़्यादा रिफ़ंड',
      '"पैसा लेने के लिए UPI पिन डालें"',
      'रिफ़ंड "प्रोसेस" करने के लिए स्क्रीन शेयरिंग',
      'ऐसा ऑर्डर आईडी जो आपने कभी नहीं किया',
    ],
  ),
  'Courier & customs': FamilyGuide(
    family: 'Courier & customs',
    adviceEn:
        'Couriers do not collect customs duty over UPI links. Track a parcel only '
        'on the courier\'s official site, using the tracking number you already '
        'have.',
    adviceHi:
        'कूरियर UPI लिंक से कस्टम ड्यूटी नहीं लेते। पार्सल को सिर्फ़ कूरियर की असली '
        'साइट पर, अपने ट्रैकिंग नंबर से देखें।',
    flagsEn: [
      'A parcel in your name with "illegal items"',
      'Customs duty payable by UPI link',
      'A tracking number that only works on their site',
      'Threat of a police complaint',
    ],
    flagsHi: [
      'आपके नाम पर "अवैध सामान" वाला पार्सल',
      'UPI लिंक से कस्टम ड्यूटी',
      'ऐसा ट्रैकिंग नंबर जो सिर्फ़ उनकी साइट पर चले',
      'पुलिस शिकायत की धमकी',
    ],
  ),
  'Remote access': FamilyGuide(
    family: 'Remote access',
    adviceEn:
        'Nobody legitimate needs to see your screen. If you already installed '
        'such an app: uninstall it, restart the phone, then change your UPI PIN '
        'and passwords.',
    adviceHi:
        'किसी असली काम के लिए आपकी स्क्रीन देखने की ज़रूरत नहीं होती। अगर ऐसा ऐप '
        'इंस्टॉल कर लिया है: उसे हटाएँ, फ़ोन रीस्टार्ट करें, फिर UPI पिन और पासवर्ड '
        'बदलें।',
    flagsEn: [
      'AnyDesk, TeamViewer, RustDesk, QuickSupport',
      '"Share the 9-digit code"',
      'Your bank app open during the call',
      'Caller knows your last bill or order',
    ],
    flagsHi: [
      'AnyDesk, TeamViewer, RustDesk, QuickSupport',
      '"9 अंकों का कोड बताइए"',
      'कॉल के दौरान बैंक ऐप खुला होना',
      'कॉलर को आपका पिछला बिल या ऑर्डर पता हो',
    ],
  ),
  'OTP theft': FamilyGuide(
    family: 'OTP theft',
    adviceEn:
        'An OTP is the key to your money. Read it to nobody — not a bank, not a '
        'delivery agent, not "customer care" found through search.',
    adviceHi:
        'OTP आपके पैसे की चाबी है। इसे किसी को न पढ़ें — न बैंक, न डिलीवरी एजेंट, '
        'न खोज से मिला "कस्टमर केयर"।',
    flagsEn: [
      '"Tell me the OTP to cancel the transaction"',
      'Caller creates panic about a wrong transfer',
      'An OTP arrives while you are on the call',
      'Screen sharing during the call',
    ],
    flagsHi: [
      '"लेन-देन रद्द करने के लिए OTP बताइए"',
      'कॉलर गलत ट्रांसफर का डर बनाता है',
      'कॉल के दौरान OTP आना',
      'कॉल के दौरान स्क्रीन शेयरिंग',
    ],
  ),
  'Prize & lottery': FamilyGuide(
    family: 'Prize & lottery',
    adviceEn:
        'You cannot win a lottery you never entered. Any prize that needs a fee, '
        'tax or deposit first is a scam.',
    adviceHi:
        'जिस लॉटरी में भाग नहीं लिया, उसे जीत नहीं सकते। जिस इनाम के लिए पहले फीस, '
        'टैक्स या जमा चाहिए, वह ठगी है।',
    flagsEn: [
      'A KBC or "lucky draw" win you never entered',
      'Processing fee or GST before delivery',
      'A link to claim the prize',
      'Bank details asked to "transfer" the prize',
    ],
    flagsHi: [
      'KBC या "लकी ड्रॉ" जिसमें भाग नहीं लिया',
      'इनाम से पहले प्रोसेसिंग फीस या GST',
      'इनाम लेने का लिंक',
      'इनाम "भेजने" के लिए बैंक विवरण माँगना',
    ],
  ),
  'Loan': FamilyGuide(
    family: 'Loan',
    adviceEn:
        'Check the lender on the RBI list before installing anything. No genuine '
        'lender takes a fee before disbursal, and no real loan app needs your '
        'contacts or gallery.',
    adviceHi:
        'कुछ भी इंस्टॉल करने से पहले RBI की सूची में ऋणदाता देखें। कोई असली ऋणदाता '
        'पैसा देने से पहले फीस नहीं लेता, और किसी लोन ऐप को आपके संपर्क या गैलरी की '
        'ज़रूरत नहीं।',
    flagsEn: [
      'Approved in 2 minutes with no documents',
      'A processing fee before disbursal',
      'An APK sent over WhatsApp',
      'Contacts and photo permissions',
    ],
    flagsHi: [
      'बिना दस्तावेज़ 2 मिनट में मंज़ूरी',
      'पैसा देने से पहले प्रोसेसिंग फीस',
      'WhatsApp पर भेजा गया APK',
      'संपर्क और फ़ोटो की अनुमति',
    ],
  ),
  'Investment': FamilyGuide(
    family: 'Investment',
    adviceEn:
        'Guaranteed returns do not exist. If profit shows in an app that is not a '
        'SEBI-registered broker, the number on screen is just a number.',
    adviceHi:
        'गारंटीड रिटर्न नहीं होता। अगर मुनाफ़ा ऐसे ऐप में दिखे जो SEBI-पंजीकृत '
        'ब्रोकर नहीं है, तो स्क्रीन पर दिख रहा आँकड़ा सिर्फ़ आँकड़ा है।',
    flagsEn: [
      'A "VIP" trading group with daily profit screenshots',
      'Deposit more to unlock withdrawal',
      'Crypto doubling',
      'Withdrawal blocked until you pay tax',
    ],
    flagsHi: [
      'रोज़ मुनाफ़े के स्क्रीनशॉट वाला "VIP" ट्रेडिंग ग्रुप',
      'निकासी खोलने के लिए और जमा',
      'क्रिप्टो दोगुना करने का दावा',
      'टैक्स देने तक निकासी रुकी',
    ],
  ),
  'Fake buyer': FamilyGuide(
    family: 'Fake buyer',
    adviceEn:
        'On OLX or Marketplace, a buyer only sends money. If they ask you to pay a '
        '"delivery" or "army officer" fee, or send you a QR, stop.',
    adviceHi:
        'OLX या Marketplace पर खरीदार सिर्फ़ पैसा भेजता है। अगर वह "डिलीवरी" या '
        '"आर्मी ऑफिसर" फीस माँगे, या QR भेजे, तो रुकें।',
    flagsEn: [
      '"Army officer posted far away"',
      'Sends a QR so you can "receive" payment',
      'Asks you to pay a courier deposit',
      'Wants to move the chat to WhatsApp immediately',
    ],
    flagsHi: [
      '"दूर तैनात आर्मी ऑफिसर"',
      '"पैसा लेने" के लिए QR भेजना',
      'कूरियर जमा देने को कहना',
      'तुरंत WhatsApp पर चैट ले जाना',
    ],
  ),
};

FamilyGuide guideFor(String family) => familyGuides[family] ?? _fallback;
