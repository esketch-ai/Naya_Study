# Naya - Cross-Platform Learning Platform

A 3-tier learning platform with Wear OS + Apple Watch companions, React Native mobile client, and Node.js backend.

## Architecture

```
┌─────────────┐     BLE GATT      ┌──────────────┐
│   Wearable  │ ───────────────→  │ Mobile Client│
│ (Watch/Phone)│                  │(React Native)│
└─────────────┘                   └──────────────┘
                                         ↓
                                    ┌──────────────┐
                                    │    Backend   │
                                    │  Node.js + SQL│
                                    └──────────────┘
```

## Tech Stack

- **Wear OS**: Kotlin + Compose
- **Apple Watch**: Swift + SwiftUI  
- **Mobile Client**: React Native/Expo
- **Backend**: Node.js + Express + SQLite (SQLCipher)
- **Admin Dashboard**: React with Royal Purple theme

## BLE Service UUIDs

- **Service**: `9E150000-B5A2-43E3-8F43-7D15A206079E`
- **Heart Rate**: `9E150001-B5A2-43E3-8F43-7D15A206079E` (UINT8, Notify)
- **HRV RMSSD**: `9E150002-B5A2-43E3-8F43-7D15A206079E` (FLOAT32, Notify)
- **Activity State**: `9E150003-B5A2-43E3-8F43-7D15A206079E` (UINT8, Notify)

## GAN Refined Shields (10 Critical Defect Shields)

1. ✅ **Audio Focus Interdict**: Pause TTS on audio focus loss
2. ✅ **SQLCipher Offline Cache**: Local encrypted DB with 3-day prefetch
3. ✅ **Annoyance Cap Controller**: Disable notifications for 4hrs if user mutes twice
4. ✅ **Sleep Mode Filter**: Detect STILL + HRV HF spike → mute interactions
5. ✅ **Driving Blackout**: CarPlay/GPS >15km/h → dark screen, TTS ducked to 10%
6. ✅ **Teenager Locker**: GPS geofence inside study location → disable close button for 30s
7. ✅ **Silent Haptic Mode**: Ambient noise >70dB → bold text + strong haptics only
8. ✅ **Secure Enclave/Keystore**: Hardware-backed encryption with biometric auth
9. ✅ **Child Safety Filter**: Kids track → use pre-recorded child voice actor, not ElevenLabs AI
10. ✅ **Low-Power Hybrid Sampling**: STILL >10min → wake PPG for 30sec only, then deep sleep

## Voice Cloning Consent Flow (4 Steps)

1. Generate dynamic challenge script with 6-digit OTP
2. User speaks full consent statement + OTP aloud
3. On-device liveness check: FFT analysis for replay attacks (18kHz+)
4. Store original consent audio in S3 Glacier for 5 years

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/profile` | GET/PUT | User settings |
| `/api/v1/learning/zombie-card` | GET | Fetch 3 daily zombie cards |
| `/api/v1/learning/quiz/submit` | POST | Submit quiz answers, update SM-2 intervals |
| `/api/wearable/log` | POST | Receive HRV/PPG telemetry from watch |

## Development Commands

```bash
# Backend
cd server && npm start

# Mobile (React Native)
npx expo start

# Wear OS (Wear OS)
cd wearable && ./gradlew assembleDebug

# Apple Watch (watchOS)
open wearable-watchos/watchOS\ App.xcodeproj
```

## Security & Compliance

- TLS 1.3 encryption for all transmissions
- UUID-only mapping (zero PII policy) for biometric data
- Hardware-backed encryption with user biometric auth required
- Voice cloning consent flow legally required
