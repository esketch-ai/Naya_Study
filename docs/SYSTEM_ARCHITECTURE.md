# MASTER SYSTEM ARCHITECTURE DEFINITION
## (10대 GAN 방어막이 통합된 마스터 시스템 아키텍처 명세서)

본 문서는 "나야~" 및 후속 확장 시리즈 플랫폼의 클라이언트 앱, 웨어러블 디바이스, 백엔드 서버 간의 상호작용 및 운영체제(OS) 네이티브 백그라운드 제어 사양을 정의하는 최상위 시스템 설계도입니다. 

특히 1,000인 군집 GAN(생성형 적대 시스템) 검증을 거쳐 도출된 **10대 치명적 결함 방어 실드(GAN Refined Shields)**를 시스템 아키텍처 코어 레이어에 무결하게 통합하여 기술 사양을 대폭 고도화했습니다.

---

## 🛰️ 1. 하이레벨 3-Tier 분산 시스템 개요

```
+---------------------------------------------------------------------------------+
|                                 WEARABLE DEVICE                                 |
|   [Wear OS (Kotlin / Compose)]             [Apple Watch (SwiftUI / WatchOS)]    |
|   - PPG Sensor Reader (HR / HRV)           - CoreBluetooth Peripheral Service   |
|   - STILL Motion Engine (가속도/자이로)     - Sleep State HRV Telemetry Engine  |
+---------------------------------------------------------------------------------+
                                      |
                             Bluetooth LE (BLE)
                                      v
+---------------------------------------------------------------------------------+
|                                 MOBILE CLIENT                                   |
|   [React Native / Expo Cross-Platform Framework]                                |
|   +-------------------------------------------------------------------------+   |
|   | Native Bridge Layer (OS-Level Services & GAN Shields)                   |   |
|   | - Android: System Alert Window, AudioFocusManager, Decibel Meter, GPS   |   |
|   | - iOS: Rich Notifications, ActivityKit (Live Activities), CarPlay Core  |   |
|   | - Security: Secure Enclave / Keystore Hardware Cryptography Wrapper    |   |
|   +-------------------------------------------------------------------------+   |
|   | Core App Engine (React Native JS)                                       |   |
|   | - WebSpeech Speech-to-Text (STT) & Text-to-Speech (TTS) Modules         |   |
|   | - State Binder (Dynamic Voice Switcher based on Biometric logs)         |   |
|   | - Local Offline SQLCipher Cache DB                                      |   |
|   +-------------------------------------------------------------------------+   |
+---------------------------------------------------------------------------------+
                                      |
                            HTTPS RESTful & WebSockets
                                      v
+---------------------------------------------------------------------------------+
|                                CLOUD AI BACKEND                                 |
|   [Node.js / Express Server & PostgreSQL]                                       |
|   - SuperMemo-2 Spaced Repetition Scheduler (망각곡선 학습 분배기)               |
|   - OpenAI GPT-4o API Gateway (Dynamic Prompt Injector, 3-Line Summary Stitch)  |
|   - ElevenLabs TTS & Voice Cloning API Wrapper (Consented Voice Generation)     |
+---------------------------------------------------------------------------------+
```

---

## 🛡️ 2. 10대 GAN 통합 방어 실드 아키텍처 (10 GAN Refined Shields)

사용자의 다양한 라이프사이클과 예외 환경 속에서 시스템의 안정성, 보안성 및 편의성을 수호하기 위해 설계된 핵심 네이티브 파이프라인 규격입니다.

### 🔇 1. 오디오 포커스 인터딕션 (Audio Focus Interdict)
- **목적**: 사용자가 통화 중이거나 유튜브, 타 음악 앱을 사용하는 도중에 좀비 영어 TTS가 겹쳐 나와 청각 피로도를 악화시키는 간섭 현상을 완전히 차단합니다.
- **구현 메커니즘**:
  - **Android**: `AudioManager.OnAudioFocusChangeListener`를 기동하여 `AUDIOFOCUS_LOSS_TRANSIENT` 감지 시 즉시 좀비 플레이어를 일시정지(`pause()`)하고 무음 대기열로 상태를 전환합니다.
  - **iOS**: `AVAudioSession.interruptionNotification` 옵션을 구독하여 전화가 오면 TTS 엔진을 즉시 보류하고, 통화가 완전 종료된 후 3초 후에 리콜 팝업 형태로 부드럽게 지연 노출합니다.

### 💾 2. 로컬 SQLCipher 캐시 및 AAC 오프라인 엔진
- **목적**: 터널, 지하철 만원 차량, 지하 하수구 등 통신이 100% 두절되는 음영 지역에서도 학습 인터랙션과 TTS 재생이 끊김 없이 굴러가도록 합니다.
- **구현 메커니즘**:
  - 단말 로컬에 `SQLCipher`를 통한 암호화 DB 인스턴스를 유지하며, 최근 3일치 학습 단어 카드 시나리오와 기본 츤데레 오디오 효과음(AAC) 세트를 사전 캐싱(Prefetching)해 둡니다.
  - 디바이스의 네트워크 도달 가능성(`NetInfo`) 상태가 `false`로 변하면 클라우드 서버 요청을 즉각 바이패스하고, 로컬 디비와 단말 내장 내장 TTS(OS 기본 음성합성 엔진)로 즉시 Fallback 작동하여 에러 프리를 보장합니다.

### 🚫 3. Annoyance Cap Controller (피로 방지 캡)
- **목적**: 사용자가 중요한 업무를 보고 있거나 집중하고 있는 상황에서 팝업이 난사되는 것을 방지합니다.
- **구현 메커니즘**:
  - 좀비 팝업 노출 시 사용자가 볼륨 다운을 누르거나 팝업 창을 연속 2회 닫기/Mute 처리하는 행동을 감지하면, 백그라운드 스케줄러가 사용자의 거절 의사를 판독하여 **향후 4시간 동안 모든 자동 좀비 센서 알림 엔진을 강제 비활성화(Sleep Overlay Protection)** 시킵니다.

### 💤 4. 교대 근무자용 스마트 워치 수면 필터
- **목적**: 야간 교대근무자(간호사, 보안요원 등)가 주간에 취침하는 도중 수면을 방해하는 자동 알림 테러를 원천 차단합니다.
- **구현 메커니즘**:
  - 스마트워치 가속도 모션이 10분 넘게 정지(STILL) 상태일 때만 PPG 광학 센서를 깨워 심박 R-R 간격의 RMSSD 자율신경 지수를 판독합니다.
  - RMSSD의 고주파 대역 성분(HF)이 급증하고 심박이 기저 심박 이하로 떨어지는 수면 파형(Sleep HRV Wave)이 감지되면 단말기의 좀비 센서는 즉각 무음 뮤트 필터(`Sleep Mode Status: ACTIVE`)를 인지하고 기상을 판단할 때까지 모든 인터랙션을 올스톱시킵니다.

### 🚗 5. 세이프티 CarPlay & Android Auto 오디오 덕킹 핸즈프리
- **목적**: 운전 중 스마트폰 화면을 조작하여 발생하는 대형 교통사고 위험을 원천 예방하고 안전 주행을 수호합니다.
- **구현 메커니즘**:
  - 차량 블루투스 페어링(CarPlay/Android Auto) 및 GPS 시속 15km/h 이상 감지 시 즉시 **"안전 주행 다크 스크린 모드(Driving Blackout)"**를 실행하여 화면 터치 조작을 100% 차단합니다.
  - 차량의 내비게이션(Tmap 등) 오디오 가이드가 흘러나올 때 모바일 오디오 덕킹 상태 머신이 작동하여 Naya TTS 음량을 **자동으로 10% 수준으로 Ducking(낮춤)** 하고, 사용자의 답변은 운전대 마이크를 통한 오프라인 구두 발화로만 100% 핸즈프리 통과시킵니다.

### 🔒 6. 청소년 공부방 GPS 이탈 방지 안심 락 (Teenager Locker)
- **목적**: 주의가 산만하여 공부 도중 학습 알림 창을 칼같이 스킵하고 인스타그램, 유튜브, 게임 앱으로 도망치는 꼼수를 차단합니다.
- **구현 메커니즘**:
  - GPS 상 사전 설정된 학원, 독서실, 자습실 반경 50m 지오펜싱(Geofencing) 내부로 진입하면 청소년 락 모드(`Teenager_Lock_Active`)가 켜집니다.
  - 이 상태에서는 틈새 팝업 노출 시 **최소 30초 동안 닫기 버튼이 원천 활성화되지 않으며**, 오디오를 청취하고 따라 읽거나 화면 퀴즈 인터랙션을 통과하기 전까지 다른 엔터테인먼트 앱으로 스위칭할 수 없도록 OS 윈도우 포커스를 강제로 붙들어 맵니다.

### 🔊 7. 작업 현장 굉음 감지 무음 모드 스위처
- **목적**: 기계 소리, 지하철 정차 굉음, 공사장 진동 등 주변 소음이 심해 전혀 오디오를 들을 수 없는 환경에서 오디오를 억지로 재생하는 오작동을 피합니다.
- **구현 메커니즘**:
  - 마이크 데시벨 센서(`NoiseLevelMeter`)가 상시 1초 간격으로 주변 소음을 수집합니다.
  - 데시벨이 **70dB 초과(Heavy Ambient Noise)** 상태임을 감지하면, 즉각 오디오 음성 송출을 차단하고 대신 폰 본체와 스마트워치에 **"시각적 볼드 자막 텍스트 리더 및 굵고 강력한 진동(Silent Haptic Mode)"**으로 유연하게 스위칭하여 데드타임을 수확합니다.

### 🔑 8. 하드웨어 암호화 저장소 (Secure Enclave / Android Keystore)
- **목적**: 기기 분실, 루팅, 탈옥 시 발생할 수 있는 음성 복제 가중치 및 개인 데이터의 해킹 유출을 방지합니다.
- **구현 메커니즘**:
  - 로컬 캐시 디비는 `SQLCipher` 드라이버를 탑재해 전 구간 **AES-256-GCM** 암호화 처리를 적용합니다.
  - 복호화에 필요한 유일한 개인 대칭 키는 기기 내부의 물리적 안전 칩셋인 iOS의 **Secure Enclave ECC P-256 키 쌍**, Android의 **Keystore TEE(Trusted Execution Environment)** 바인딩 키로 보호되어 OS 커널 영역에서도 원천 탈취가 불가능합니다.

### 👼 9. 아동 보호 전문 성우 클라우드 필터 (Child Safety Filter)
- **목적**: 기계적인 합성음(TTS)이 아동 학습자에게 주는 '불쾌한 골짜기' 공포와 이질감을 지우고 정서적 친근함을 줍니다.
- **구현 메커니즘**:
  - 입력 벡터 상 아동 트랙(Kids Track, Level 1)이 감지되면 인공지능 ElevenLabs 합성 모델 대신, 미리 클라우드에 고음질 녹음 보관된 **전문 어린이 요정 성우의 오리지널 음성 어셋 데이터**만 추출하여 맞춤 서빙합니다.

### 🔋 10. 저전력 하이브리드 모션 센서 샘플링
- **목적**: 웨어러블 디바이스 및 스마트폰의 배터리를 하루 종일 실시간으로 파먹지 않고 최적의 효율로 유지합니다.
- **구현 메커니즘**:
  - 상시 저전력 자이로 및 가속도계만 켜두어 움직임의 주파수 대역을 판독하고, **완전 멈춤(STILL) 상태가 10분 이상 기록된 순간에 한하여** 30초 동안만 PPG 광학 센서를 반짝 켜서 맥박 수치를 수집한 뒤 즉시 Deep Sleep으로 돌려보냅니다. 이로써 웨어러블 배터리 유지 수명을 24시간 이상 추가 확보합니다.

---

## 🛰️ 3. 디바이스별 OS 네이티브 백그라운드 구동 흐름

### 🤖 Android: AlarmManager 및 System Alert Window 오버레이
안드로이드는 배터리 소모 차단을 위한 Doze 모드를 강제 우회하여 화면 잠금 상태에서도 좀비 학습 창을 송출해야 합니다.

1. **Doze 모드 우회 트리거**:
   - `AlarmManager.setExactAndAllowWhileIdle()`를 호출해 기기가 깊은 절전 상태(Deep Sleep)에 빠져도 정확한 시간에 Broadcast Receiver가 깨어나도록 제어합니다.
2. **잠금화면 오버레이 (System Alert Window)**:
   - `android.permission.SYSTEM_ALERT_WINDOW` 권한을 통해 다른 모든 앱과 잠금화면(Keyguard) 위에 학습 뷰인 `ZombieOverlayActivity`를 강제 드로잉합니다.
3. **화면 켬 감지 (Restroom & Idle trigger)**:
   - `ACTION_SCREEN_ON` 브로드캐스트 리시버를 동적으로 등록해 사용자가 기기를 켜는 시점을 실시간 포착하여 최근 틈새 학습 상태를 평가합니다.

### 🍏 iOS: Live Activities 위젯 및 푸시 알람 스위처
iOS의 샌드박스 보안 정책은 백그라운드 강제 화면 송출을 전면 금지하므로 다음 우회 아키텍처를 도입합니다.

1. **잠금화면 실시간 위젯 (Live Activities)**:
   - `ActivityKit` 프레임워크를 연동하여 사용자가 폰을 켜지 않아도 잠금화면 및 Dynamic Island 영역에 상시 10초 학습 카드를 렌더링합니다.
2. **풍부한 알림 (Rich Push Notification Actions)**:
   - `UNNotificationCategory` 및 `UNNotificationAction`을 활용하여 수신된 푸시 알림 안에서 앱을 켜지 않고 즉시 오디오 스피커 아이콘을 눌러 예문을 듣고 O/X 정답을 맞출 수 있는 무음 인터랙티브 뷰를 구성합니다.

---

## 📶 4. 스마트워치 블루투스 LE (BLE) 연동 GATT 규격

### 서비스 UUID: `9E150000-B5A2-43E3-8F43-7D15A206079E`

| Characteristic Name | UUID | Properties | Data Format | Description |
| :--- | :--- | :--- | :--- | :--- |
| **HEART_RATE_MEASUREMENT** | `9E150001-...` | Notify | `UINT8` | 실시간 수집된 BPM 값 (예: 76) |
| **HRV_RMSSD_VALUE** | `9E150002-...` | Notify | `FLOAT32` | 계산된 R-R 간격 RMSSD 값 (스트레스 평가용) |
| **DEVICE_ACTIVITY_STATE** | `9E150003-...` | Notify | `UINT8` | 0: STILL, 1: WALKING, 2: IN_VEHICLE, 3: SLEEP |

본 **마스터 시스템 아키텍처 명세서**는 10대 GAN 위협 방어막 설계를 영구 탑재하여, 어떠한 환경 조건의 사용자도 에러 없이 매끄럽게 학습 중독 상태로 정교하게 포섭합니다.
