# Pramaan · प्रमाण

**Proof before you pay.**
**भुगतान से पहले प्रमाण।**

Pramaan is an offline scam shield for India. Paste a suspicious SMS, a WhatsApp
forward, a UPI collect request or a QR payload, and it tells you what is wrong
with it — in Hindi or English — **without sending a single byte off the phone**.

No account. No server. No model download. Works in airplane mode.

```
┌──────────────────────────────────────────────────────────┐
│  "Dear Customer, your account will be BLOCKED today     │
│   because KYC is not updated. Update immediately:        │
│   http://sbi-kyc-verify.online/update"                   │
└──────────────────────────────────────────────────────────┘
                            │
                            ▼
              87 / 100  ·  CRITICAL
              Scam DNA match: KYC / account block — 94%
              • Brand name inside a fake domain
              • 24-hour deadline
              • Threat of permanent block
```

---

## Why this exists

Every scam defence in India today needs the internet: a spam database, a cloud
AI, a bank's server. The scam arrives on a phone that may have no data, or the
victim may not have the confidence to search for an answer.

The scam message itself, though, is already on the phone. It can be judged
right there.

Pramaan does that with three engines that fit in a few hundred kilobytes:

### 1. Scam DNA — fuzzy template matching

A bundled corpus of real Indian fraud scripts (KYC block, collect-request
"refund", digital arrest, task-job deposit, electricity disconnection, courier
customs, loan processing fee, trading VIP groups, fake army buyer, and more).

Each message is fingerprinted with character trigrams and word tokens. The
matcher blends them (`0.62 × trigram Jaccard + 0.38 × token overlap`), so a scam
that has been reworded, translated, or padded with emoji still lands on its
family. This is why it catches scams it has never seen verbatim.

### 2. A rule engine with 34 fraud signals

Deterministic rules over a normalised view of the text:

- Devanagari → canonical English tokens (तुरंत → immediately, खाता → account,
  ओटीपी → otp), so Hindi and English hit the same rules
- Cyrillic/Greek homoglyph folding (`РАYTM` → `PAYTM`)
- UPI address, link, amount, mobile and caps-ratio extraction
- Look-alike domain detection against official bank/government domains
- Brand-as-subdomain tricks (`sbi.verify-login.xyz`)
- PSP handle vetting with bounded Levenshtein typosquat detection

Signals are weighted, de-duplicated per category, and combined with a noisy-OR
model. A critical signal sets a floor of 70 — a message that asks for your UPI
PIN cannot come out "probably fine".

### 3. A UPI intent inspector

`upi://pay`, `upi://mandate`, `upi://collect`, bare VPAs and percent-encoded QR
payloads are decoded offline. Pramaan shows the operation, payee, amount,
merchant code and every structural warning — including the one that matters
most:

> A **collect** request and a **QR you scan** only ever take money *out*.
> Receiving money never needs approval, a PIN, or a scan.

---

## Privacy is the architecture, not a promise

| What other apps do | What Pramaan does |
| --- | --- |
| Upload the message to a server | Runs on-device, always |
| Download a model on first launch | Ships the corpus in the binary |
| Need an account | No account exists |
| Keep analytics | No analytics SDK is compiled in |
| Ask for contacts/SMS permissions | Requests no permissions at all |

The Android build declares **no dangerous permissions**. There is no network
code in the app beyond opening the `1930` dialer and the cybercrime portal,
which you trigger explicitly.

History is stored with `shared_preferences` on the device and nowhere else.
Clearing it, or uninstalling the app, deletes it.

---

## Repository layout

```
pramaan/
├── app/                      Flutter application (Android + Web)
│   ├── lib/
│   │   ├── core/             theme · l10n (en/hi) · widgets · services
│   │   ├── features/         scan · result · upi · learn · emergency · history
│   │   ├── main.dart
│   │   └── root_shell.dart
│   └── test/                 12 widget + unit tests
├── packages/
│   └── scam_engine/          Pure Dart. Zero runtime dependencies.
│       ├── lib/src/
│       │   ├── models/       Severity · RiskLevel · ScamSignal · ScanReport
│       │   ├── text/         normalizer · similarity
│       │   ├── context/      ScanContext
│       │   ├── rules/        34 declarative rules
│       │   ├── data/         31 scam templates · PSP handles · domains
│       │   ├── matching/     TemplateMatcher (Scam DNA)
│       │   ├── scoring/      RiskScorer (noisy-OR)
│       │   └── upi/          UpiLinkParser · VpaInspector
│       └── test/             81 tests
├── docs/                     Architecture · threat model · patterns · privacy
├── scripts/                  Local verification and build helpers
└── .github/                  CI, release workflow, issue templates
```

The engine is a separate package on purpose: it has no Flutter dependency, so it
can be tested on plain Dart, reused in a CLI, or embedded in a bank's own app.

---

## Getting started

Requirements: Flutter 3.47+ (Dart 3.13+). No Android SDK is needed to run the
web build or the test suite.

```bash
git clone https://github.com/OPBSUTHAR/pramaan.git
cd pramaan

# Engine: pure Dart, no Flutter needed
cd packages/scam_engine
dart pub get
dart test          # 81 tests

# App
cd ../../app
flutter pub get
flutter test       # 12 tests
flutter run -d chrome
flutter build apk --release   # needs Android SDK
```

### Verification status

| Check | Result |
| --- | --- |
| `dart analyze` (engine) | clean |
| `dart test` (engine) | 81 passing |
| `flutter analyze` (app) | clean |
| `flutter test` (app) | 12 passing |
| `flutter build web --release` | passing |

---

## How a scan flows

```
input ──▶ TextNormalizer ──▶ ScanContext
                                │
              ┌─────────────────┼──────────────────┐
              ▼                 ▼                  ▼
        34 rules          TemplateMatcher      UPI extraction
              │                 │                  │
              └────────┬────────┘                  │
                       ▼                           │
                  RiskScorer  ◀───────────────────┘
                       │
                       ▼
                  ScanReport (score · level · signals · DNA match)
```

Scoring, in order:

1. Positive signals sorted by effective weight (weight × severity multiplier)
2. At most 3 signals per category, so one noisy category cannot dominate
3. Noisy-OR accumulation: `remaining *= (1 - w)`
4. Scam DNA contributes `similarity × 0.75`, capped at 0.95
5. Trusted official-domain signals apply relief, capped at 60%
6. Any critical signal floors the score at 70
7. Final score is rounded and clamped to 0–100

---

## What Pramaan will not do

- It will not tell you a payee is safe. UPI transfers are irreversible; the app
  says so on every UPI screen.
- It will not scan your SMS inbox. You paste what you want checked.
- It will not replace 1930. The Help tab exists for the moment after money has
  already moved.

---

## Contributing

Scam patterns age fast. The most valuable contribution is a **new template** in
`packages/scam_engine/lib/src/data/scam_templates.dart` with a test proving it
scores at least `dangerous`. See [CONTRIBUTING.md](CONTRIBUTING.md).

Never paste a real victim's message, phone number, account number or VPA into an
issue. Rewrite it with placeholders.

---

## License

MIT © [Omprakash Suthar (@OPBSUTHAR)](https://github.com/OPBSUTHAR)

Built in India, for India. If this app stops one wrong payment, it has done its
job.
