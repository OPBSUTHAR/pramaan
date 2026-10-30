/// A bundled corpus of scam message shapes seen in India.
///
/// These are written in the *canonical* form (lower case, English/Hinglish
/// mixed) because the matcher compares them against normalised input. They are
/// descriptions of fraud patterns, not the exact wording of any one message —
/// which is the point: the fuzzy matcher catches reworded copies.
class ScamTemplate {
  const ScamTemplate({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.familyEn,
    required this.familyHi,
    required this.body,
  });

  final String id;
  final String titleEn;
  final String titleHi;
  final String familyEn;
  final String familyHi;
  final String body;
}

/// Built-in templates. Kept in code (not an asset) so the engine stays a pure
/// Dart package that can run in a background isolate or a unit test with no I/O.
const List<ScamTemplate> builtInTemplates = <ScamTemplate>[
  ScamTemplate(
    id: 'kyc_block_sms',
    titleEn: 'KYC expired, account will be blocked',
    titleHi: 'KYC एक्सपायर, खाता बंद हो जाएगा',
    familyEn: 'KYC / account block',
    familyHi: 'KYC / खाता बंद',
    body:
        'dear customer your kyc has expired and your account will be blocked '
        'today update your kyc immediately by clicking the link below to avoid '
        'account suspension',
  ),
  ScamTemplate(
    id: 'netbanking_locked',
    titleEn: 'Net banking locked, verify identity',
    titleHi: 'नेट बैंकिंग लॉक, पहचान सत्यापित करें',
    familyEn: 'KYC / account block',
    familyHi: 'KYC / खाता बंद',
    body:
        'dear customer your net banking has been locked for security reasons '
        'please verify your identity by clicking this link within 24 hours '
        'otherwise your account will be deactivated',
  ),
  ScamTemplate(
    id: 'collect_request',
    titleEn: 'Accept a request to "receive" money',
    titleHi: '"पैसे लेने" के लिए रिक्वेस्ट एक्सेप्ट करें',
    familyEn: 'Collect request / QR',
    familyHi: 'कलेक्ट रिक्वेस्ट / QR',
    body:
        'i have sent you a payment request of rs 2000 please accept the request '
        'to receive the money in your account and approve it now',
  ),
  ScamTemplate(
    id: 'qr_to_receive',
    titleEn: 'Scan QR to receive refund',
    titleHi: 'रिफंड लेने के लिए QR स्कैन करें',
    familyEn: 'Collect request / QR',
    familyHi: 'कलेक्ट रिक्वेस्ट / QR',
    body:
        'to receive your refund please scan this qr code and enter your upi pin '
        'the amount will be credited to your account instantly',
  ),
  ScamTemplate(
    id: 'upi_pin_cashback',
    titleEn: 'Enter UPI PIN to get cashback',
    titleHi: 'कैशबैक लेने के लिए UPI पिन डालें',
    familyEn: 'Collect request / QR',
    familyHi: 'कलेक्ट रिक्वेस्ट / QR',
    body:
        'congratulations you are eligible for a cashback of rs 5000 enter your '
        'upi pin to receive the cashback in your account immediately',
  ),
  ScamTemplate(
    id: 'digital_arrest_cbi',
    titleEn: 'CBI digital arrest over a parcel',
    titleHi: 'पार्सल पर CBI डिजिटल अरेस्ट',
    familyEn: 'Digital arrest',
    familyHi: 'डिजिटल अरेस्ट',
    body:
        'this is cbi officer a parcel in your name contains illegal items join '
        'the video call for verification do not tell anyone about this call or '
        'you will be arrested immediately',
  ),
  ScamTemplate(
    id: 'digital_arrest_laundering',
    titleEn: 'Aadhaar linked to money laundering',
    titleHi: 'आधार मनी लॉन्ड्रिंग से जुड़ा',
    familyEn: 'Digital arrest',
    familyHi: 'डिजिटल अरेस्ट',
    body:
        'your aadhaar is linked to a money laundering case stay on the call and '
        'transfer the clearance amount to avoid arrest do not disconnect the '
        'call or inform your family',
  ),
  ScamTemplate(
    id: 'trai_block_notice',
    titleEn: 'TRAI will block your number',
    titleHi: 'TRAI आपका नंबर ब्लॉक करेगा',
    familyEn: 'Digital arrest',
    familyHi: 'डिजिटल अरेस्ट',
    body:
        'trai notice your mobile number will be blocked in 2 hours for illegal '
        'activity press 1 to talk to our officer regarding this complaint',
  ),
  ScamTemplate(
    id: 'task_job_telegram',
    titleEn: 'Part-time job, like videos and earn daily',
    titleHi: 'पार्ट टाइम नौकरी, वीडियो लाइक करें रोज़ कमाएं',
    familyEn: 'Job & task',
    familyHi: 'नौकरी और टास्क',
    body:
        'part time job available work from home and earn rs 3000 daily just '
        'like youtube videos and complete simple tasks join our telegram group '
        'no experience needed',
  ),
  ScamTemplate(
    id: 'task_job_deposit',
    titleEn: 'Deposit money to unlock the next task',
    titleHi: 'अगला टास्क खोलने के लिए पैसे जमा करें',
    familyEn: 'Job & task',
    familyHi: 'नौकरी और टास्क',
    body:
        'your task is complete you earned rs 500 to unlock the next task deposit '
        'rs 5000 into this account and you will receive your commission with '
        'profit immediately',
  ),
  ScamTemplate(
    id: 'electricity_disconnect',
    titleEn: 'Electricity will be disconnected tonight',
    titleHi: 'आज रात बिजली कट जाएगी',
    familyEn: 'Bill & subsidy',
    familyHi: 'बिल और सब्सिडी',
    body:
        'dear consumer your electricity bill is pending your power supply will '
        'be disconnected tonight at 9 30 pm pay immediately on this link to '
        'avoid disconnection',
  ),
  ScamTemplate(
    id: 'fastag_blacklist',
    titleEn: 'FASTag will be blacklisted',
    titleHi: 'FASTag ब्लैकलिस्ट हो जाएगा',
    familyEn: 'Bill & subsidy',
    familyHi: 'बिल और सब्सिडी',
    body:
        'your fastag kyc is pending your tag will be blacklisted and you will '
        'not be able to cross toll plaza update your kyc immediately on this '
        'link',
  ),
  ScamTemplate(
    id: 'lpg_subsidy',
    titleEn: 'LPG subsidy pending, update bank details',
    titleHi: 'LPG सब्सिडी लंबित, बैंक जानकारी अपडेट करें',
    familyEn: 'Bill & subsidy',
    familyHi: 'बिल और सब्सिडी',
    body:
        'your lpg subsidy of rs 1200 is pending in your account update your bank '
        'account details by clicking here to receive the subsidy amount',
  ),
  ScamTemplate(
    id: 'pm_kisan_ekyc',
    titleEn: 'PM-Kisan instalment on hold',
    titleHi: 'PM-Kisan किस्त रुकी हुई',
    familyEn: 'Bill & subsidy',
    familyHi: 'बिल और सब्सिडी',
    body:
        'pm kisan samman nidhi your installment of rs 2000 is on hold complete '
        'your ekyc immediately to receive the benefit amount in your bank '
        'account',
  ),
  ScamTemplate(
    id: 'income_tax_refund',
    titleEn: 'Income tax refund needs card details',
    titleHi: 'आयकर रिफंड के लिए कार्ड डिटेल',
    familyEn: 'Refund',
    familyHi: 'रिफंड',
    body:
        'income tax department your refund of rs 15480 has been approved submit '
        'your bank account number and card details to receive the refund within '
        '24 hours',
  ),
  ScamTemplate(
    id: 'courier_customs',
    titleEn: 'Parcel held at customs, pay clearance',
    titleHi: 'पार्सल कस्टम में रुका, क्लीयरेंस चुकाएं',
    familyEn: 'Courier & customs',
    familyHi: 'कूरियर और कस्टम',
    body:
        'your parcel from dubai is held at customs department pay the clearance '
        'charges of rs 4500 to release it otherwise the parcel will be returned '
        'to sender',
  ),
  ScamTemplate(
    id: 'anydesk_support',
    titleEn: 'Install AnyDesk to reverse the transaction',
    titleHi: 'ट्रांजैक्शन वापस लेने के लिए AnyDesk इंस्टॉल करें',
    familyEn: 'Remote access',
    familyHi: 'रिमोट एक्सेस',
    body:
        'to reverse your failed transaction please install anydesk and share the '
        '9 digit code with our support executive he will help you get your money '
        'back',
  ),
  ScamTemplate(
    id: 'otp_phone_call',
    titleEn: 'Share the OTP to complete your refund',
    titleHi: 'रिफंड पूरा करने के लिए OTP बताएं',
    familyEn: 'OTP theft',
    familyHi: 'OTP चोरी',
    body:
        'sir i am calling from bank please share the otp you just received on '
        'your mobile to complete the refund process otherwise the transaction '
        'will fail',
  ),
  ScamTemplate(
    id: 'lottery_kbc',
    titleEn: 'KBC lucky draw winner',
    titleHi: 'KBC लकी ड्रॉ विजेता',
    familyEn: 'Prize & lottery',
    familyHi: 'इनाम और लॉटरी',
    body:
        'congratulations your mobile number has won rs 25 lakh in the kbc lucky '
        'draw to claim your prize send your aadhaar card and pay the processing '
        'fee',
  ),
  ScamTemplate(
    id: 'lottery_courier_fee',
    titleEn: 'Pay courier charges for your prize',
    titleHi: 'इनाम के लिए कूरियर चार्ज दें',
    familyEn: 'Prize & lottery',
    familyHi: 'इनाम और लॉटरी',
    body:
        'you are the lucky winner of our mega draw send rs 5000 as courier '
        'charges and your gift will be delivered to your address within 3 days',
  ),
  ScamTemplate(
    id: 'loan_instant_app',
    titleEn: 'Instant loan, no documents',
    titleHi: 'तुरंत लोन, कोई कागज़ नहीं',
    familyEn: 'Loan',
    familyHi: 'लोन',
    body:
        'instant personal loan of rs 50000 approved no documents needed download '
        'our app and get money in your account within 5 minutes no cibil check',
  ),
  ScamTemplate(
    id: 'loan_processing_fee',
    titleEn: 'Loan approved, pay processing fee',
    titleHi: 'लोन मंज़ूर, प्रोसेसिंग फीस दें',
    familyEn: 'Loan',
    familyHi: 'लोन',
    body:
        'congratulations your loan of rs 5 lakh is approved by rbi pay the '
        'processing fee of rs 2500 and the amount will be credited to your '
        'account today',
  ),
  ScamTemplate(
    id: 'trading_vip_group',
    titleEn: 'VIP trading group with guaranteed profit',
    titleHi: 'गारंटीड मुनाफे वाला VIP ट्रेडिंग ग्रुप',
    familyEn: 'Investment',
    familyHi: 'निवेश',
    body:
        'join our vip trading group guaranteed 30 percent daily profit with no '
        'risk minimum investment rs 10000 our experts give sure shot intraday '
        'calls',
  ),
  ScamTemplate(
    id: 'crypto_double',
    titleEn: 'Double your money with a crypto bot',
    titleHi: 'क्रिप्टो बॉट से पैसे दोगुने करें',
    familyEn: 'Investment',
    familyHi: 'निवेश',
    body:
        'double your money in 7 days our crypto bot gives fixed return every day '
        'deposit now and withdraw your profit anytime no risk guaranteed',
  ),
  ScamTemplate(
    id: 'sim_aadhaar_mismatch',
    titleEn: 'SIM deactivation due to Aadhaar mismatch',
    titleHi: 'आधार मेल न खाने पर SIM बंद',
    familyEn: 'KYC / account block',
    familyHi: 'KYC / खाता बंद',
    body:
        'your sim card will be deactivated in 2 hours due to aadhaar mismatch '
        'verify your details now on this link to keep your number active',
  ),
  ScamTemplate(
    id: 'pan_aadhaar_link',
    titleEn: 'PAN will be deactivated, pay to link',
    titleHi: 'PAN बंद हो जाएगा, लिंक करने के पैसे दें',
    familyEn: 'KYC / account block',
    familyHi: 'KYC / खाता बंद',
    body:
        'your pan card will be deactivated link it with aadhaar immediately by '
        'paying rs 500 on this link otherwise your bank account will be frozen',
  ),
  ScamTemplate(
    id: 'army_bulk_order',
    titleEn: 'Fake army bulk order',
    titleHi: 'नकली सेना का बल्क ऑर्डर',
    familyEn: 'Fake buyer',
    familyHi: 'नकली खरीदार',
    body:
        'we are from indian army we want to place a bulk order please contact on '
        'whatsapp we will pay advance through upi but first you need to pay '
        'registration charges',
  ),
  ScamTemplate(
    id: 'olx_buyer_collect',
    titleEn: 'Fake online buyer sends a collect request',
    titleHi: 'नकली खरीदार कलेक्ट रिक्वेस्ट भेजता है',
    familyEn: 'Collect request / QR',
    familyHi: 'कलेक्ट रिक्वेस्ट / QR',
    body:
        'i am interested in your item i will send you the payment right now '
        'please accept the collect request and enter your upi pin to receive the '
        'amount',
  ),
  ScamTemplate(
    id: 'order_cancelled_refund',
    titleEn: 'Order cancelled, refund needs card details',
    titleHi: 'ऑर्डर रद्द, रिफंड के लिए कार्ड डिटेल',
    familyEn: 'Refund',
    familyHi: 'रिफंड',
    body:
        'your amazon order was cancelled refund of rs 3999 is pending share your '
        'card number and cvv to process the refund immediately',
  ),
  ScamTemplate(
    id: 'screen_share_refund',
    titleEn: 'Share your screen so we can refund you',
    titleHi: 'रिफंड के लिए स्क्रीन शेयर करें',
    familyEn: 'Remote access',
    familyHi: 'रिमोट एक्सेस',
    body:
        'your money will be refunded please share your screen so our executive '
        'can help you complete the process do not worry this is fully secure',
  ),
  ScamTemplate(
    id: 'verification_transfer',
    titleEn: 'Send money as "verification" to receive a credit',
    titleHi: '"सत्यापन" के लिए पैसे भेजें, फिर रकम मिलेगी',
    familyEn: 'Refund',
    familyHi: 'रिफंड',
    body:
        'you have received rs 10000 to complete the transaction send rs 2000 as '
        'verification amount it will be refunded to you immediately after the '
        'process',
  ),
];
