# Privacy

Pramaan's privacy claim is architectural, not a policy statement. This page
lists every place data can go, so the claim can be checked.

## What is collected

**Nothing.** There is no analytics SDK, no crash reporter, no advertising
identifier, no account system and no server.

## What stays on the device

| Data | Where | Why | How to delete |
| --- | --- | --- | --- |
| The text you paste | RAM during the check | To score it | It is gone when you leave the screen |
| Saved checks (max 60) | `shared_preferences` | The History tab | History → Clear all, or uninstall |
| Language choice | `shared_preferences` | Remember EN/हिंदी | Uninstall, or switch language |

A saved check stores: the message text, the score, the number of signals, the
timestamp, and the top signal's title. It does **not** store a sender name,
phone number, contact, location, or device identifier.

`shared_preferences` is not an encrypted store. Anyone with unlocked access to
the device and a debugging tool could read the history. If that matters to you,
clear it after use — the app is designed so that clearing costs nothing.

## Permissions

The **release** Android manifest declares **no dangerous permissions** and no
`INTERNET` permission. Specifically, the app does not request:

- `READ_SMS` — it never reads your inbox
- `READ_CONTACTS` — it does not know who you talk to
- `CAMERA` — QR codes are pasted as text, not scanned
- `INTERNET` — the release build has no network capability at all

Debug and profile builds add `INTERNET` only because the Flutter tool needs it
for hot reload. It is absent from the release manifest.

The only platform interactions are clipboard reads (when you tap **Paste**) and
handing `tel:1930` / `https://cybercrime.gov.in` to the operating system when you
tap those buttons.

## Clipboard

Paste is explicit: the app reads the clipboard only after you tap the button,
and never in the background. Nothing is written to the clipboard except when you
tap **Copy verdict**, **Share warning** or **Copy checklist**.

## Children

The app has no accounts, no chat, no user-generated content and no data
collection, so it does not knowingly process any personal data about anyone,
including children.

## Open source

The entire pipeline — normaliser, rules, corpus, scorer, UPI parser — is in this
repository under the MIT licence. If the app did anything with your text, it
would be visible in
[`packages/scam_engine/lib/src/scanner.dart`](../packages/scam_engine/lib/src/scanner.dart),
which is 40 lines and has no imports beyond the engine's own files.

## Contact

Privacy questions: open an issue at
<https://github.com/OPBSUTHAR/pramaan/issues>. Do not include a real message,
number, account or VPA — redact it first.
