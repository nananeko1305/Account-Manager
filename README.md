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
