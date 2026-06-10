# ADMIN WEB ANALYTICS & RESOLUTION PORTAL
## (사용자 여정 로깅 및 이슈 해결 관리자 대시보드 기획 설계서)

본 명세서는 "나야~" 플랫폼을 이용하는 1,000인 이상 대단위 가상/실제 사용자의 **회원가입, 로그인, 디바이스 동기화, 실시간 사용량, 백그라운드 구동 장애, 콘텐츠 중복 및 프리토킹 이상 상황**을 전 방위로 수집(Telemetry)하고, 관리자 웹 대시보드에서 이를 정밀하게 포착하여 원터치로 **원격 해결(Remote Direct Resolutions)**을 집행할 수 있게 설계한 **관리자 분석 포탈 운영 설계서**입니다.

---

## 🛰️ 1. 사용자 여정 6대 지점 데이터 수집 규격 (Telemetry Data Schema)

사용자가 서비스에 가입하는 순간부터 주말 AI 회화를 마치는 시점까지의 전 여정을 감시하기 위해 단말기로부터 백엔드 수집 서버(`GET/POST /api/telemetry/log`)로 전송되는 데이터의 JSON 표준 스키마 계약입니다.

```
       [ USER APP CLIENT ]
 가입 -> 로그인 -> 구동 -> 학습 -> 주말 회화
   │        │        │        │        │
   └────────┴────────┼────────┴────────┘
                     v (JSON Telemetry Payload)
         [ TELEMETRY COLLECTOR ]
                     v
      [ SQLCipher DB / server Logs ]
```

### 📝 A. 가입 및 로그인 단계 (Auth & Sync Logs)
- **가입 시 음성 구두 서명 매칭 및 생체 기준값 동기화 실패 여부 수집**
```json
{
  "user_id": "u_001_minjun",
  "event_type": "AUTH_SIGNUP",
  "timestamp": 1780000000,
  "status": "FAILED",
  "metrics": {
    "voice_signature_liveness_score": 0.32,
    "otp_match": false,
    "baseline_hrv_rmssd": 0.00
  },
  "error_log": {
    "code": "ERR_VOICE_SPOOFING_DETECTED",
    "msg": "Replay attack high-frequency resonance detected (>18kHz). Spoofing blocked."
  }
}
```

### ⚙️ B. 앱 사용량 및 백그라운드 구동 단계 (Runtime Usage & OS Kill Logs)
- **OS 백그라운드Doze 강제 킬 및 CarPlay/Android Auto 오디오 포커스 이탈 수집**
```json
{
  "user_id": "u_004_carplay_jina",
  "event_type": "RUNTIME_OS_ANOMALY",
  "timestamp": 1780000120,
  "status": "CRITICAL",
  "metrics": {
    "os_battery_saving_active": true,
    "carplay_connected": true,
    "ambient_decibels": 45.2
  },
  "error_log": {
    "code": "ERR_AUDIO_FOCUS_LOSS_FORCE_KILLED",
    "msg": "AVAudioSession category interrupted by navigation stream but OS did not yield focus. App frozen."
  }
}
```

### 📚 C. 콘텐츠 및 프리토킹 사용 단계 (Content Transition & Free-Talk Logs)
- **Sentence-BERT 중복 유사도 임계치(0.85) 초과 어휘 생성 및 주말 STT/TTS 이상 수집**
```json
{
  "user_id": "u_008_silver_ocksoon",
  "event_type": "CONTENT_FREETALK_FAULT",
  "timestamp": 1780000240,
  "status": "WARNING",
  "metrics": {
    "gpt_response_time_ms": 2850,
    "sentence_bert_cosine_similarity": 0.89,
    "stt_mic_permission_granted": false
  },
  "error_log": {
    "code": "ERR_VOCAB_DUPLICATION_ALERT",
    "msg": "Generated vocabulary card similarity (0.89) exceeds safe limits. User in repetition loop."
  }
}
```

---

## 🎨 2. 프리미엄 관리자 비주얼 테마 시스템 (Royal Purple Theme)

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

---

## 🛠️ 3. 어드민 비상 원격 해결 조치 규격 (Direct Remote Resolutions)

대시보드에서 이상 징후가 감지된 사용자 혹은 코호트를 대상으로 관리자가 직접 날려 보낼 수 있는 **원격 수리 API 명령어 규격**입니다.

```
       [ ADMIN DASHBOARD ]
               │
   어드민 강제 해결 명령어 발동!
  (POST /api/admin/users/resolve)
               │
               ▼
       [ BACKEND GATEWAY ]
               │
    WebSocket / Push Notification
               │
               ▼
       [ USER APP CLIENT ]
  - Token Flush, DB Wipe, Bypass Pro Voice
```

### 🛠️ 5대 원격 복구 파이프라인 명세 (5 Action Commands)

| 장애 유형 코드 | 진단 현상 (Telemetry) | 대시보드 경보 | 어드민 복구 버튼 액션명 (Resolution Action) | 백그라운드 원격 치료 메커니즘 |
| :---: | :--- | :---: | :--- | :--- |
| **ERR_AUTH_SYNC** | 가입 및 로그인 시 BLE 통신 단절 및 토큰 불일치 | **🔴 CRITICAL** | **[원격 토큰 리셋 (Token Flush)]** | 대상 기기의 클라이언트 JWT 토큰 테이블을 무효화(`flush`)하고 컴패니언 컴패니언 워치 통신 채널에 재인증 신호를 자동 푸시함. |
| **ERR_AUDIO_FOCUS** | Doze 강제 킬 및 CarPlay 오디오 점유 이탈 | **🔴 CRITICAL** | **[저전력 모드 강제 복구<br>(Low-Power Switch)]** | 해당 기기의 배터리 도즈 최적화 제외 알림창을 강제 재오버레이하고 백그라운드 지속 포어그라운드 서비스 바인딩 재기동. |
| **ERR_VOICE_CLONE** | ElevenLabs 음성 지연 및 복제 가중치 파손 | **🟠 WARNING** | **[음성가중치 재동기화<br>(Voice Re-generate)]** | 복제 모델에 무효 플래그를 찍어 ElevenLabs 서버의 원본 구두 음성을 통해 오디오 복제 엔진을 강제 비동기 재컴파일함. |
| **ERR_VOCAB_DUP** | Sentence-BERT 중복 유사도 기준치 초과 | **🟠 WARNING** | **[유사도 임계치 동적 조율<br>(Threshold Tuner)]** | 해당 유저의 동적 필터 임계치를 일시적으로 낮추고(`0.85 ➔ 0.70`), 최근 중복 단어를 오답노트에서 소거하여 에셋 순환 복구. |
| **ERR_MIC_BLOCKED** | 주말 톡 중 STT 마이크 차단 및 음성 유실 | **🟡 WARNING** | **[임시 기본 프로 성우 우회<br>(Voice Bypass)]** | 복제 목소리 재생을 즉각 중단하고, 불쾌한 골짜기가 없는 클라우드 성우 녹음 라이브러리(`Pro_Vo_Voice`)로 오디오 통로를 임시 우회시킴. |

---

## 🗄️ 4. 데이터베이스 스키마 확장 정의 (Database DDL Upgrade)

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

---

## 🔌 5. 관리자 분석 및 원격 제어 REST API 명세 (REST API Spec)

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
      "error_message": "OTP challenge code mismatched on device u_001.",
      "status": "ACTIVE",
      "created_at": "2026-05-31T09:30:00"
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
  "log_id": 482,
  "resolution_action": "TOKEN_FLUSH"
}
```
- **Response**:
```json
{
  "success": true,
  "msg": "Remote direct resolution command [TOKEN_FLUSH] successfully pushed to client device u_001_minjun. Status resolved.",
  "resolved_at": "2026-05-31T09:37:00"
}
```

본 **관리자 분석 포탈 및 이슈 해결 명세서**는 1,000인 이상 대단위 사용자 여정 속의 실시간 가입/로그인 문제 및 AI 프리토킹 품질 저하 위협을 신속하고 정확하게 원격으로 진단하고 소거하는 핵심 아키텍처 규격으로 가동됩니다.
