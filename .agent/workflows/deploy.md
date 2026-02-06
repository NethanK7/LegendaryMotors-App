---
description: How to build and deploy the Legendary Motors mobile app
---

# Deploying Legendary Motors

Since this is a mobile application, "hosting" technically means building the installer files (APK/IPA) and distributing them, either via App Stores or manually.

## 1. Preparation
Before building, ensure your `pubspec.yaml` has the correct version:
```yaml
version: 1.0.0+1
```
*(Increment the number after `+` for each new build)*

## 2. Build for Android
To create an APK for testing or direct installation:
```bash
flutter build apk --release
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

To create an App Bundle for Google Play Store:
```bash
flutter build appbundle
```
**Output:** `build/app/outputs/bundle/release/app-release.aab`

## 3. Build for iOS (Mac Only)
To create an archive for the App Store (requires Xcode installed):
```bash
flutter build ipa
```
**Output:** `build/ios/archive/Runner.xcarchive`
*You will then need to upload this using Apple Transporter or Xcode.*

## 4. Hosting / Distribution
*   **Google Play Store**: Upload the `.aab` file to the [Play Console](https://play.google.com/console).
*   **Apple App Store**: Upload the `.ipa` (from the archive) via [App Store Connect](https://appstoreconnect.apple.com/).
*   **Manual Hosting**: You can upload the `.apk` file to a server (like Google Drive, Dropbox, or a website) and share the link for Android users to sideload.
