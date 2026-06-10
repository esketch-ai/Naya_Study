# DASHBOARD & CLIENT INTEGRATED SCENARIO PLAYBOOK
## (대시보드-앱 통합 시나리오 테스트 플레이북)

본 명세서는 "나야~" 플랫폼의 **모바일 클라이언트 앱(로컬 캐시/동기화 엔진)**과 **관리자 분석 대시보드(원격 해결 포탈)** 간의 유기적인 상호작용 및 장애 대응 흐름을 실증하고 검증하기 위한 **통합 시나리오 테스트 설계서**입니다.

사용자의 일상 틈새 시간(Dead Time) 동안 발생하는 스마트 센서 연동, 오프라인 상황에서의 텔레메트리 적재, 앱 재실행 시점의 벌크 동기화, 그리고 관리자의 즉각적인 원격 복구 명령 전송이 유기적으로 맞물리는 3대 대표 시나리오의 흐름을 논리적으로 추적(Trace)합니다.

---

## 🧭 시나리오 1: 지하철 단절 후 가입 실패 및 앱 실행 시 벌크 동기화
> 본 시나리오는 만원 지하철 등 100% 통신 음영 지역에서 사용자가 가입을 시도하다 발생한 오류가 로컬 큐에 적재되었다가, 와이파이가 터지고 앱이 재기동되는 순간 관리자 대시보드로 자동 벌크 전송(Flush)되어 원격 해결되는 과정을 검증합니다.

```
[지하철 터널 (Offline)] ➔ 1단계: 사용자 목소리 구두 서명 가입 시도
                                │
                                ▼ (통신 두절로 ElevenLabs 인증 불가)
                       2단계: ERR_AUTH_SYNC 로컬 큐에 적재 (is_synced: 0)
                                │
[지하철 탈출 (Online)]  ➔ 3단계: 사용자가 앱을 다시 실행 (Launch)
                                │
                                ▼ (NetInfo가 기기 Online 감지)
                       4단계: POST /api/telemetry/bulk 자동 밀어내기 (Flush)
                                │
                       5단계: 어드민 대시보드 🔴 CRITICAL 사이렌 경보 작동
                                │
                       6단계: 어드민이 [원격 토큰 리셋 (Token Flush)] 버튼 클릭
                                │
                       7단계: 클라이언트 기기에 원격 푸시 전송 ➔ 로컬 큐 안전 파쇄
```

### 📊 1. 클라이언트 로컬 캐시 적재 (Offline Telemetry Ingest)
- 지하철 터널에서 사용자가 발화한 음성 서명이 동기 난수 불일치 및 네트워크 차단으로 가입 오류 발생.
- **로컬 적재 페이로드 (`local_telemetry_queue`)**:
```json
{
  "log_uuid": "e9b28c3d-f203-4c12-a89b-9008c728362b",
  "event_type": "AUTH_SIGNUP",
  "error_code": "ERR_AUTH_SYNC",
  "error_message": "OTP challenge code mismatched on device u_001. User input '482902' but challenge was '482901'.",
  "stress_level_at_error": 32.5,
  "occurred_at": "2026-05-31T09:30:12.852Z",
  "is_synced": 0
}
```

### 🛰️ 2. 앱 실행 및 자동 벌크 동기화 (Auto-Flush on Launch)
- 지하철역 탈출 후 사용자가 앱을 기동하자, `NetInfo`가 활성화 상태로 천이됨을 확인.
- 로컬 SQLite에 쌓여있던 `is_synced = 0` 로그 1건을 감지하여 Gzip 압축 후 `POST /api/telemetry/bulk` 호출.
- 백엔드 서버 수신 후 **200 OK (ACK)** 처리 완료. 로컬 상태 `is_synced = 1` 마킹 후 영구 보관 기한 스케줄 돌입.

### 👑 3. 관리자 대시보드 경보 및 원격 해결 (Operations Portal Resolution)
- 관리자 분석 포탈 대시보드 탭에 **"🔴 [ERR_AUTH_SYNC] 가입 구두서명 동기화 실패"** 사이렌 경보 팝업 노출.
- ElevenLabs 지연 및 API 비용 요동 게이지가 일시적으로 스파이크 상승.
- 관리자가 **[Token Flush (원격 토큰 리셋)]** 버튼을 클릭하여 백엔드 `/api/admin/users/resolve` 전송.
- 기기에 멱등 키가 무효화된 리셋 패킷이 전달되어, 앱은 로컬의 깨진 가입 잔재 데이터를 완전 세척하고 유저에게 "음성인식 가입 단계"로 안전하게 복귀할 것을 비주얼 가이드로 재안내함.

---

## 🚗 시나리오 2: 고속 주행 중 CarPlay 오디오 충돌 및 원격 저전력 탈출
> 본 시나리오는 CarPlay를 켜고 운전하던 중 내비게이션 안내 오디오 스트림과 Naya 좀비 TTS 스트림이 충돌하여 앱이 OS에 의해 강제 킬(Kill)되었을 때, 대시보드 감지를 통해 원격으로 앱의 백그라운드 상주 생명줄을 되살려 주는 과정을 검증합니다.

```
[차량 고속 주행 (>15km/h)] ➔ 1단계: CarPlay LE 블루투스 오토 페어링
                                    │
                                    ▼ (화면 Blackout 암전 & 100% 핸즈프리 전환)
                           2단계: 내비 음성 가이드 충돌로 오디오 포커스 이탈
                                    │
                                    ▼ (OS가 App Background Activity 강제 Kill)
                           3단계: ERR_AUDIO_FOCUS 통신 두절 에러 수집
                                    │
                           4단계: 어드민 대시보드 🔴 CRITICAL 사이렌 경보 가동
                                    │
                           5단계: 어드민이 [저전력 모드 강제 복구 (Low-Power)] 버튼 클릭
                                    │
                           6단계: WakeLock API 원격 강제 자극 ➔ 포어그라운드 서비스 복구
```

### 📊 1. CarPlay 연동 중 오디오 포커스 이탈
- 운전자가 고속도로 주행 중 차량 오디오 가이드 충돌로 `AVAudioSession` 카테고리 점유권 박탈.
- **백서버 전송용 에러 텔레메트리**:
```json
{
  "log_uuid": "f290b34d-17ea-4390-ac3b-01290374e2ab",
  "event_type": "RUNTIME_OS_ANOMALY",
  "error_code": "ERR_AUDIO_FOCUS",
  "error_message": "AVAudioSession category interrupted by navigation stream. Focus loss in Driving Mode.",
  "stress_level_at_error": 68.2,
  "occurred_at": "2026-05-31T09:32:00.010Z"
}
```

### 👑 2. 관리자 대시보드 감지 및 저전력 원격 기생 조치
- 대시보드에 **"🔴 [ERR_AUDIO_FOCUS] CarPlay 오디오 포커스 이탈"** 이상 로그가 빨간색으로 등재됨.
- 관리자가 해당 운전자의 교통사고 위험을 차단하고 틈새 오디오 복구를 위해 **[저전력 모드 전환 (Low-Power Switch)]** 복구 명령 클릭.
- 클라이언트 기기의 OS 백그라운드 엔진으로 `WakeLock` 강제 해제 및 저전력 BLE 컴패니언 폴링 모드 강제 전환 신호가 원격 전달됨.
- 앱은 무리하게 미디어를 재생하지 않는 대신 워치 햅틱 호흡 진동 및 CarPlay 내비 더킹(10% 사운드 다운) 채널을 우아하게 재정렬하여 복구 완료됨.

---

## 🤖 시나리오 3: 0.85 초과 중복 어휘 생성 차단 및 임계치 동적 조율
> 본 시나리오는 AI 동적 콘텐츠 생성 파이프라인에서 Sentence-BERT 코사인 유사도 임계치(0.85)를 초과하는 지루한 유사 단어 카드가 연속 노출되는 것을 관리자가 실시간 모니터링하여, 어드민 단에서 유사도 허용치를 강제 차단·조율해 나가는 품질 사후 관리 과정을 검증합니다.

```
[AI 콘텐츠 자동 생성] ➔ 1단계: GPT-4o가 'Bite the bullet'과 유사한 카드 생성
                                  │
                                  ▼ (유사도 측정 결과 0.89 ➔ 0.85 임계치 초과)
                         2단계: ERR_VOCAB_DUP 중복 텔레메트리 팝업 거부
                                  │
                         3단계: 어드민 대시보드 🟠 WARNING 노란색 경보 점등
                                  │
                         4단계: 어드민이 [임계치 동적 조율 (Threshold Tuner)] 버튼 클릭
                                  │
                         5단계: 기기 내 유사도 임계치가 0.70으로 동적 강화 조율
                                  │
                         6단계: 중복 카드 강제 우회 패스 ➔ 새로운 학습 세트 로딩
```

### 📊 1. 코사인 유사도 챌린지 검출
- 단어 생성 모델이 사용자가 2일 전에 이미 암기 완료한 유사 예문을 노출하려 하자 단말의 Sentence-BERT가 검출 차단함.
- **백서버 전송용 에러 텔레메트리**:
```json
{
  "log_uuid": "d412b39c-8a21-432e-b82b-9118c728362b",
  "event_type": "CONTENT_FREETALK_FAULT",
  "error_code": "ERR_VOCAB_DUP",
  "error_message": "Sentence-BERT cosine similarity exceeds 0.85 threshold. Cards duplicated.",
  "stress_level_at_error": 38.0,
  "occurred_at": "2026-05-31T09:33:15.912Z"
}
```

### 👑 2. 관리자 대시보드 감지 및 품질 가이드 조율
- 대시보드의 **"Sentence-BERT Max Cosine Sim"** 게이지가 한계치인 `0.89 / 0.85 ⚠️`로 치솟으며 노란색 경고 패널이 활성화됨.
- 관리자가 **[임계치 동적 조율 (Threshold Tuner)]** 복구 명령을 작동시킴.
- 기기에 원격 임계값 갱신 파라미터가 푸시되어, 유사도 임계 기준을 더욱 엄격한 `0.70`으로 강제 스케일링 세팅함.
- 기기는 동의어 루프에서 깨어나 100% 새로운 어원 카드로 틈새 학습 큐를 재빌드하고, 대시보드 유사도 게이지는 정상 범주인 `0.72` 수준의 에메랄드 테마로 안전하게 회귀함.

본 **통합 시나리오 테스트 명세서**는 관리자 대시보드와 앱 클라이언트가 서로 밀고 당기는 양방향 유기적 복구 파이프라인의 완성도를 직관적으로 증명하는 마스터 기획 입증 자료입니다.
