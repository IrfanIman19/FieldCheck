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

## How to Run
1. Install Flutter SDK
2. Run `flutter pub get`
3. Run `flutter run`

## Screenshots Placeholders
- Home screen: history of saved check-ins
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/homescreen.jpeg

- check-in: camera, photo preview, GPS, note
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/check%20in.jpeg

- Detail screen: full record information
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/details%20preview.jpeg

## video Placeholders
- Video Demo : full tutorial
https://github.com/IrfanIman19/FieldCheck/blob/master/SCREENSHOT%26DEMO/DEMO.mp4

## Requirements Checklist
- [x] Home / History screen
- [x] New check-in form
- [x] Detail screen
- [x] Local Hive storage
- [x] Camera and location permissions handling
- [x] Provider state management
- [x] Material 3 UI

## Bonus Features
- Modern empty state and polished cards
