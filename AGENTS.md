# Agent Guidance for Naya

## Architecture Overview

This is a **3-tier cross-platform learning platform**:
- **Wearables**: Wear OS (Kotlin/Compose) + Apple Watch (SwiftUI/WatchOS) - BLE GATT service `9E150000-B5A2-43E3-8F43-7D15A206079E`
- **Mobile Client**: React Native/Expo with native OS bridge layer (Android/iOS)
- **Cloud Backend**: Node.js/Express + PostgreSQL

## Tech Stack & Commands

### Setup
```bash
npm install
# No build step required - docs are standalone specs
```

### Development Commands
- Mobile: `npx expo start` or `react-native run-android` / `run-ios`
- Wearable (Wear OS): Gradle build in `/wearable/` directory
- Wearable (watchOS): Xcode project in `/wearable-watchos/`  
- Backend: `npm start` in `/server/`, migrations via SQL scripts

### Test Commands
Find test scripts in respective package.json files. No shared test framework configured yet.

## Directory Structure

```
Naya/
├── docs/                    # Standalone spec documents (source of truth)
│   ├── SYSTEM_ARCHITECTURE.md      # 3-tier architecture + 10 GAN Shields
│   ├── DATABASE_SCHEMA.md          # SQLite/PostgreSQL DDL + SM-2 algorithm
│   ├── API_SPECIFICATION.md        # REST endpoints + ElevenLabs/GPT-4o specs
│   ├── SECURITY_PRIVACY_SPEC.md    # Voice cloning consent, hardware encryption
│   ├── DEVELOPMENT_ROADMAP.md      # 12-week WBS with file mapping
│   └── [feature]_*_SPEC.md         # Feature-specific specs (GAN, driving mode, etc.)
├── mobile/                  # React Native Expo client code
├── wearable/                # Wear OS Kotlin (Kotlin + Compose)
├── wearable-watchos/        # Apple Watch Swift (watchOS framework)
├── server/                  # Node.js Express backend
└── admin-web/               # Admin dashboard (React?)
```

## Critical Architecture Patterns

### 1. Native OS Bridge Layer (Mobile Client)
The React Native app has a **native bridge layer** that handles:
- Android: `System Alert Window`, `AudioFocusManager`, `Decibel Meter`, GPS geofencing
- iOS: Rich Notifications, ActivityKit Live Activities, CarPlay Core

**Never modify the JS core directly for OS-level features** - they live in native modules.

### 2. Local Offline-First Design
- **SQLCipher encrypted SQLite** on device with AES-256-GCM
- Prefetches 3-day learning scenarios + AAC audio effects locally
- Falls back to local TTS when network unavailable (`NetInfo.isConnected === false`)

### 3. Hardware Security Boundaries
- iOS: Secure Enclave ECC P-256 keys for decryption
- Android: Keystore TEE with user biometric auth required
- All voice models/weights encrypted at rest

## Key Algorithms & Formulas

### SuperMemo-2 Spaced Repetition (SM-2)
```javascript
// Called on quiz submission /api/v1/learning/quiz/submit
function calculateSM2(quality, prevReps, prevEF) {
  let reps = prevReps;
  let ef = prevEF;
  let intervalDays = 1;

  if (quality >= 3) { // Correct answer
    intervalDays = reps === 0 ? 1 : reps === 1 ? 6 : Math.round(intervalDays * ef);
    reps += 1;
  } else { // Incorrect - reset
    reps = 0;
    intervalDays = 1;
  }

  // EF update formula
  ef = ef + (0.1 - (5 - quality) * (0.8 + (5 - quality) * 0.2));
  if (ef < 1.3) ef = 1.3;

  return { reps, intervalDays, ef };
}
```

### BLE Wearable Service UUIDs
- **HEART_RATE_MEASUREMENT**: `9E150001-B5A2-43E3-8F43-7D15A206079E` (UINT8, Notify)
- **HRV_RMSSD_VALUE**: `9E150002-B5A2-43E3-8F43-7D15A206079E` (FLOAT32, Notify)  
- **DEVICE_ACTIVITY_STATE**: `9E150003-B5A2-43E3-8F43-7D15A206079E` (UINT8, Notify)

## Security & Compliance Requirements

### Voice Cloning Consent Flow
**MUST implement this exact 4-step flow:**
1. Generate dynamic challenge script with 6-digit OTP
2. User speaks full consent statement + OTP aloud
3. On-device liveness check: FFT analysis for replay attacks (18kHz+ high freq)
4. Store original consent audio in S3 Glacier for 5 years

### Biometric Data Handling
- HRV/PPG data **ephemeral**: auto-delete after 48hrs once used for scheduling
- All telemetry uses UUID-only mapping (zero PII policy)
- TLS 1.3 encryption for all wearable→cloud transmissions

## GAN Refined Shields (Critical Features)

These are the **10 critical defect shields** that must be implemented:

1. **Audio Focus Interdict**: Pause TTS on `AUDIOFOCUS_LOSS_TRANSIENT` (Android) / interruption notification (iOS)
2. **SQLCipher Offline Cache**: Always maintain local encrypted DB with 3-day prefetch
3. **Annoyance Cap Controller**: Disable all notifications for 4hrs if user mutes/closes popups twice
4. **Sleep Mode Filter**: Detect STILL motion >10min + HRV HF spike → mute all interactions
5. **Driving Blackout**: CarPlay/Android Auto + GPS >15km/h → dark screen, TTS ducked to 10%
6. **Teenager Locker**: GPS geofence (50m radius) inside study location → disable close button for 30s
7. **Silent Haptic Mode**: Ambient noise >70dB → switch to bold text + strong haptics only
8. **Secure Enclave/Keystore**: Hardware-backed encryption with biometric auth required
9. **Child Safety Filter**: Kids track → use pre-recorded child voice actor, not ElevenLabs AI
10. **Low-Power Hybrid Sampling**: STILL >10min → wake PPG for 30sec only, then deep sleep

## API Endpoints (From API_SPECIFICATION.md)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/profile` | GET/PUT | User settings (wakeup/sleep time, voice preference) |
| `/api/v1/learning/zombie-card` | GET | Fetch 3 daily zombie cards for review |
| `/api/v1/learning/quiz/submit` | POST | Submit quiz answers, update SM-2 intervals |
| `/api/wearable/log` | POST | Receive HRV/PPG telemetry from watch |

## ElevenLabs TTS Integration

```javascript
// Voice settings adapt to user stress level (HRV RMSSD)
const voiceSettings = {
  stability: 0.4,        // Lower = more emotional range (lover/rockstar voices)
  similarity_boost: 0.8, // Closer to original cloned voice
  style: 0.6             // Enhance unique tone of cloned voice
};

// Stress threshold from user profile triggers voice switching
const stressThreshold = 75; // Default from user_profiles table
```

## OpenAI GPT-4o Structured Output Schema

For weekend free-talk conversations, enforce this JSON schema:

```json
{
  "buddy_reply_english": "string - Character's affectionate English response",
  "buddy_reply_korean": "string - Korean chat feedback in same tone", 
  "has_grammatical_error": "boolean - Did user make grammar mistakes?",
  "grammar_correction_tip": "string|null - Gentle correction if error exists"
}
```

## Development Workflow

1. **Read spec first**: Every feature has a corresponding `docs/*_SPEC.md` file
2. **Check DEVELOPMENT_ROADMAP.md** for current WBS milestone
3. **Use directory mapping table** in ROADMAP to find correct source files
4. **Verify against executable specs**: Config/docs > prose documentation

## Common Pitfalls to Avoid

- ❌ Don't modify `docs/` - these are immutable spec documents
- ❌ Don't implement OS-level features in pure React Native JS
- ❌ Don't store biometric data with PII (use UUID-only mapping)
- ❌ Don't skip voice cloning consent flow - it's legally required
- ❌ Don't forget offline fallback - always check `NetInfo.isConnected`

## Testing Notes

- Wearable tests require physical device or simulator with BLE support
- Offline mode tests: mock `NetInfo` to return `{ isConnected: false }`
- Voice cloning consent must be tested with actual microphone input for liveness detection
