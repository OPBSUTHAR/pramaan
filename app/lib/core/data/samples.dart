/// Messages used by the "Try a real scam" button.
///
/// They are composites of patterns reported by Indian banks and the I4C, not
/// real people's messages: no phone numbers, no working links, no real VPAs.
class SampleMessage {
  const SampleMessage({
    required this.labelEn,
    required this.labelHi,
    required this.body,
  });

  final String labelEn;
  final String labelHi;
  final String body;
}

const List<SampleMessage> sampleMessages = [
  SampleMessage(
    labelEn: 'KYC block SMS',
    labelHi: 'KYC ब्लॉक SMS',
    body:
        'Dear Customer, your SBI YONO account will be BLOCKED today because your '
        'KYC is not updated. Update immediately within 24 hours to avoid '
        'suspension: http://sbi-kyc-verify.online/update  - SBI Team',
  ),
  SampleMessage(
    labelEn: 'Refund collect request',
    labelHi: 'रिफ़ंड कलेक्ट अनुरोध',
    body:
        'Sir your order was cancelled, refund of Rs 2,499 is pending. To receive '
        'the refund approve this request in your UPI app: '
        'upi://pay?pa=refund.helpdesk@ybl&pn=Flipkart%20Refund&am=2499&cu=INR '
        'Do not share OTP with anyone.',
  ),
  SampleMessage(
    labelEn: 'Digital arrest call',
    labelHi: 'डिजिटल अरेस्ट कॉल',
    body:
        'This is Inspector Sharma from CBI Cyber Cell. A parcel in your name was '
        'found with illegal items and a money laundering case is registered '
        'against your Aadhaar. Join this video call now and do not disconnect or '
        'tell anyone, otherwise a non-bailable warrant will be issued in 2 hours.',
  ),
  SampleMessage(
    labelEn: 'AnyDesk "support"',
    labelHi: 'AnyDesk "सपोर्ट"',
    body:
        'Your electricity connection will be disconnected tonight as your last '
        'bill payment failed. Install AnyDesk from Play Store and share the 9 '
        'digit code so our engineer can fix the bill from your phone. Pay Rs 10 '
        'reconnection charge only.',
  ),
];
