# RMScanner AI

> Total Free Premium Pro Scanner App — Scan, OCR, PDF tools, and QR scanner in one app.

[![Build](https://github.com/rifqimulyawan/rmscanner-ai/actions/workflows/build.yml/badge.svg)](https://github.com/rifqimulyawan/rmscanner-ai/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/rifqimulyawan/rmscanner-ai)](https://github.com/rifqimulyawan/rmscanner-ai/releases)
[![License](https://img.shields.io/badge/license-Proprietary-red)](LICENSE)

## Features

- **Document Scanning** — Auto-edge detection and perspective correction via Cunning Document Scanner
- **Smart OCR** — Extract text from images and PDFs in 7 languages (EN, ID, BN, HI, FR, DE, AR) using Google ML Kit
- **Batch OCR** — Process multiple files at once and export to TXT/CSV
- **PDF Tools** — Merge, split, compress, lock/unlock, rotate, and reorder pages
- **Converters** — Image to PDF, PDF to Image, Text to PDF
- **QR Scanner** — Scan and generate QR codes
- **File Management** — Search, sort, and organize scanned documents
- **Multilingual** — 7 languages with full localization
- **Dark Mode** — System-aware theme with manual toggle
- **AdMob** — Banner, interstitial, and rewarded ads support

## Architecture

```
rmscanner-ai/
├── lib/
│   ├── core/                # Theme, routing, localization, services, utils
│   ├── features/            # Feature modules (home, files, tools, ocr, settings, splash, onboarding)
│   └── main.dart
├── android/                 # Android platform config
├── ios/                     # iOS platform config
├── assets/                  # App icon, logo, images
└── .github/                 # CI/CD workflows
```

### Tech Stack

| Component | Technology |
|---|---|
| Framework | Flutter 3.38+ |
| State Management | flutter_bloc |
| Navigation | go_router (StatefulShellRoute) |
| OCR | Google ML Kit Text Recognition |
| Document Scanner | Cunning Document Scanner |
| PDF | pdf, pdf_merger, pdf_compressor |
| Ads | Google Mobile Ads (AdMob) |
| i18n | Custom AppLocalizations (7 languages) |
| Icons | Material Icons |

## Installation

### Download

Download the latest release from the [Releases page](https://github.com/rifqimulyawan/rmscanner-ai/releases).

- **Android**: `.apk` (sideload) or `.aab` (Play Store)
- **iOS**: `.ipa` (sideload via AltStore/Sideloadly)

### Build from Source

#### Prerequisites

- [Flutter](https://flutter.dev) 3.38+ (stable channel)
- [Android Studio](https://developer.android.com/studio) with Android SDK
- [Xcode](https://developer.apple.com/xcode/) 15+ (for iOS builds, macOS only)
- [CocoaPods](https://cocoapods.org/) (for iOS)

#### Steps

```bash
# Clone the repository
git clone https://github.com/rifqimulyawan/rmscanner-ai.git
cd rmscanner-ai

# Install dependencies
flutter pub get

# Run in development mode
flutter run

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS, requires macOS)
flutter build ipa --release
```

## Configuration

### AdMob

Configure your AdMob IDs in:

- **Android**: `android/app/src/main/AndroidManifest.xml`
- **iOS**: `ios/Runner/Info.plist`

| Ad Type | Unit ID |
|---|---|
| Banner | `ca-app-pub-9495219818644530/2125318030` |
| Interstitial | `ca-app-pub-9495219818644530/7059603024` |
| Rewarded | `ca-app-pub-9495219818644530/8499154699` |

### Languages

Supported languages: English, Indonesian, Bengali, Hindi, French, German, Arabic.

## CI/CD

GitHub Actions automatically builds Android APK and iOS IPA on push to `main` and on version tags.

See [Build Workflow](.github/workflows/build.yml).

## License

This project is proprietary. All rights reserved.

## Links

- [Releases](https://github.com/rifqimulyawan/rmscanner-ai/releases)
- [Issues](https://github.com/rifqimulyawan/rmscanner-ai/issues)
- [Privacy Policy](https://rmdigital.co.id/kebijakan-privasi/)
- [Play Store](https://play.google.com/store/apps/details?id=com.rmscanner.ai)

