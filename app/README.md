# Pramaan (mobile)

The mobile app lives in this directory. It is a Flutter (Android + Web) client for
the offline scam-detection engine in `../packages/scam_engine`.

See [`../README.md`](../README.md) for the project overview, scoring, privacy and
contribution guidelines.

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release        # needs an Android SDK
flutter build web --release
```

Development only: `flutter run` (requires a device or an emulator). The release
build declares **no dangerous permissions and no `INTERNET`** — keep it that way.

Maintained by [Omprakash Suthar (@OPBSUTHAR)](https://github.com/OPBSUTHAR).
