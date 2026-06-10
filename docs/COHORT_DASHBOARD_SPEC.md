# 1,000-USER COHORT & SCENARIO DIAGNOSTICS DASHBOARD SPECIFICATION
## (1,000인 군집 시나리오 특화 관리자 대시보드 기획 설계서)

본 명세서는 10대 정밀 특화 군집(1,000명의 남녀노소 가상 사용자)이 플랫폼에서 일으키는 다양한 일상 틈새 시나리오(소파 STILL, CarPlay 고속 주행, 지하철 이동, 독서실 지오펜싱, 교대 수면)와 그 과정에서 검출되는 기술적 예외 상황을 세그먼트별로 관제하고 통제하기 위한 **군집 특화 관리자 진단 대시보드 기획 설계서**입니다.

어드민 운영자가 1,000인의 각양각색 시나리오 정합성을 한눈에 모니터링하고 원클릭 원격 제어로 사후 보완할 수 있도록 비주얼 레이아웃과 데이터 수집 게이트웨이를 설계했습니다.

---

## 🎨 1. 대시보드 핵심 레이아웃 아키텍처 (Dashboard Layout Architecture)

코호트 분석 대시보드는 **3단 마스터-디테일 관제 그리드** 구조를 취하여 Royal Purple HSL 다크 테마 시스템 하에 시각 피로도를 방지하고 정보 인지력을 극대화합니다.

```
+---------------------------------------------------------------------------------------------------------+
| [A] COHORT SELECTION PANEL (10대 특화 군집 셀렉터)                                                       |
| [C01: 실버 옥순] [C02: ADHD 아동] [C03: 지하철 직장인] [C04: CarPlay 운전] ... [C10: 목소리 위협군]      |
+------------------------------------+--------------------------------------------------------------------+
| [B] COHORT REAL-TIME HEATMAP MAP    | [C] DETAILED DIAGNOSTICS & TELEMETRY LEDGER (선택 군집 세부 지표)    |
| (실시간 1,000인 군집 상태 열지도)    |                                                                    |
|  - C01: 🟢🟢🟡🟢🔴🟢🟢🟢🟢🟢...     | - Active Segment Name: Cluster 1 (실버 어르신 코호트)              |
|  - C02: 🟢🟢🟢🟢🟢🟢🟢🟡🟢🟢...     | - Dementia Prevention Badge Rate: 94.2%                            |
|  - C03: 🟢🔴🟢🟢🟢🟢🟢🟢🟢🟢...     | - Presbyopia 24pt Font Override: 98.5% (노안 고대비 최적화 수율)    |
|  - C04: 🔴🟢🟢🟢🟢🟢🟡🟢🟢🟢...     | - STILL Sofa Inaction Detection Count: 242회/일                     |
|  - C05: 🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢...     | - Selected Anomaly Trace:                                          |
|                                    |   "User u_c100_ocksoon STILL 20m -> Focus failure logged."         |
|  (🟢: 정상, 🟡: 경보/뮤트, 🔴: 장애) | - [Resolve: Threshold Tuner] [Bypass Pro Voice] (원격 해결 제어기)  |
+------------------------------------+--------------------------------------------------------------------+
```

---

## 🔌 2. 10대 특화 군집별 전용 진단 위젯 규격 (Cohort Metrics Specifications)

운영자가 대시보드 상단 셀렉터에서 특정 군집을 선택할 때 노출되는 군집 전용 통계 분석 지표와 진단 사양입니다.

### 📊 군집별 맞춤형 관제 데이터 매핑 스펙 (Segmented Analytics Metrics)

| 군집 ID 및 명칭 | 대시보드 노출 전용 KPI 위젯 | 실시간 이상 징후 감지 규칙 (Trigger Alert) | 어드민 원격 해결 직접 명령 (Direct Resolution) |
| :---: | :--- | :--- | :--- |
| **Cluster 1**<br>실버 어르신군 | - 실버 노안 고대비 모드 활성율 (%)<br>- 치매 예방 회춘 배지 누적 적립 수량 | 20분 초과 STILL 감지 후 학습 오버레이 **3초 내 이탈** 시 ➔ `ALERT_SILVER_BORED` | **[임시 기본 프로 성우 우회]**<br>(ElevenLabs 지연 시 클라우드 성우로 우아하게 스와이프) |
| **Cluster 2**<br>ADHD 꼬마 아동 | - 요술봉 파티클 시각 반응율 (%)<br>- 부모 안심 칭찬 캔디 배지 전송 건수 | 학원 셔틀 버스 공회전(**8~12Hz**) 감지 시 좀비 플레이어 **3회 스킵** 시 ➔ `ALERT_KIDS_ATTENTION` | **[요정 마법 보이스 언락]**<br>(전문 요정 성우 데이터 벌크 활성화로 이탈 차단) |
| **Cluster 3**<br>지하철 출퇴근 직장인 | - 지옥철 소음 저주파 필터링 레벨 (dB)<br>- 일일 틈새 학습 스트릭(Streak) 연속 일수 | 지하철 저주파(**50~100Hz**) 만원 열차 내 **볼륨 강제 0(Mute)** 감지 시 ➔ `ALERT_SUBWAY_ESCAPE` | **[로컬 SQLite 캐시 강제 동기화]**<br>(음영 지역 로컬 큐에 쌓인 데이터 즉시 Flush 유도) |
| **Cluster 4**<br>CarPlay 운전자 | - CarPlay LE 오토 페어링 정합성 (%)<br>- CarPlay 오디오 Ducking 레벨 (Target 10%) | 주행 속도 시속 15km/h 이상 감지 중 **스마트폰 화면 조작 터치** 유입 시 ➔ `ALERT_DRIVING_TOUCH_DANGER` | **[운전 전면 암전 강제 명령]**<br>(폰 화면 완전 블랙아웃 ➔ 100% 핸즈프리 발화 유도) |
| **Cluster 5**<br>굉장한 소음 근로자 | - 현장 데시벨 평균 측정치 (dB)<br>- 진동/시각 대체 자막 노출 전환 횟수 | 주변 소음 **70dB 초과** 환경에서 오디오 재생 시도 감지 ➔ `ALERT_DECIBEL_OVERLOAD` | **[묵음 시각 자막 모드 강제 전환]**<br>(귀 대신 눈과 손끝 햅틱으로 틈새 학습 자동 우회) |
| **Cluster 6**<br>접근성 장애 학습자 | - iOS VoiceOver/TalkBack 터치 로그 수율<br>- 유니버설 더블 탭 스와이프 정합성 (%) | 화면 스와이프 및 더블 탭 퀴즈 입력 반응 속도 **15초 초과 지연** 시 ➔ `ALERT_ACCESSIBILITY_TIMEOUT` | **[VoiceOver 전용 오디오 가이드 활성]**<br>(지연 시 차분한 속도의 TTS 안내 음성 송출) |
| **Cluster 7**<br>야간 교대근무군 | - 스마트워치 수면 HRV RMSSD 판독 수율<br>- 주간 수면 방해 방지 Mute 스위칭 수율 | 교대 Sleep profile 타임스탬프와 다른 **주간 RMSSD 수면 파형** 강제 감지 시 ➔ `ALERT_SLEEP_TERROR_BLOCKED` | **[수면 뮤트 필터 강제 활성화]**<br>(센서 오류에 의한 주간 취침 학습 오버레이 100% 차단) |
| **Cluster 8**<br>가사 전담 주부군 | - 가사 STILL 모션 감지율 (%)<br>- 대형마트 지오펜싱 200m 입점 성공 수율 | 마트/세탁 대기 중 STILL 감지 하였으나 **학습 집중도 10초 미만** 이탈 시 ➔ `ALERT_CHORE_SKIPPED` | **[가사 배지 가변 보상 2배 인젝션]**<br>(자발적 학습 의지 유도를 위해 도파민 칩 보상 증가) |
| **Cluster 9**<br>주의산만 중고생 | - 독서실 GPS 반경 50m 지오펜싱 차단율 (%)<br>- PC방/유튜브 강제 이탈 락 가동 수율 | 독서실 지오펜싱 내에서 좀비 팝업 30초 스킵 불가 락 **우회 강제 강제 킬** 감지 시 ➔ `ALERT_STUDY_LOCK_ESCAPE` | **[안심 락커 강제 완전 잠금]**<br>(동적 코사인 0.70으로 강화 및 타 앱 백그라운드 킬) |
| **Cluster 10**<br>보안 위협 금융 타겟군 | - 구두 서명 오디오 난수 OTP 성공률 (%)<br>- 로컬 Secure Enclave 키 복호화 감수성 | 가입 시 재생기기 오디오 스푸핑 고주파(**18kHz**) 공명 챌린지 검출 시 ➔ `ALERT_DEEPFAKE_ATTACK` | **[원격 토큰 즉시 무효화 및 격리]**<br>(해당 단말 로컬 SQLite 큐 잠금 및 계정 강제 락업) |

---

## 🟢 3. 실시간 1,000인 군집 상태 열지도 기획 (Cohort Real-time Heatmap Map)

대시보드 중앙 패널에는 1,000명의 세션 상태를 직관적인 **10 x 100 마이크로 도트 열지도(Heatmap Grid)**로 렌더링합니다.

- **도트 색상 분기 정책**:
  - **🟢 Emerald (정상 작동)**: Telemetry 정상 수집, E-Factor 망각곡선 안정적 유지, 에러 없음.
  - **🟡 Amber (경보/보조 가동)**: 스마트워치 수면 뮤트 필터 작동 중, Sentence-BERT 유사도 임계치 초과로 동적 조율 대기, CarPlay 세이프 드라이빙 모드 작동 중.
  - **🔴 Crimson (치명적 장애)**: 가입 스푸핑 재생공격 탐지, Doze 모드 강제 킬로 오디오 포커스 이탈, 마이크 권한 차단으로 프리토킹 불능.
- **마우스 호버 & 클릭 인터랙션**:
  - 특정 도트 위에 마우스 커서를 올리거나 터치하면 1,000인 중 해당 사용자(예: `u_c100_ocksoon`)의 **실시간 센서 텔레메트리 파이프라인 데이터(HRV, STILL 속도, GPS, 데시벨)**와 **최근 에러 상세 이력**이 좌측 패널에 즉각 상세 연동 투사(Slide-Projection)됩니다.

---

## 🔌 4. 군집 특화 대시보드 데이터 통신 명세 (REST API Spec)

어드민 대시보드 화면이 1,000명의 코호트 상태 데이터를 백엔드 서버로부터 끌어올 때 사용하는 지능형 API 스펙입니다.

### 📈 1. 10대 군집 전체의 실시간 요약 상태 및 에러 카운트 수집
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
      "crimson_critical": 1,
      "critical_uuids": ["u_c100_ocksoon"]
    },
    {
      "cluster_id": "C04",
      "cluster_name": "CarPlay 운전자",
      "total_count": 100,
      "emerald_normal": 88,
      "amber_warning": 10,
      "crimson_critical": 2,
      "critical_uuids": ["u_c400_jina", "u_c400_chulsoo"]
    }
  ]
}
```

### 🔍 2. 특정 사용자의 실시간 텔레메트리 분석 이력 조회
- **Endpoint**: `GET /api/admin/cohorts/metrics?user_id=u_c100_ocksoon`
- **Response**:
```json
{
  "user_id": "u_c100_ocksoon",
  "cluster_id": "C01",
  "biometric_telemetry": {
    "current_bpm": 68,
    "stress_index_rmssd": 35,
    "last_activity": "STILL (Sofa 22 mins)"
  },
  "content_metrics": {
    "active_subject": "HISTORY",
    "retention_score": 45,
    "focus_score": 30,
    "fatigue_index": 82
  },
  "anomaly_logs": [
    {
      "log_uuid": "c100_silver_890a-4b7c-889d-2a819b182cb1",
      "event_type": "CONTENT_FREETALK_FAULT",
      "error_code": "ERR_VOCAB_DUP",
      "error_message": "Dwell Time is 3000ms. Skip detected on History Card.",
      "status": "ACTIVE",
      "created_at": "2026-05-31T14:00:03.112Z"
    }
  ]
}
```

본 **1,000인 군집 시나리오 특화 관리자 대시보드 기획 설계서**는 남녀노소 어떤 각양각색의 라이프스타일을 영위하는 가상 사용자라도 틈새 학습 과정에서 발생하는 오작동 징후를 명확하게 정량화하고, 원격 Resolve 명령과 HSL 테마 그리드를 통해 **1,000인 전체의 학습 완결성을 100% 무결하게 운영 관리**할 수 있도록 보장하는 최상위 운영 기획 명세서입니다.
