# Architecture

Pramaan is split into two Dart packages so that the detection logic can be
tested, reused and audited without Flutter.

```
app/                     Flutter UI, platform shells, persistence
packages/scam_engine/    Pure Dart detection engine, zero runtime dependencies
```

The dependency arrow points one way only: `app → scam_engine`. The engine never
imports Flutter.

---

## 1. Engine layers

```
lib/src/
├── text/        normalizer.dart   canonicalisation, extraction
│                similarity.dart   levenshtein, trigrams, blended similarity
├── context/     scan_context.dart lazy, memoised view over one input
├── models/      severity · risk_level · scam_signal · scan_report · upi_intent
├── rules/       scam_rule.dart    DeclarativeRule, CustomRule
│                rule_catalog.dart 34 rules
├── data/        scam_templates.dart  31 scripts
│                psp_handles.dart     ~110 UPI handles
│                known_domains.dart   official domains, shorteners, TLDs
├── matching/    template_matcher.dart  Scam DNA
├── scoring/     risk_scorer.dart       noisy-OR combination
├── upi/         upi_link_parser.dart · vpa.dart
└── scanner.dart ScamScanner — the only entry point the UI needs
```

### Why a separate context object

`ScanContext` normalises once and memoises every derived value (links, VPAs,
amounts, caps ratio, emoji count, script mix). 34 rules then read the same
computed facts instead of each re-parsing the raw string. A scan of a 400
character message stays under a millisecond on a mid-range phone.

### Rule shape

```dart
class DeclarativeRule implements ScamRule {
  final List<List<Pattern>> groups; // OR inside a group, AND across groups
  final int minGroups;              // how many groups must hit
  final bool Function(ScanContext)? suppress; // whitelist escape hatch
}
```

`Pattern` is either a `String` (substring test on canonical text) or a
`RegExp` (all matches become evidence). `suppress` exists for the case that
matters most in practice: a genuine "never share your OTP" advisory must not be
flagged as an OTP request.

`CustomRule` takes a function returning evidence strings, used for logic that
needs parsing rather than phrase matching — look-alike domains, typosquatted
handles, brand-as-subdomain tricks.

### Scoring

```
positives = signals with effectiveWeight > 0, sorted descending
negatives = signals with effectiveWeight < 0   (trusted domains)
positives = top 3 per category

remaining = 1.0
for s in positives: remaining *= (1 - min(s.effectiveWeight, 0.95))

if templateMatch != null:
    remaining *= 1 - clamp(similarity * 0.75, 0, 0.95)

score = (1 - remaining) * 100

relief = sum(|negative.effectiveWeight|)
score *= 1 - min(relief, 0.6)

if any critical signal: score = max(score, 70)
score = round(score).clamp(0, 100)
```

Properties this buys us:

- **Independent evidence compounds.** Three medium signals beat one weak one.
- **One loud category cannot dominate.** Capping per category prevents a
  message that repeats "urgent" eight times from scoring 90 on urgency alone.
- **Critical signals are non-negotiable.** Asking for a UPI PIN floors the
  score at 70 regardless of how friendly the rest of the message reads.
- **Trusted domains relieve, but never absolve.** A real `sbi.co.in` link cuts
  at most 60% of the score; it cannot make an OTP request safe.

### Scam DNA

`TemplateMatcher` normalises both sides to lowercase alphanumerics, then scores:

```
blended = 0.62 * trigramJaccard + 0.38 * tokenOverlapCoefficient
```

Trigrams catch rewording and typos; token overlap keeps short messages from
matching on character noise alone. For inputs over 220 characters, the head 200
and tail 200 are scored too and the best result wins — long forwards keep their
payload at one end.

Thresholds: `>= 0.72` strong, `>= 0.55` moderate, `>= 0.50` weak match floor.
Inputs under 24 characters are not matched at all: too little signal to be fair.

---

## 2. App layer

```
lib/
├── main.dart                 bootstrap: restore locale + history, run app
├── root_shell.dart           five-tab IndexedStack
├── core/
│   ├── theme/                AppColors, AppTheme (dark only, by design)
│   ├── l10n/                 AppStrings (en/hi maps), LocaleController, AppScope
│   ├── data/                 sample scams, family guides
│   ├── services/             Engine singleton, HistoryStore
│   └── widgets/              RiskGauge, SignalTile, ScanSweep, settings sheet
└── features/
    ├── scan/                 input + recent checks
    ├── result/               verdict, DNA card, signals, copy/share
    ├── upi/                  intent inspector
    ├── learn/                scam library (31 scripts, 13 families)
    ├── emergency/            1930 checklist
    └── history/              saved checks
```

### State

No state-management package. Two `ChangeNotifier`s (`LocaleController`,
`HistoryStore`) exposed through `InheritedNotifier` (`AppScope`, `HistoryScope`).
Screens read them with `context.t(...)` and `HistoryScope.of(context)`.

This is deliberate: the app has two pieces of state. Adding Riverpod or Bloc
would be more code to audit for a privacy claim that says "nothing leaves this
phone".

### Localisation

`AppStrings` holds two `const Map<String, String>` tables. `context.t('key')`
looks up the current language, falling back to English, then to the key itself
(so a missing translation is visible in review, never a crash). A test asserts
that both maps have identical key sets and no empty values.

Engine strings are already bilingual (`titleEn`/`titleHi` on every signal and
template), so the app never has to translate detection output.

### Persistence

`HistoryStore` keeps at most 60 entries as one JSON string in
`shared_preferences`. Each entry stores the input text, score, signal count,
timestamp and the top signal title. Storage failures are swallowed: the app
keeps working in memory if the platform denies storage.

### Rendering budget

- `RiskGauge` is a `CustomPainter` with a single `TweenAnimationBuilder`; no
  third-party chart or gauge package.
- The app mark is painted, not an image asset.
- `ScanSweep` animates only while a check is running.
- Total asset weight: zero images, zero fonts, zero model files.

---

## 3. Extension points

| To add… | Touch |
| --- | --- |
| A new scam script | `data/scam_templates.dart` + a test asserting score ≥ 60 |
| A new rule | `rules/rule_catalog.dart`, append to the right group |
| A UPI handle | `data/psp_handles.dart` |
| An official domain | `data/known_domains.dart` |
| A language | new `Map` in `app_strings.dart`, add to `supportedLocales` |

Every extension point is covered by a test that would fail if the data were
malformed (duplicate set entries, empty bodies, missing Hindi titles).
