# MSGX — Offline Music Player

> **Your Music. Your World.**  
> A premium, Spotify-inspired, offline-first mobile music player engineered in Flutter for Android and iOS.

---

## 🎧 Overview

MSGX delivers a high-fidelity, standalone music listening experience with zero reliance on cloud streaming, user registration, or internet connectivity. It automatically scans your device for local audio files, parses metadata and embedded album artwork, and organizes your music library into an intuitive Spotify-like interface.

### Key Highlights
- **100% Offline-First**: Instant playback with airplane mode enabled; no accounts, no subscriptions, zero tracking.
- **Deep System Integration**: Background audio playback via foreground service on Android and lock-screen/Control Center integration on iOS.
- **Native Device Scanner**: High-speed discovery of MP3, M4A, FLAC, WAV, AAC, and OGG audio files with duration filtering.
- **Spotify-Inspired UI**: Signature dark theme (`#121212`), high-contrast typography, large cover artwork, responsive mini-player, and full-screen Now Playing view.
- **Comprehensive Playlist & Library Management**: Playlists, favorites, recently played history, albums, artists, and folder browsing backed by an ACID-compliant SQLite database.
- **Offline Lyrics & Equalizer**: Synchronized and static LRC offline lyrics parsing, sleep timer, playback speed control, and multi-band equalizer presets.

---

## 🏗 Architecture

MSGX follows a clean, feature-based architecture utilizing Riverpod for reactive state management:

```
MSGX/
├── lib/
│   ├── main.dart                   # Application entry point & service initialization
│   ├── app.dart                    # Root MaterialApp with theme & routing
│   ├── core/
│   │   ├── constants/              # Colors, metrics, and constants
│   │   ├── theme/                  # Dark & Light theme configurations
│   │   ├── database/               # SQLite database, schema migrations, DAOs
│   │   ├── services/               # Artwork, permissions, file helpers
│   │   └── utils/                  # Formatters, audio helpers, error handling
│   ├── models/                     # Song, Album, Artist, Playlist, MusicFolder
│   ├── features/
│   │   ├── home/                   # Quick access grid, recently added/played
│   │   ├── scanner/                # Android MediaStore & iOS audio discovery
│   │   ├── library/                # Songs, albums, artists, folders tabs
│   │   ├── player/                 # Audio engine, queue, Now Playing, Mini-Player
│   │   ├── playlists/              # Playlist CRUD & tracks management
│   │   ├── favorites/              # Persistent favorites
│   │   ├── search/                 # Offline real-time local search
│   │   ├── equalizer/              # Audio settings & equalizer presets
│   │   ├── lyrics/                 # Local LRC and embedded lyrics parser
│   │   └── settings/               # App configuration, scan filters, cache
│   ├── navigation/                 # Bottom navigation bar & routing
│   └── shared/                     # Reusable UI widgets (cards, tiles, states)
```

---

## 📱 Permissions Setup

### Android (`android/app/src/main/AndroidManifest.xml`)
- `READ_MEDIA_AUDIO` (Android 13+ / API 33+)
- `READ_EXTERNAL_STORAGE` (Android 12 and below)
- `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (Android 14+)
- `WAKE_LOCK` (Prevents CPU sleep during playback)

### iOS (`ios/Runner/Info.plist`)
- `NSAppleMusicUsageDescription` (Permission to access your local music library)
- `UIBackgroundModes`: `audio` (Allows background playback while locked or minimized)
- `UIFileSharingEnabled` & `LSSupportsOpeningDocumentsInPlace` (Enables Files app document importing)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.24.0)
- Dart SDK (>= 3.5.0)
- Android Studio / Android SDK (API 34)
- Xcode (for iOS builds)

### Installation & Run

1. Clone or navigate to the repository:
   ```bash
   cd MSGX
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run static analysis:
   ```bash
   flutter analyze
   ```

4. Run automated tests:
   ```bash
   flutter test
   ```

5. Launch on a connected device / emulator:
   ```bash
   flutter run
   ```

---

## 📦 Building for Release

### Android APK / App Bundle
```bash
flutter build apk --release
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 📄 License
MSGX is distributed under the MIT License.
