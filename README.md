# FieldCheck

FieldCheck is a modern Flutter mobile app for capturing field inspection check-ins with a photo, GPS location, and note. Every record is stored locally with Hive so it remains available after restart.

## Features
- Create field check-ins with photo, note, and GPS coordinates
- View a history of saved check-ins on the home screen
- Open a detailed view for each saved check-in
- Handle camera and location permissions gracefully
- Store all data locally using Hive

## Architecture
- Provider for state management
- Hive for local persistence
- Clean separation between screens, providers, storage, models, and widgets

## Folder Structure
- lib/constants
- lib/models
- lib/providers
- lib/screens
- lib/services
- lib/storage
- lib/theme
- lib/utils
- lib/widgets

## Plugins Used
- image_picker
- geolocator
- permission_handler
- hive
- hive_flutter
- path_provider
- provider
- url_launcher

## How to Clone and Run This Project from GitHub

Follow these steps carefully to avoid setup issues.

### 1. Prerequisites
Before running the app, make sure you have the following installed:

- Git
- Flutter SDK compatible with Dart 3.12.2 or newer
- Android Studio (for Android emulator/device builds)
- Xcode (for iOS builds on macOS only)
- VS Code with the Flutter and Dart extensions (recommended)

You can verify your setup with:

```bash
git --version
flutter --version
flutter doctor
```

If `flutter doctor` shows problems, fix them before continuing. Common issues include:

- Flutter not added to your system PATH
- Android SDK not installed or not accepted
- Android licenses not accepted
- Xcode command line tools missing on macOS

### 2. Clone the Repository
Open a terminal and run:

```bash
git clone https://github.com/IrfanIman19/FieldCheck.git
cd FieldCheck
```

### 3. Install Project Dependencies
Run this inside the project folder:

```bash
flutter pub get
```

If you see dependency or package resolution errors, try:

```bash
flutter clean
flutter pub get
```

### 4. Run the App
Choose one of the following:

```bash
flutter run
```

### 5. Important Notes for This App
This project uses:

- camera access
- GPS/location access
- local storage with Hive

When you run the app, allow the required permissions on your device or emulator. If permissions are denied, the app may not work correctly.

### 6. Common Troubleshooting
- If Flutter says the SDK is not found, restart your terminal or reload your shell configuration.
- If Android build fails, run `flutter doctor --android-licenses` and accept the licenses.
- If package download errors happen, check your internet connection and try again.
- If the app does not launch, make sure a device or emulator is running.

### 7. Recommended Environment
For best compatibility, use a recent stable Flutter version that supports Dart 3.12.2 or newer.

## Screenshots Placeholders
- Home screen: history of saved check-ins
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/homescreen.jpeg

- check-in: camera, photo preview, GPS, note
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/check%20in.jpeg

- Detail screen: full record information
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/details%20preview.jpeg

## Video Placeholders
- Video Demo : full tutorial
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/DEMO.mp4

## Install APK
- FieldCheck.apk     
https://github.com/IrfanIman19/FieldCheck/blob/master/APK/FieldCheck.apk

## Requirements Checklist
- [x] Home / History screen
- [x] New check-in form
- [x] Detail screen
- [x] Local Hive storage
- [x] Camera and location permissions handling
- [x] Provider state management
- [x] Material 3 UI