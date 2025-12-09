# CSE489 LAB MIDTERM APP

App summary

- A compact Flutter application for recording, annotating, and reviewing landmarks on an interactive Google map. Users can capture their current location or pick coordinates on the map, add details for a landmark, and save or browse previously recorded entries — useful as a teaching/demo project for mobile mapping, location permissions, and simple local data storage.
- First build (v0.1) APK available: [First Build](https://github.com/ShariarShuvo1/cse489_lab_mid/releases/tag/0.1 "First Build")

Feature list

- Display map and preview coordinates
- Create new landmark entries with location
- View saved records
- Uses device location and Google Maps

Setup instructions

- Prerequisites: Flutter SDK, Android Studio
- Add your Google Maps API key to `android/local.properties` as:

  GOOGLE_MAPS_API_KEY=YOUR_KEY
- Install deps and run:

  flutter pub get
  flutter run # or `flutter build apk` to build

Known limitations

- Requires a valid Google Maps API key in `android/local.properties`
- Permissions and map features tested primarily on Android
- Limited error handling and input validation
