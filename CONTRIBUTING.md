# Contributing to Pramaan

Thanks for helping protect people from UPI fraud. Pramaan is deliberately small,
offline and dependency-light — please keep it that way.

## Ground rules

- **No network calls in the release build.** No analytics, no crash reporting, no
  remote config, no model downloads. A PR that adds `INTERNET` to the release
  manifest will be closed.
- **No user data collection.** Messages are scanned in memory only.
- **Every scam pattern needs a test.** If you add a rule or a template, add the
  message that must be caught *and* a lookalike legitimate message that must not
  be caught.
- **Hindi and English are first-class.** New UI strings go into
  `app/lib/core/l10n/app_strings.dart` in both maps (a test enforces parity).

## Repository layout

| Path | What lives here |
| --- | --- |
| `packages/scam_engine/` | Pure-Dart detection engine. No Flutter, no I/O. |
| `app/` | Flutter UI (Android + web). |
| `docs/` | Architecture, threat model, pattern catalogue, privacy. |
| `scripts/` | Developer helpers (icons, verification). |

## Getting set up

```bash
# Engine
cd packages/scam_engine
dart pub get
dart analyze
dart test

# App
cd ../../app
flutter pub get
flutter analyze
flutter test
```

Requirements: Dart 3.13+, Flutter 3.47+. No Android SDK is required for
`analyze` / `test`; only `flutter build apk` needs one.

## Adding a scam pattern

1. **Add the template** to `packages/scam_engine/lib/src/data/scam_templates.dart`.
   Use a realistic message, keep placeholders generic, and pick an existing
   `familyEn` from the list below so the Learn screen picks up the right advice.
2. **Add a test** in `packages/scam_engine/test/scanner_test.dart` asserting the
   message scores `>= 60` (dangerous).
3. **Add a false-positive test** with a legitimate message that resembles it.
4. Run `dart test` and `dart analyze`.

Families in use: `KYC / account block`, `Collect request / QR`,
`Digital arrest`, `Job & task`, `Bill & subsidy`, `Refund`,
`Courier & customs`, `Remote access`, `OTP theft`, `Prize & lottery`,
`Loan`, `Investment`, `Fake buyer`.

If your pattern needs new logic (not just text), add a `DeclarativeRule` or
`CustomRule` in `lib/src/rules/rule_catalog.dart` and register it in
`buildDefaultRules()`. Give it a unique `id`, a bilingual title and explanation,
and keep the weight honest — see `docs/ARCHITECTURE.md` for the scoring model.

## Style

- `dart format .` before committing.
- Single quotes, trailing commas, `const` wherever possible.
- Public API needs a doc comment; internal code should be obvious without one.
- UI text never hardcoded in widgets — use `context.t('key')`.

## Commit messages

```
feat(engine): catch FASTAG blacklist SMS
fix(app): stop Hindi overflow on the scan action row
docs: clarify release manifest permissions
test(engine): add legit bank advisory false-positive case
```

## Reporting a security issue

Do **not** open a public issue. See [SECURITY.md](SECURITY.md).

## Licence

By contributing you agree your work is released under the MIT Licence and that
you have the right to submit it.

---

Maintained by [Omprakash Suthar (@OPBSUTHAR)](https://github.com/OPBSUTHAR).
