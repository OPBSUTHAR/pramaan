# Scam pattern catalogue

Every script below lives in
[`packages/scam_engine/lib/src/data/scam_templates.dart`](../packages/scam_engine/lib/src/data/scam_templates.dart)
and is matched offline by Scam DNA. The same list powers the app's **Learn** tab.

The rule of thumb across all of them:

> If a message creates **urgency**, demands **secrecy**, asks you to **install**
> something, or asks you to **approve/scan/pay to receive**, it is a scam. No
> exceptions have been observed in the Indian fraud ecosystem.

---

## KYC / account block

| Template | The tell |
| --- | --- |
| KYC expired, account will be blocked | A link to "update KYC" on a domain that is not the bank's |
| Net banking locked, verify identity | A web form asking for card number, PIN or password |
| SIM deactivation due to Aadhaar mismatch | A 24-hour deadline plus a re-verification link |
| PAN will be deactivated, pay to link | A **fee** to link PAN–Aadhaar (linking is free) |

**Never** happens: a bank sending a KYC link. KYC is done in the bank's app or
at the branch.

## Collect request / QR

| Template | The tell |
| --- | --- |
| Accept a request to "receive" money | A collect request, described as incoming |
| Scan QR to receive refund | A QR that debits instead of credits |
| Enter UPI PIN to get cashback | A PIN prompt for "receiving" |
| Fake online buyer sends a collect request | An OLX/Marketplace buyer who sends a request |

**Never** happens: receiving money requiring approval, a PIN, or a scan. A PIN
prompt is always a payment leaving your account.

## Digital arrest

| Template | The tell |
| --- | --- |
| CBI digital arrest over a parcel | A video call with a uniform and a "case file" |
| Aadhaar linked to money laundering | "Do not disconnect, do not tell anyone" |
| TRAI will block your number | Press 9 / talk to an "officer" to avoid disconnection |

**Never** happens: arrest over a video call, or a "verification transfer" to
prove innocence.

## Job & task

| Template | The tell |
| --- | --- |
| Part-time job, like videos and earn daily | ₹2,000–5,000/day for trivial tasks |
| Deposit money to unlock the next task | Small payouts first, then a large deposit |

**Never** happens: an employer asking you to pay to work.

## Bill & subsidy

| Template | The tell |
| --- | --- |
| Electricity will be disconnected tonight | A ₹10 "reconnection" fee and an app to install |
| FASTag will be blacklisted | A link to recharge a FASTag you may not own |
| LPG subsidy pending, update bank details | Bank details requested over a link |
| PM-Kisan instalment on hold | An e-KYC link that is not `pmkisan.gov.in` |

**Never** happens: a subsidy that needs a payment or a link to be "released".

## Refund

| Template | The tell |
| --- | --- |
| Income tax refund needs card details | A refund larger than any tax you paid |
| Order cancelled, refund needs card details | Card number and CVV requested |
| Share your screen so we can refund you | Screen sharing to "process" a refund |
| Send money as "verification" to receive a credit | A transfer described as reversible (it is not) |

**Never** happens: a refund that requires you to send money first.

## Courier & customs

| Template | The tell |
| --- | --- |
| Parcel held at customs, pay clearance | A UPI link for "customs duty" |
| (digital arrest cross-over) | A parcel with "illegal items" in your name |

**Never** happens: customs duty collected over a UPI link sent on WhatsApp.

## Remote access

| Template | The tell |
| --- | --- |
| Install AnyDesk to reverse the transaction | Any screen-sharing app requested by a stranger |
| Share your screen so we can refund you | Bank app open during the call |

**Never** happens: legitimate support needing to see your screen.

## OTP theft

| Template | The tell |
| --- | --- |
| Share the OTP to complete your refund | An OTP read out during a call |

**Never** happens: any legitimate request for an OTP, ever.

## Prize & lottery

| Template | The tell |
| --- | --- |
| KBC lucky draw winner | A draw you never entered |
| Pay courier charges for your prize | A fee before delivery |

**Never** happens: a prize that requires a payment.

## Loan

| Template | The tell |
| --- | --- |
| Instant loan, no documents | Approval in minutes, APK sent over chat |
| Loan approved, pay processing fee | A fee before disbursal |

**Never** happens: a regulated lender taking a fee before disbursing.

## Investment

| Template | The tell |
| --- | --- |
| VIP trading group with guaranteed profit | Daily profit screenshots, deposit to unlock withdrawal |
| Double your money with a crypto bot | Guaranteed returns |

**Never** happens: a guaranteed return.

## Fake buyer

| Template | The tell |
| --- | --- |
| Fake army bulk order | "Army officer posted far away" asking you to pay a supplier |
| (collect-request cross-over) | A buyer who sends a request instead of money |

**Never** happens: a buyer asking a seller to pay.

---

## Adding a pattern

1. Add a `ScamTemplate` to `builtInTemplates` with a unique `id`, bilingual
   titles, a family, and a realistic body. **Rewrite it with placeholders** —
   never commit a real victim's message, number, account or VPA.
2. Add a case to `scanner_test.dart` asserting the score is `>= 60` and the
   level is at least `dangerous`.
3. Run `dart test` in `packages/scam_engine`.

The corpus test loops over every template automatically, so a badly written
body (too short, too generic) fails without a new test being written.
