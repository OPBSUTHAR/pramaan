# Security policy

Pramaan is an offline scam-detection app. It has no backend, no accounts and no
telemetry, which removes most of the usual attack surface — but the engine still
makes decisions people trust with their money.

## Supported versions

| Version | Supported |
| --- | --- |
| 1.0.x | ✅ |

## What counts as a security issue

- A message that steals money but Pramaan scores as **safe** (false negative)
  when the pattern is already covered by the engine's stated scope.
- A crafted input that makes the scanner crash, hang, or allocate unbounded
  memory (e.g. a pathological regex or an enormous paste).
- A way for scanned text to leave the device (log, backup, clipboard leak,
  crash report, web build request).
- A permission or manifest change that enables network access in a release build.
- Supply-chain issues in the dependency set (`shared_preferences`,
  `url_launcher`, `cupertino_icons`).

Generic "the app can be fooled by a brand-new scam" reports are **not**
vulnerabilities — that is the documented limitation in
[`docs/THREAT_MODEL.md`](docs/THREAT_MODEL.md). Those are still very welcome as
normal issues or PRs with a new template.

## How to report

1. Email **omprakashsuthar@users.noreply.github.com** with the subject
   `[PRAMAAN SECURITY]`.
2. Or use GitHub's private advisory flow:
   <https://github.com/OPBSUTHAR/pramaan/security/advisories/new>
3. Include: affected version, the exact input, expected vs actual score, and
   whether it reproduces on the web build or Android.

Please **do not** open a public issue with a working scam message that defeats
the detector — that is a roadmap for fraudsters.

## What to expect

- Acknowledgement within 7 days.
- A fix or a documented decision within 30 days for confirmed issues.
- Credit in the release notes unless you prefer to stay anonymous.

## Out of scope

- Physical access to an unlocked device.
- A rooted device or a malicious keyboard/clipboard app reading what you paste.
- Social engineering of the user *after* Pramaan has warned them.
- The accuracy of third-party helpline numbers beyond what is published by
  official Indian government sources.

---

Maintained by [Omprakash Suthar (@OPBSUTHAR)](https://github.com/OPBSUTHAR).
