# FLUTTER DEVELOPMENT ROADMAP & IMPLEMENTATION PLAYBOOK
## (나야~ 마스터 Flutter 개발 이관 로드맵 및 실구현 핸드오버 플레이북)

본 명세서는 "나야~" 플랫폼을 **Flutter/Dart**로 재구축하기 위한 6 단계 세부 개발 타임라인입니다.  
Wearable 디바이스 (Wear OS/watchOS) 는 기존 Kotlin/Swift 로 유지하고, 모바일 클라이언트만 Flutter 로 통합합니다.

---

## 📅 1. 12 주 완결형 마스터 개발 로드맵 (Flutter + React Implementation WBS)

```
[12 주 Flutter+React 개발 WBS 로드맵]
Week 1-2   : 1 단계 - DB 설계 및 백엔드 REST API 게이트웨이 구축 ➔ SQLCipher, 벌크 시딩
Week 3-4   : 2 단계 - 스마트워치 BLE 컴패니언 및 저전력 센서 가동 ➔ 가속 STILL, 30 초 PPG 샘플링
Week 5-6   : 3 단계 - Flutter OS별 백그라운드 침투 및 락 오버레이 ➔ Android SystemAlert, iOS LiveActivity
Week 7-8   : 4 단계 - AI 음성 복제 구두동의 및 에피소드 스토리 결합 ➔ OTP Replay Liveness, BERT 0.85 필터
Week 9-10  : 5 단계 - 중독성 게이미피케이션 및 주말 ESL 프리토킹 ➔ 8bit 효과음, 이중 햅틱, AI Linter
Week 11-12 : 6 단계 - React 어드민 대시보드 구축 ➔ 10x100 열지도, 원격 Resolve 집행자
```

### 🛠️ 단계별 마스터 개발 사양 (Milestones)

#### 1 단계: Database & Core REST Gateway Setup (1~2 주차)
- **Flutter 작업**: 
  - `sqflite` 또는 `drift`로 SQLite DB 연동 및 SQLCipher 암호화 플러그인 (`sqflite_sqlcipher`) 탑재
  - `http`/`dio`를 통한 백엔드 API 게이트웨이 구현
  - 4 과목 학습 자산 벌크 시딩 스크립트 작성
- **참고 기획서**: [DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md), [API_SPECIFICATION.md](docs/API_SPECIFICATION.md)

#### 2 단계: Wearable BLE Companion & Hybrid Sensing (3~4 주차)
- **Flutter 작업**: 
  - `flutter_blue_plus`를 통한 BLE GATT 서비스 연결 (`9E150000-B5A2-43E3-8F43-7D15A206079E`)
  - 가속도계/자이로 센서 데이터 실시간 수신 및 STILL 모션 판독 엔진 구현
  - PPG 광학 센서 하이브리드 샘플링 (STILL >10 분 시 30 초만 활성화)
- **참고 기획서**: [DYNAMIC_TRIGGER_PLAYBOOK.md](docs/DYNAMIC_TRIGGER_PLAYBOOK.md), [SYSTEM_ARCHITECTURE.md](docs/SYSTEM_ARCHITECTURE.md)

#### 3 단계: OS-level Background Penetration & Overlays (5~6 주차)
- **Flutter 작업**: 
  - *Android*: `SYSTEM_ALERT_WINDOW` 권한 및 `ZombieOverlayActivity` Flutter 플러그인 구현
  - *iOS*: `Live Activities` 위젯 연동 및 Rich Notification Action 플러그인 개발
  - *CarPlay*: 차량 BLE 연결 및 GPS 시속 15km/h 감지 시 Driving Blackout 모드 구현
- **참고 기획서**: [DRIVING_MODE_SPEC.md](docs/DRIVING_MODE_SPEC.md), [SYSTEM_ARCHITECTURE.md](docs/SYSTEM_ARCHITECTURE.md)

#### 4 단계: AI Cloned Voice Consent & Spaced narrative (7~8 주차)
- **Flutter 작업**: 
  - ElevenLabs TTS API 연동 및 음성 복제 동의 플로우 구현
  - GPT-4o Chat Completions API 를 통한 주말 프리토킹 기능 개발
  - Sentence-BERT 유사도 필터 (0.85 임계치) 및 스토리 스티처 엔진 결합
- **참고 기획서**: [SECURITY_PRIVACY_SPEC.md](docs/SECURITY_PRIVACY_SPEC.md), [AI_CONTENT_GENERATION_MODEL.md](docs/AI_CONTENT_GENERATION_MODEL.md), [WEEKEND_FREETALK_MODEL.md](docs/WEEKEND_FREETALK_MODEL.md)

#### 5 단계: Dopamine Gamification & Weekend ESL Linter (9~10 주차)
- **Flutter 작업**: 
  - 정답 판정 시 8 비트 효과음 (`audioplayers` 플러그인) 및 이중 햅틱 (`vibration`) 구현
  - 오답노트 감지용 ESL Linter (be 동사 누락, 3 인칭 -s 누락 등) 탑재
- **참고 기획서**: [GAMIFICATION_PSYCHOLOGY_SPEC.md](docs/GAMIFICATION_PSYCHOLOGY_SPEC.md), [WEEKEND_FREETALK_MODEL.md](docs/WEEKEND_FREETALK_MODEL.md)

#### 6 단계: React Admin Dashboard & Remote Resolutions (11~12 주차)
- **React 작업**: 
  - Royal Purple HSL 테마 (`hsl(260, 25%, 8%)` 배경, `hsl(270, 85%, 65%)` 네온 퍼플 액센트) 적용
  - 10x100 마이크로 열지도 그리드 렌더링 (🟢 정상/🟡 경보/🔴 장애 상태)
  - 10 대 특화 군집 선택 패널 (실버 어르신, ADHD 아동, 지하철 직장인, CarPlay 운전 등)
  - 원격 해결 액션 버튼 구현 (Token Flush, Low-Power Switch, Voice Re-generate 등 5 가지)
- **참고 기획서**: [ADMIN_DASHBOARD_SPEC.md](docs/ADMIN_DASHBOARD_SPEC.md), [COHORT_DASHBOARD_SPEC.md](docs/COHORT_DASHBOARD_SPEC.md), [ADVANCED_DASHBOARD_COHORT_SPEC.md](docs/ADVANCED_DASHBOARD_COHORT_SPEC.md)

---

## 🗺️ 2. Flutter + React 디렉토리 구조 및 파일 매핑 지도

```
Naya/
├── docs/                    # 스탠다인드 설계 문서 (변경 금지)
│   ├── SYSTEM_ARCHITECTURE.md      # 3-tier 아키텍처 + 10 GAN Shields
│   ├── DATABASE_SCHEMA.md          # SQLite DDL + SM-2 알고리즘
│   ├── API_SPECIFICATION.md        # REST endpoints + ElevenLabs/GPT-4o specs
│   ├── SECURITY_PRIVACY_SPEC.md    # 음성 복제 동의, 하드웨어 암호화
│   ├── DEVELOPMENT_ROADMAP.md      # 12 주 WBS (이 파일)
│   └── [feature]_*_SPEC.md         # 기능별 설계서
├── mobile_flutter/          # Flutter/Dart 클라이언트 코드 (새로 생성)
│   ├── lib/
│   │   ├── main.dart                    # 앱 진입점
│   │   ├── screens/                     # UI 화면들
│   │   │   ├── ZombieOverlayScreen.dart  # 잠금화면 오버레이
│   │   │   ├── WeekendFreeTalkScreen.dart # 주말 프리토킹
│   │   │   └── QuizSubmitScreen.dart     # 퀴즈 제출 화면
│   │   ├── services/                    # 비즈니스 로직
│   │   │   ├── sm2_scheduler.dart       # SM-2 복습 스케줄러
│   │   │   ├── elevenlabs_tts.dart      # ElevenLabs TTS 클라이언트
│   │   │   └── openai_chat.dart         # GPT-4o 챗 API 클라이언트
│   │   ├── native/                      # 네이티브 플러그인 (platforms/)
│   │   │   ├── android/                 # Android 네이티브 코드
│   │   │   │   └── system_alert_window.kt  # System Alert Window 구현
│   │   │   └── ios/                     # iOS 네이티브 코드
│   │   │       └── live_activities.swift    # Live Activities 구현
│   │   └── utils/                       # 유틸리티
│   │       ├── dopamine_haptic.dart     # 8bit 효과음 + 이중 햅틱
│   │       └── offline_cache.dart       # SQLCipher 오프라인 캐시
│   ├── pubspec.yaml                     # Flutter 의존성 관리
│   └── test/                            # 테스트 코드
├── wearable/                # Wear OS Kotlin (기존 유지)
├── wearable-watchos/        # Apple Watch Swift (기존 유지)
├── server/                  # Node.js Express 백엔드
└── admin-web/               # React 관리자 대시보드 (새로 생성)
    ├── package.json                 # 의존성 관리
    ├── src/
    │   ├── components/              # UI 컴포넌트들
    │   │   ├── CohortHeatmapGrid.tsx      # 10x100 마이크로 열지도
    │   │   ├── UserMetricsCard.tsx        # 사용자 지표 카드
    │   │   └── ResolutionActions.tsx      # 원격 해결 액션 버튼
    │   ├── pages/                   # 페이지들
    │   │   ├── DashboardPage.tsx       # 메인 대시보드
    │   │   ├── CohortSelectionPage.tsx  # 군집 선택 패널
    │   │   └── UserDetailPage.tsx      # 사용자 상세 분석
    │   ├── services/                # API 서비스
    │   │   ├── adminApi.ts           # /api/admin/* 엔드포인트 클라이언트
    │   │   └── telemetryService.ts    # 실시간 텔레메트리 구독
    │   ├── styles/                  # 스타일 및 테마
    │   │   └── royalPurpleTheme.ts   # Royal Purple HSL 테마 정의
    │   └── App.tsx                  # 앱 진입점
    ├── public/                      # 정적 자산
    │   └── index.html
    └── vite.config.ts               # 빌드 설정
```

---

## ⚡ 3. Flutter + React 개발 바이브 치트시트 (Cheat-Sheet)

### 🔢 A. SuperMemo-2 (SM-2) 알고리즘 Dart 포팅
```dart
// Spaced Repetition Core Algorithm for SQLite/JSON syncing
class SM2Scheduler {
  Future<Map<String, dynamic>> calculateSM2({
    required int quality,
    required int prevReps,
    required double prevEF,
  }) async {
    var reps = prevReps;
    var ef = prevEF;
    var intervalDays = 1;

    if (quality >= 3) { // Correct answer
      if (reps == 0) intervalDays = 1;
      else if (reps == 1) intervalDays = 6;
      else intervalDays = (intervalDays * ef).round();
      reps += 1;
    } else { // Incorrect - reset
      reps = 0;
      intervalDays = 1;
    }

    // EF calculation formula
    ef = ef + (0.1 - (5 - quality) * (0.8 + (5 - quality) * 0.2));
    if (ef < 1.3) ef = 1.3;

    return {
      'reps': reps,
      'intervalDays': intervalDays,
      'easinessFactor': ef,
    };
  }
}
```

### 📶 B. BLE Wearable Service 연결 (flutter_blue_plus)
```dart
// Connect to wearable device with GATT service UUID
final ble = BluetoothAdapter();
ble.startDeviceDiscovery();

ble.deviceFound.listen((device) async {
  if (device.id == 'wearable-device-id') {
    final client = await ble.connectToDevice(device.id, timeout: const Duration(seconds: 5));
    
    // Connect to HEART_RATE_MEASUREMENT characteristic
    final hrService = await client.getServices();
    final hrChar = await hrService.getServiceById('9E150001-B5A2-43E3-8F43-7D15A206079E');
    
    // Subscribe to notifications
    await hrChar?.subscribeFromCharacteristic();
  }
});
```

### 💬 C. GPT-4o Structured Output Schema (OpenAI Dart SDK)
```dart
// Weekend FreeTalk conversation with structured JSON output
class OpenAIBuddyService {
  Future<Map<String, dynamic>> generateBuddyReply({
    required String userInput,
    required String focusScore,
    required String fatigueIndex,
    required String memoryRetention,
  }) async {
    final response = await openai.chat.completions.create(
      model: 'gpt-4o',
      messages: [
        {
          'role': 'system',
          'content': '''
            You are Naya~ personalized content generator.
            Target User is currently evaluated as Focus Profile Vector:
            [Focus Score: $focusScore/100, Fatigue Index: $fatigueIndex/100, Memory Retention: $memoryRetention/100].
            
            Adapt instructions:
            - If Fatigue Index > 70: output strictly 3 words max (enum: ULTRA_SHORT_PUNCHY).
            - If Memory Retention < 50: inject hilarious Korean mnemonic association in the JSON "supplementary_mnemonic" field.
          '''
        },
        {'role': 'user', 'content': userInput},
      ],
      response_format: {'type': 'json_schema'},
    );

    // Parse structured JSON output
    final jsonStr = response.choices.first.message.content;
    return jsonDecode(jsonStr);
  }
}
```

### 🎨 D. React Admin Dashboard Royal Purple Theme
```typescript
// src/styles/royalPurpleTheme.ts
export const royalPurpleTheme = {
  colors: {
    background: 'hsl(260, 25%, 8%)',
    card: 'hsl(260, 20%, 14%)',
    primaryAccent: 'hsl(270, 85%, 65%)',
    warningAccent: 'hsl(38, 95%, 55%)',
    criticalAlert: 'hsl(0, 90%, 55%)',
    fontColor: 'hsl(0, 0%, 95%)',
  },
  fontFamily: 'Outfit, sans-serif',
};

// src/components/CohortHeatmapGrid.tsx
const HeatmapGrid = ({ users }: { users: User[] }) => (
  <div className="grid grid-cols-10 gap-2">
    {users.map((user) => (
      <div
        key={user.id}
        className={`w-3 h-3 rounded-full cursor-pointer hover:scale-150 transition-transform`}
        style={{ backgroundColor: user.status === 'normal' ? '#10b981' : user.status === 'warning' ? '#f59e0b' : '#ef4444' }}
        title={`${user.name}: ${user.error?.message || 'No error'}`}
      />
    ))}
  </div>
);
```

### 🔧 E. Admin Remote Resolution API Service
```typescript
// src/services/adminApi.ts
export const adminApi = {
  // Get dashboard metrics
  async getMetrics(): Promise<DashboardMetrics> {
    const response = await fetch('/api/admin/metrics');
    return response.json();
  },

  // Resolve user error remotely
  async resolveUser(userId: string, action: ResolutionAction): Promise<void> {
    await fetch('/api/admin/users/resolve', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ userId, resolution_action: action }),
    });
  },

  // Get cohort status
  async getCohortStatus(): Promise<CohortStatus[]> {
    const response = await fetch('/api/admin/cohorts/status');
    return response.json();
  },
};

type ResolutionAction = 
  | 'TOKEN_FLUSH'
  | 'LOW_POWER_SWITCH'
  | 'VOICE_REGENERATE'
  | 'THRESHOLD_TUNER'
  | 'VOICE_BYPASS';
```

---

## ⚠️ 4. Flutter + React 개발 시 주의사항

- ❌ **docs/ 디렉토리 수정 금지** - 설계 문서는 불변 (immutable)
- ❌ **네이티브 기능은 JS 코어로 직접 구현하지 않기** - 플러그인 사용
- ❌ **생체 데이터에 PII 포함하지 않기** - UUID 만 매핑 (zero PII policy)
- ❌ **음성 복제 동의 프로пуск스킵 금지** - 법적 요구사항
- ✅ **오프라인 모드 항상 대비하기** - `NetInfo.isConnected` 체크
- ✅ **Admin API 인증 토큰 관리** - `/api/admin/*` 엔드포인트는 admin-only 인증 필요

---

## 🧪 5. Flutter + React 테스트 전략

### Flutter Mobile Tests
- Wearable BLE 테스트: 물리적 디바이스 또는 시뮬레이터 필요 (`flutter_blue_plus` 시뮬레이션)
- 오프라인 모드 테스트: Mock 네트워크 상태 (`Mockito` + `http`)
- 음성 복제 동의 테스트: 실제 마이크 입력으로 Liveness 검증

### React Admin Dashboard Tests
- Unit tests: Jest + React Testing Library
- Integration tests: Playwright for end-to-end admin workflow
- API mock: MSW (Mock Service Worker) for `/api/admin/*` endpoints

---

## 🛡️ 4. 10 대 GAN Refined Shields (Flutter Implementation Checklist)

| Shield | Flutter 구현 전략 | 플러그인/기술 |
|--------|------------------|---------------|
| **Audio Focus Interdict** | `AUDIOFOCUS_LOSS_TRANSIENT` 감지 시 TTS 일시정지 | `audio_service`, `audioplayers` |
| **SQLCipher Offline Cache** | 3 일치 학습 데이터 사전 캐싱 + 네트워크 폴백 | `sqflite_sqlcipher`, `workmanager` |
| **Annoyance Cap Controller** | 팝업 연속 2 회 닫기 시 4 시간 알림 비활성화 | `flutter_local_notifications` |
| **Sleep Mode Filter** | STILL >10 분 + HRV HF spike 감지 시 뮤트 | `flutter_blue_plus`, `sensors_plus` |
| **Driving Blackout** | CarPlay/GPS >15km/h 감지 시 화면 암전 | `carplay_flutter`, `geolocator` |
| **Teenager Locker** | GPS 지오펜싱 (50m) 내 닫기 버튼 비활성화 | `geofence_plus` |
| **Silent Haptic Mode** | 70dB 초과 시 볼드 텍스트 + 강진동 전환 | `noise_decibel`, `vibration` |
| **Secure Enclave/Keystore** | 하드웨어 암호화 키 관리 | `local_auth`, `flutter_secure_storage` |
| **Child Safety Filter** | 아동 트랙 감지 시 ElevenLabs 대신 녹음 음성 사용 | 커스텀 플러그인 |
| **Low-Power Hybrid Sampling** | STILL >10 분 시 PPG 30 초만 활성화 | `flutter_blue_plus` |

---

## 🎨 4. React Admin Dashboard Royal Purple Theme

관리자 포탈은 사용자 앱의 에메랄드 테마와 대비되는 **Royal Purple 및 Neon Amber** 컬러셋을 통해 고도로 숙련된 시스템 운영 관제의 전문성을 강조합니다.

### 🎨 HSL Color Palette
- **Background (심해 퍼플)**: `hsl(260, 25%, 8%)`
- **Card / Surface (미드나잇 바이올렛)**: `hsl(260, 20%, 14%)`
- **Primary Accent (네온 퍼플)**: `hsl(270, 85%, 65%)`
- **Warning Accent (네온 엠버)**: `hsl(38, 95%, 55%)`
- **Critical Alert (사이버 크림슨)**: `hsl(0, 90%, 55%)`
- **Font Color**: `hsl(0, 0%, 95%)`

### 👁️ UI Typography
- **Google Fonts (Outfit)** 적용을 통한 세련되고 현대적인 대시보드 그리드 선감 극대화.

## 🛠️ 5. 어드민 원격 해결 조치 API 규격 (Remote Resolutions)

대시보드에서 이상 징후가 감지된 사용자 혹은 코호트를 대상으로 관리자가 직접 날려 보낼 수 있는 **원격 수리 API 명령어 규격**입니다.

### 🛠️ 5 대 원격 복구 파이프라인 명세 (5 Action Commands)

| 장애 유형 코드 | 진단 현상 (Telemetry) | 대시보드 경보 | 어드민 복구 버튼 액션명 (Resolution Action) |
| :---: | :--- | :---: | :--- |
| **ERR_AUTH_SYNC** | 가입 및 로그인 시 BLE 통신 단절 및 토큰 불일치 | 🔴 CRITICAL | **[원격 토큰 리셋]** |
| **ERR_AUDIO_FOCUS** | Doze 강제 킬 및 CarPlay 오디오 점유 이탈 | 🔴 CRITICAL | **[저전력 모드 강제 복구]** |
| **ERR_VOICE_CLONE** | ElevenLabs 음성 지연 및 복제 가중치 파손 | 🟠 WARNING | **[음성가중치 재동기화]** |
| **ERR_VOCAB_DUP** | Sentence-BERT 중복 유사도 기준치 초과 | 🟠 WARNING | **[유사도 임계치 동적 조율]** |
| **ERR_MIC_BLOCKED** | 주말 톡 중 STT 마이크 차단 및 음성 유실 | 🟡 WARNING | **[임시 기본 프로 성우 우회]** |

## 🗄️ 6. 데이터베이스 스키마 확장 정의 (Telemetry Error Logs)

사용자 가입, 로그인 상태 및 장애 이력을 로깅하고 치료 시간을 체크하기 위한 관계형 테이블 컬럼 확장 규격입니다.

```sql
-- 사용자 여정 및 텔레메트리 장애 현황 로그 테이블
CREATE TABLE IF NOT EXISTS telemetry_error_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    event_type TEXT NOT NULL,          -- AUTH_SIGNUP, RUNTIME_OS, CONTENT_FREETALK 등
    error_code TEXT NOT NULL,          -- ERR_AUTH_SYNC, ERR_VOCAB_DUP 등
    error_message TEXT,
    stress_level_at_error REAL,        -- 장애 발생 당시 심박/RMSSD 기반 추정 스트레스
    status TEXT DEFAULT 'ACTIVE',      -- ACTIVE: 미해결, RESOLVED: 원격 치료 완료
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    resolution_action TEXT             -- TOKEN_FLUSH, VOICE_BYPASS 등 실행된 어드민 조치
);

-- 기존 user_profiles 테이블에 원격 조치 바인딩을 위한 상태 필드 보강
ALTER TABLE user_profiles ADD COLUMN active_error_state TEXT DEFAULT 'NORMAL'; -- NORMAL, FAULT
```

## 🔌 7. 관리자 분석 및 원격 제어 REST API 명세 (Admin API Spec)

### 📈 1. 실시간 대시보드 통계 메트릭 수집
- **Endpoint**: `GET /api/admin/metrics`
- **Response**:
```json
{
  "total_active_users": 1024,
  "average_spaced_retention": 84.6,
  "active_critical_errors": 3,
  "cumulative_token_cost_usd": 12.85,
  "elevenlabs_average_latency_ms": 780,
  "recent_telemetry_errors": [
    {
      "log_id": 482,
      "user_id": "u_001_minjun",
      "event_type": "AUTH_SIGNUP",
      "error_code": "ERR_AUTH_SYNC",
      "status": "ACTIVE"
    }
  ]
}
```

### 🛠️ 2. 사용자 장애 원격 해결 명령어 전송
- **Endpoint**: `POST /api/admin/users/resolve`
- **Request**:
```json
{
  "user_id": "u_001_minjun",
  "resolution_action": "TOKEN_FLUSH"
}
```

### 📊 3. 군집별 실시간 상태 조회
- **Endpoint**: `GET /api/admin/cohorts/status`
- **Response**:
```json
{
  "timestamp": 1780005000,
  "cohorts": [
    {
      "cluster_id": "C01",
      "cluster_name": "Silver 어르신군",
      "total_count": 100,
      "emerald_normal": 94,
      "amber_warning": 5,
      "crimson_critical": 1
    }
  ]
}
```

## 📋 8. 10 대 특화 군집별 진단 위젯 (Cohort Metrics)

| 군집 ID | 명칭 | 주요 KPI 위젯 |
| :---: | :--- | :--- |
| **C01** | 실버 어르신군 | 노안 고대비 모드 활성율, 치매 예방 배지 수량 |
| **C02** | ADHD 아동 | 요술봉 파티클 반응율, 칭찬 캔디 전송 건수 |
| **C03** | 지하철 직장인 | 저주파 필터링 레벨 (dB), 학습 스트릭 일수 |
| **C04** | CarPlay 운전자 | CarPlay LE 페어링 정합성, 오디오 Ducking 레벨 |
| **C05** | 굉장한 소음 근로자 | 현장 데시벨 평균, 시각 자막 전환 횟수 |
| **C06** | 접근성 장애 학습자 | VoiceOver 터치 로그 수율, 더블 탭 정합성 |
| **C07** | 야간 교대근무군 | 스마트워치 수면 HRV 판독 수율, Mute 스위칭 수율 |
| **C08** | 가사 전담 주부군 | STILL 모션 감지율, 마트 지오펜싱 입점 성공 수율 |
| **C09** | 주의산만 중고생 | 독서실 GPS 차단율, 락 가동 수율 |
| **C10** | 보안 위협 금융 타겟군 | OTP 성공률, Secure Enclave 키 감수성 |

---

## ⚡ 3. Flutter 개발 바이브 치트시트 (Cheat-Sheet)
