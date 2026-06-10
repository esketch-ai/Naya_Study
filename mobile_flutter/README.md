# Naya~ Mobile App (Flutter)

English learning app with Wearable BLE integration for heart rate monitoring and personalized learning.

## Features

- 📱 **Cross-platform**: Android & iOS support
- 🔗 **BLE Wearable Integration**: Connects to Naya wearable devices
- 💚 **Emerald Theme**: Beautiful Material Design 3 UI
- 🧠 **SM-2 Algorithm**: Spaced repetition for optimal learning
- 🎯 **10 GAN Refined Shields**: Privacy and safety features

## Setup Instructions

### Prerequisites

```bash
# Install Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

### Project Setup

```bash
cd mobile_flutter
flutter pub get
flutter clean
flutter build apk --debug  # For Android
flutter build ios --debug   # For iOS
```

## Running the App

### Android

```bash
flutter run -d <device-id>
# or
flutter run -d chrome
```

### iOS (macOS only)

```bash
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── card_model.dart       # Learning card data model
├── services/
│   ├── ble_service.dart      # BLE wearable connection
│   ├── learning_service.dart # API calls for learning content
│   └── database_service.dart # SQLite local storage
├── screens/
│   ├── home_screen.dart      # Main screen with BLE status
│   ├── learn_screen.dart     # Learning cards display
│   └── profile_screen.dart   # User settings
└── widgets/                  # Reusable UI components

android/                      # Android native code
ios/                          # iOS native code
```

## API Endpoints

- `GET /api/v1/learning/zombie-card` - Fetch learning cards
- `POST /api/v1/learning/quiz/submit` - Submit quiz answers
- `POST /api/wearable/log` - Send telemetry data

## BLE Service UUIDs

- **Service**: `9E150000-B5A2-43E3-8F43-7D15A206079E`
- **Heart Rate**: `9E150001-B5A2-43E3-8F43-7D15A206079E` (UINT8)
- **HRV RMSSD**: `9E150002-B5A2-43E3-8F43-7D15A206079E` (FLOAT32)

## Permissions Required

### Android
- Bluetooth (`BLUETOOTH`, `BLUETOOTH_ADMIN`)
- Location (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`)
- Background execution (`FOREGROUND_SERVICE`)

### iOS
- Bluetooth Central (`NSBluetoothAlwaysUsageDescription`)
- Location When In Use (`NSLocationWhenInUseUsageDescription`)

## Development Commands

```bash
# Hot reload
flutter run

# Build release APK
flutter build apk --release

# Build iOS app
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Troubleshooting

### Android Build Issues

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### iOS Build Issues

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

## Next Steps

1. Connect to Naya wearable device via BLE
2. Fetch learning cards from backend API
3. Submit quiz answers and track progress with SM-2 algorithm
4. Monitor heart rate data for stress detection

## License

MIT License - See LICENSE file for details.
