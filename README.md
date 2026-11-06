# Account Manager

A cross-platform account & password manager built with Flutter. Your vault is
**encrypted on the device** with a key derived from your master password, and only
the encrypted data is stored in the cloud (Firebase) — a zero-knowledge design.

## Features

- 🔐 **Master password** lock (key never leaves the device)
- 🔑 **Account login** (Firebase Auth) so your vault syncs across devices
- ☁️ **Cloud sync** with Firestore, per-account documents + offline cache
- 🔎 **Search**, ➕ add / ✏️ edit / 🗑️ delete accounts
- 🖼️ **Service icons** (favicons) with a colored-initial fallback
- 🎨 **6 color themes** + 🌗 **light / dark** mode
- 🌍 **i18n**: English + Serbian (Latin)
- 🔵🟢 Sync status banner + manual "Sync now"

## Tech

Flutter · Dart · Firebase (Auth + Firestore) · AES encryption (`encrypt`, `crypto`)

## Getting started

```bash
flutter pub get
# Connect your own Firebase project (generates lib/firebase_options.dart):
flutterfire configure
flutter run
```

## Security

- Passwords are encrypted client-side (AES) with a key derived from the master
  password via salted SHA-256; the master password is never stored or uploaded.
- Firestore security rules restrict each user to their own vault.
- The included `firebase_options.dart` / `google-services.json` are **client**
  Firebase config (safe to ship in apps); data is protected by the security rules.

## Release

Every push to `main` runs [release-apk.yml](.github/workflows/release-apk.yml):
analyze → tests (once there is a `test/` folder) → signed release APK → GitHub
Release → download page on GitHub Pages
(<https://nananeko1305.github.io/Account-Manager/>) with a Download button, a
Share button and a QR code. A merge that only changes the page (`.github/pages/`)
does not release: [pages.yml](.github/workflows/pages.yml) redeploys the page for
the current APK.

Versions are `major.minor.patch`, worked out in CI from the commit messages since
the last tag: a `feat` bumps the minor, anything else the patch, and a breaking
change the major. The version in `pubspec.yaml` is a floor; raise it by hand to
force a bigger number, such as a deliberate 1.0.0.

Signing uses these repository secrets: `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. A run
without them fails rather than ship an APK that cannot be updated. Keep a backup
of the keystore: losing it means users must uninstall to get new versions.
