# CLIENT-SIDE TELEMETRY CACHE & AUTO-SYNC SPECIFICATION
## (앱 로컬 텔레메트리 캐시 및 실행 시 자동 동기화 기획 설계서)

본 명세서는 "나야~" 플랫폼의 모바일 클라이언트 앱이 통신 두절(음영 지역, 엘리베이터, 만원 지하철) 상황이나 백엔드 서버 장애 상태에서도 사용자의 학습 여정 로그(가입, 로그인, 사용량, 구동 중 에러 등)를 유실 없이 안전하게 수존하고, **앱 실행(Launch) 시 또는 네트워크 복구 시점에 로컬 캐시 데이터를 백엔드 분석 서버로 자동 벌크 동기화(Auto-Sync on Launch)**하기 위한 클라이언트 사이드 데이터 수집 시스템 설계서입니다.

개발 코드가 아닌 **오직 아키텍처 논리 설계, 데이터 제어 규칙, 예외 보호 정책 기획**에 집중하여 작성되었습니다.

---

## 🔄 1. 로컬 텔레메트리 캐시 및 동기화 라이프사이클 (Sync Lifecycle)

앱은 오프라인-퍼스트(Offline-First) 설계 사상을 충족하여 실시간으로 서버에 데이터를 쏘지 않고, **로컬 보안 캐시 디렉토리에 우선 안전 적재(Queue)한 뒤 비동기로 배치 벌크 처리(Batch Bulk Flush)**합니다.

```
 [이벤트 발생] ➔ 1단계: 로컬 SQLite/Key-Value 적재 (is_synced: false)
                                 │
                                 ▼
               2단계: 앱 첫 기동 및 활성화 (App Launch / Resume)
                                 │
                                 ▼
               3단계: 네트워크 연결 진단 (WiFi / LTE / 5G) 
                       ├── (연결 있음) ➔ 4단계: 벌크 전송 API 호출 (idempotency 검증)
                       │                       │
                       │                       ├── (서버 ACK 수신) ➔ 5단계: 로컬 큐 안전 파쇄 (Delete)
                       │                       └── (서버 TIMEOUT)  ➔ 지수 백오프 재시도 대기
                       │
                       └── (연결 없음) ➔ 백그라운드 대기열 보존 (가속도 센서 저전력 슬립)
```

---

## 🗄️ 2. 클라이언트 사이드 로컬 저장소 스키마 (Client-Side Local Schema)

클라이언트 디바이스 내부의 샌드박스 영역에 생성되는 보안 SQLite 텔레메트리 큐 테이블 DDL 정의 및 로컬 JSON 데이터 계약입니다.

### 💾 Local SQLite Queue Table DDL
```sql
CREATE TABLE IF NOT EXISTS local_telemetry_queue (
    log_uuid TEXT PRIMARY KEY,             -- 중복 전송 방지를 위한 멱등성 고유 식별자 (UUID v4)
    event_type TEXT NOT NULL,              -- AUTH_SIGNUP, LOGIN, RUNTIME_OS, CONTENT_FAULT
    error_code TEXT,                       -- ERR_AUTH_SYNC, ERR_AUDIO_FOCUS 등 (선택)
    error_message TEXT,                    -- 상세 디버그 메시지
    stress_level REAL DEFAULT 0.0,         -- 당시의 웨어러블 심박/HRV RMSSD 스트레스 레벨
    occurred_at TIMESTAMP NOT NULL,        -- 기기 내부 로컬 발생 시각 (ISO 8601 UTC)
    retry_count INTEGER DEFAULT 0,         -- 전송 실패 재시도 횟수
    is_synced INTEGER DEFAULT 0            -- 0: 미전송(Pending), 1: 전송성공(Synced)
);

CREATE INDEX IF NOT EXISTS idx_telemetry_pending ON local_telemetry_queue(is_synced) WHERE is_synced = 0;
```

### 멱등성 키(Idempotency Key) 수립 정책:
- 중복 전송 및 네트워크 순서 꼬임으로 인한 중복 분석 집계를 원천적으로 막기 위해, 모든 텔레메트리 로그는 생성 즉시 단말기 내에서 `log_uuid` (예: `46a89c2c-7b0b-4e12-b9b2-9118c728362b`)를 강제 발급받아 원장으로 기능합니다.
- 백엔드 서버는 수신된 벌크 로그 중 이미 DB에 등록된 `log_uuid`가 존재하면, 해당 데이터를 무시하고 통과(Bypass)시켜 데이터 정합성을 수호합니다.

---

## ⚙️ 3. 앱 실행 시 자동 동기화 상태 머신 (App Launch Sync State Machine)

앱 기동(Cold Start) 또는 백그라운드에서 포어그라운드로 복귀(Warm Start)하는 즉시 엔진이 가동되는 내부 상태 천이 흐름도입니다.

```
       [ STATE: IDLE ]
              │
         App Launch / Warm Start 감지
              │
              ▼
  [ STATE: READING_LOCAL_QUEUE ] ➔ 미전송 로그(is_synced = 0)가 존재하는가?
              │
              ├── (아니오: 0건) ➔ [ STATE: IDLE ] 복귀
              │
              └── (예: N건 존재)
                      │
                      ▼
         [ STATE: CHECK_CONNECTIVITY ] ➔ NetInfo API 네트워크 활성 판독
                      │
                      ├── (연결 없음) ➔ 1분 단위 타이머 리스너 등록 후 ➔ [ STATE: IDLE ] 보류
                      │
                      └── (연결 있음)
                              │
                              ▼
                [ STATE: PACKAGING_BULK ] ➔ 최대 50건 단위로 청크 분할 및 벌크 JSON 패킹
                              │
                              ▼
               [ STATE: TRANSMITTING_DATA ] ➔ POST /api/telemetry/bulk 호출
                              │
               ┌──────────────┴──────────────┐
         (서버 응답 성공 200 OK)       (통신 지연/에러 5xx / Timeout)
               │                             │
               ▼                             ▼
   [ STATE: CLEARING_LOCAL_QUEUE ]   [ STATE: BACKOFF_RETRY ]
   - 수신 완료(ACK)된 UUID의           - retry_count 1 증가
     is_synced 값을 1로 마킹          - 지수 백오프 시간만큼
   - 48시간 지난 완료 로그 물리 삭제    - 대기 후 다시 시도
               │                             │
               ▼                             ▼
         [ STATE: IDLE ]               [ STATE: IDLE ]
```

---

## 📶 4. 네트워크 감지 및 지수 백오프 정책 (Retry & Backoff Policy)

### 🛰️ A. 네트워크 도달 가능성 감지 (Reachability Detection)
- 디바이스의 네이티브 네트워크 리스너(`NetInfo.addEventListener`)를 상시 경청하여, 통신 음영 지역에서 LTE/5G망으로 탈출하는 즉시(Offline ➔ Online) 앱이 백그라운드에 슬립 상태로 켜져 있더라도 동기화 루프가 **자동으로 흔들어 깨우는 트리거(Dynamic Wake-Up)** 역할을 집행합니다.

### ⏱️ B. 지수 백오프 재시도 메커니즘 (Exponential Backoff)
- 서버의 일시적 마비(API Gateway 부하, 디비 락킹) 시 무차별적인 API 폭격을 가해 서버를 완전히 다운시키는 악순환을 예방하기 위해 재시도 간격을 기하급수적으로 증가시킵니다.
- **재시도 공식**:
  $$\text{Next Delay (sec)} = 2^{\text{retry\_count}} + \text{random\_jitter}$$
  - *1차 실패 시*: 2초 + 지터 대기
  - *2차 실패 시*: 4초 + 지터 대기
  - *3차 실패 시*: 8초 + 지터 대기
  - *최대 한도(Max Cap)*: 120초 이상 재시도 대기가 늘어나지 않도록 상한선 규정.
- **재시도 포기 정책 (Max Retry Cap)**:
  - `retry_count`가 **10회**에 도달할 때까지 전송이 실패한 망가진 데이터 패킷은 불량 로그로 격리(`is_synced = -1` 처리)하고 원장 전송 대기열에서 제외시켜 분석 큐의 정체를 예방합니다.

---

## 🔌 5. 벌크 전송 API 페이로드 규격 (Bulk Transmission Spec)

앱이 실행되며 로컬에 묵혀 두었던 다량의 전 여정 장애 데이터를 한 번에 밀어 넣을 때 사용하는 백엔드 수신 규격입니다.

- **Endpoint**: `POST /api/telemetry/bulk`
- **Request Header**: `Content-Encoding: gzip` (5건 이상 벌크 전송 시 데이터 사용량 보호를 위해 클라이언트 단말에서 Gzip 압축 압축 전송 처리)
- **Request Payload**:
```json
{
  "device_id": "d_phone_iphone15_minjun",
  "client_app_version": "v1.4.2",
  "cumulative_sent_count": 3,
  "payload": [
    {
      "log_uuid": "46a89c2c-7b0b-4e12-b9b2-9118c728362b",
      "event_type": "AUTH_SIGNUP",
      "error_code": "ERR_AUTH_SYNC",
      "error_message": "OTP challenge code mismatched on device u_001. User input '482902' but challenge was '482901'.",
      "stress_level_at_error": 32.5,
      "occurred_at": "2026-05-31T09:30:12.852Z"
    },
    {
      "log_uuid": "f290b34d-17ea-4390-ac3b-01290374e2ab",
      "event_type": "RUNTIME_OS_ANOMALY",
      "error_code": "ERR_AUDIO_FOCUS",
      "error_message": "AVAudioSession category interrupted by navigation stream. Driving Mode Active.",
      "stress_level_at_error": 68.2,
      "occurred_at": "2026-05-31T09:32:00.010Z"
    },
    {
      "log_uuid": "a782b890-e54b-4a7b-890d-2a819b182cb9",
      "event_type": "CONTENT_FREETALK_FAULT",
      "error_code": "ERR_MIC_BLOCKED",
      "error_message": "Weekend STT message capture blocked by mic system authorization error.",
      "stress_level_at_error": 41.0,
      "occurred_at": "2026-05-31T09:35:45.912Z"
    }
  ]
}
```

- **Response Payload (ACK)**:
```json
{
  "success": true,
  "received_count": 3,
  "processed_uuids": [
    "46a89c2c-7b0b-4e12-b9b2-9118c728362b",
    "f290b34d-17ea-4390-ac3b-01290374e2ab",
    "a782b890-e54b-4a7b-890d-2a819b182cb9"
  ],
  "duplicated_skipped_count": 0,
  "timestamp": "2026-05-31T10:15:00.000Z"
}
```

---

## 🚨 6. 메모리 보호 및 캐시 오버플로우 한도 제어 (Cache Buffer Cap)

만약 백엔드 서버가 3일 이상 완전 다운되거나 장기 여행으로 인해 비행기 내에서 오프라인 모드로 몇 주 동안 앱을 사용하더라도, 클라이언트 기기의 디바이스 한정된 스토리지 메모리를 잠식하지 않도록 하는 안전 제어 가이드입니다.

### 🛡️ A. 버퍼 용량 캡 제한 (Storage Maximum Limit)
- 로컬 텔레메트리 큐의 최대 스토리지 점유율은 **10MB** 또는 **최대 5,000건** 이하로 상한선을 강제 고정합니다.
- 이 상한 임계치에 다다르면 단말기는 비상 로컬 FIFO(First-In, First-Out) 삭제 정책을 수립합니다.

### 🗑️ B. 비상 FIFO 가위질 삭제 정책 (Cache Eviction Policy)
1. **중요도에 따른 전송Pending 차등화**:
   - `event_type` 중 회원가입 및 결제 오류 등 주요 보안 로그(`CRITICAL` 등급)는 절대 삭제하지 않고 보존합니다.
   - 단순 좀비 카드 읽기 노출 로그(`INFO` 등급)를 우선 타겟으로 선정하여, 로컬 스토리지 한도 도달 시 가장 오래된 순(Occurred_at이 가장 과거인 순)으로 로컬 DB에서 영구 소거(FIFO Hard Delete)합니다.
2. **청소 주기**:
   - 이미 서버 동기화가 성공한 로그(`is_synced = 1`)는 동기화 통보 즉시 로컬에서 하드 딜리트하거나, 디버깅 모드 유지를 위해 **최대 48시간** 경과 시 단말기 내부 백그라운드 가비지 컬렉터(Garbage Collector)에 의해 완전 자동 삭제되게 보관 기한을 제어합니다.

본 **앱 로컬 캐시 및 실행 시 자동 동기화 명세서**의 기술적 설계 규칙은, 음영 지역에서 발생한 장애가 공중분해 되지 않고 앱이 다시 켜지는 순간 원형 그대로 관리자 관제 대시보드에 모여들어 완벽한 사후 원격 조치를 가능하게 하는 든든한 기술 기획 초석으로 작동하게 될 것입니다.
