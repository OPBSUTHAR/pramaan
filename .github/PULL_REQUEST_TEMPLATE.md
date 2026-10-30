## Summary

<!-- What does this PR change, and why? Keep it to three or four lines. -->

## Type of change

- [ ] Bug fix (engine or app)
- [ ] New scam pattern (template / rule)
- [ ] New feature
- [ ] Documentation
- [ ] Build / tooling / CI

## Changes

<!-- Bullet list, grouped by area: engine, app, docs. -->

## Privacy check

- [ ] The release AndroidManifest still contains no `android.permission.INTERNET`.
- [ ] No new network call, analytics, telemetry or remote config.
- [ ] Scanned text is not written to disk, shared or logged.

## Engine check (if scam_engine touched)

- [ ] `dart analyze` passes with no issues.
- [ ] `dart test` passes.
- [ ] Engine still imports only `package:scam_engine`'s allowed dependencies (pure Dart).
- [ ] New rule / template ships with both a positive and a negative test case.
- [ ] Hindi + English strings use `context.t('...')`, not inline literals.

## App check (if app touched)

- [ ] `flutter analyze` passes with no issues.
- [ ] `flutter test` passes.
- [ ] `flutter build web --release` succeeds.
- [ ] Strings added to **both** maps in `app_strings.dart` (test enforces parity).
- [ ] Tested on a narrow viewport (the widget test sets `size: Size(1080, 2400)`).

## Linked issue

Closes #
