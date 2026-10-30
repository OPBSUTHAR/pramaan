# Threat model

Pramaan is a decision aid for one person holding one phone. This document states
what it defends against, what it deliberately does not, and where the residual
risk sits.

## Assets

| Asset | Where it lives | Sensitivity |
| --- | --- | --- |
| The message being checked | RAM only, until saved | High — may contain a name, amount, VPA |
| Scan history | `shared_preferences`, device only | High |
| Scam corpus / rules | App binary | Public |
| User's money | Outside the app | Critical |

## Adversaries

### A1 — The scammer (remote, untrusted input)

Sends the message being analysed. Controls its wording, length, language,
Unicode characters, links, VPAs and attachments.

**Capabilities:** social engineering, brand impersonation, homoglyph and
zero-width obfuscation, disposable domains, typosquatted UPI handles,
reworded scripts, urgency and authority pressure.

**Not capable of:** modifying the app, reading its memory, or influencing the
score except through the input text.

### A2 — A malicious app on the same device

**Capabilities:** overlay attacks (drawing a fake "success" screen over the
banking app), accessibility-service keylogging, clipboard reading.

**Pramaan does not defend against A2.** No offline text checker can. The only
honest mitigation is user education, which the Help tab provides.

### A3 — Network attacker

**Capabilities:** intercept or modify traffic.

**Pramaan has no traffic to intercept.** No network calls are made during a
scan. The only outbound actions are user-initiated: `tel:1930` and
`https://cybercrime.gov.in`, both handed to the OS.

### A4 — Supply chain

**Capabilities:** a compromised dependency, a tampered release artifact.

**Mitigations:** the engine has zero runtime dependencies. The app depends on
`shared_preferences`, `url_launcher`, `flutter_localizations` and
`cupertino_icons` only. CI runs analyze and both test suites on every push.
Release artifacts are built in CI, not on a contributor laptop.

## Trust boundaries

```
┌───────────────────────────────────────────────┐
│ Device                                        │
│                                               │
│  ┌─────────────┐    ┌──────────────────────┐  │
│  │ Clipboard / │───▶│ app (Flutter)        │  │
│  │ user typing │    │  ┌────────────────┐  │  │
│  └─────────────┘    │  │ scam_engine    │  │  │
│                     │  │ (pure, no I/O) │  │  │
│                     │  └────────────────┘  │  │
│                     │  ┌────────────────┐  │  │
│                     │  │ prefs (local)  │  │  │
│                     │  └────────────────┘  │  │
│                     └──────────┬───────────┘  │
└────────────────────────────────┼──────────────┘
                                 │ user-initiated only
                                 ▼
                     tel:1930 · cybercrime.gov.in
```

The engine is a pure function of its input. That is the strongest privacy
property in the design: there is no code path from a message to a socket.

## Threats to Pramaan itself

### T1 — False negative (scam scored safe)

**Impact:** user pays.
**Cause:** novel script, language not in the corpus, very short message.
**Mitigations:** the clean verdict never says "safe"; it says "no fraud signals
found" and repeats the OTP/PIN rule. Scores are only one input to a decision
the UI frames as "proof before you pay".

### T2 — False positive (legitimate message scored dangerous)

**Impact:** user distrusts the app and ignores it later — the worst outcome for
a safety tool.
**Cause:** aggressive keyword rules; banks' own advisory SMS.
**Mitigations:** `suppress` predicates (a genuine "never share your OTP"
advisory does not fire the OTP rule), trusted-domain relief, per-category caps,
and a test suite with five ordinary-message fixtures that must stay below 35.

### T3 — Template rot

**Impact:** Scam DNA stops matching new scripts.
**Mitigation:** templates are data, not code. Adding one is a one-file change
with a test. The Learn tab reads the same corpus, so users see the same list the
matcher uses.

### T4 — Over-trust in the UPI inspector

**Impact:** user reads "no structural red flags" as "payee is safe".
**Mitigation:** the copy explicitly says the opposite on the same screen, and
the parser always emits `p2p_no_chargeback` for person-to-person payments.

### T5 — History leakage

**Impact:** someone with the unlocked phone reads past checks.
**Mitigation:** history is capped, clearable in one tap, and never synced. It is
not encrypted at rest — `shared_preferences` is not a secret store, and the app
does not claim otherwise.

### T6 — Malicious contribution

**Impact:** a PR weakens detection or exfiltrates data.
**Mitigation:** the engine has no I/O to exfiltrate through. Any new dependency
in the app is a review-blocking change. CI must stay green.

## Out of scope

- Protecting the user from a scammer they are talking to on a call.
- Recovering money (that is 1930 and the bank's job).
- Verifying that a payee is honest.
- Detecting malware already installed on the device.
- iOS builds (the platform shell is not implemented yet).

## Reporting

Security issues: see [SECURITY.md](../SECURITY.md). Never include a real
victim's message, number, account or VPA in a report — redact it.
