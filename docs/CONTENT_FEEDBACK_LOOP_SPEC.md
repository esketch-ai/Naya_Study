# FOCUS COMPLETION FEEDBACK LOOP SPECIFICATION
## (콘텐츠 집중 완결성 분석 및 동적 보완 콘텐츠 생성 모델 설계서)

본 명세서는 사용자가 모바일 틈새 학습 카드를 열거나 주말 프리토킹을 수행할 때의 **집중도 및 세션 완결성(Focus Completion Rate)** 통계 데이터를 정밀하게 수집·분석하고, 이를 **인공지능형 콘텐츠 생성 및 지원 모델(OpenAI GPT-4o / ElevenLabs)**의 입력 벡터로 피드백하여 **사용자별 학습 사각지대를 실시간 보완(Adaptive Supplementation)**해 주기 위한 **기획 및 폐루프 피드백(Closed-Loop Feedback) 아키텍처 설계서**입니다.

사용자의 피로도, 집중 분산 이력, 스킵 패턴을 통계적으로 판독하여 콘텐츠 난이도와 자극 구조를 동적으로 튜닝하는 지능형 피드백 메커니즘을 정의합니다.

---

## 🔄 1. 집중 완결성 기반 콘텐츠 동적 순환 파이프라인 (Closed-Loop Feedback Flow)

```
[사용자 학습 세션] ➔ 1단계: 세션별 집중 완결성 지표 획득 (Dwell Time, STT 발화성공 등)
         ▲                       │
         │                       ▼
         │             2단계: 데이터베이스 축적 및 통계 엔진 가동
         │                       │
         │                       ▼ (집중 프로필 분석)
         │             3단계: 사용자 집중 완결성 프로필 벡터 (Focus Profile Vector) 산출
         │                       │
         │                       ▼ (생성 AI 입력 인자로 피드백 주입)
         │             4단계: AI 콘텐츠 보완 생성 모델 작동 (GPT-4o Adaptive Prompt)
         │                       │
         └───────────────────────┴─ [사용자 맞춤형 보완 콘텐츠 제공]
                                    - 저집중자: 초단문, 강한 자극, 요정/락스타 보이스 변환
                                    - 맥락 붕괴자: 지난 화 에피소드 3줄 연계 Stitcher 주입
                                    - 저암기/고집중자: 어원 연상 Mnemonic 힌트 결합
```

---

## 📊 2. 집중 완결성 분석 통계 지표 명세 (Focus Completion Metrics)

클라이언트 앱이 학습 세션 중 측정하여 백엔드로 보낼 집중 완결성 평가 데이터 규격입니다.

### 📈 세션 완결성 4대 핵심 메트릭 (4 Core Metrics)

| 지표명 | 수집 항목 (Client Telemetry) | 측정 공식 및 임계치 | 집중도 판독 의미 |
| :--- | :--- | :--- | :--- |
| **Dwell Time Rate<br>(화면 체류 완결성)** | `session_dwell_time_ms` / `audio_duration_ms` | 음성 합성 재생 시간 대비 실제 좀비 오버레이 카드를 화면에 띄우고 집중한 시간 비율 (기준치: $\ge 1.0$) | 카드 노출 즉시 볼륨을 다운하거나 2초 내에 꺼버렸는지 여부 감지 (회피성 이탈 판독) |
| **Utterance Match Rate<br>(STT 발화 완결성)** | `speech_recognition_confidence` | Web Speech STT 수집 텍스트와 원문 예문의 음운 유사도 (기준치: $\ge 80\%$) | 사용자가 실제 소리 내어 문장을 정확하게 읊고 물리적 발화를 마쳤는지 여부 판독 |
| **Heartrate Jitter<br>(심박 안녕도 지표)** | `delta_stress_index` | 학습 카드 오픈 후 10초간의 심박 변이도(HRV) 스트레스 급상승율 | 세션 중 발생한 사용자의 불쾌 지수 및 번아웃 피로 유도 패턴 판독 |
| **Interact Skip Rate<br>(인터랙션 지연/스킵)** | `quiz_response_latency_ms` | 저녁 스파르타 퀴즈 시 첫 오답 클릭 또는 고민 시간 (기준치: $\le 5,000\text{ms}$) | 주의산만 및 ADHD 성향, 또는 기저 어휘가 너무 어려워 느끼는 지적 장벽 감지 |

---

## 🧠 3. 사용자 집중 완결성 프로필 벡터 (Focus Profile Vector)

위의 통계 지표를 바탕으로 백엔드 분석 엔진이 실시간 컴파일하는 **3차원 집중 매트릭스**입니다.

$$\vec{V}_{\text{focus}} = \left[ FS, FI, RS \right]$$

1. **Focus Score (집중 점수 - $FS \in [0, 100]$)**:
   - 사용자가 학습 시 중간에 앱을 이탈하지 않고 발화까지 끝낸 완결율의 주간 가중 평균치.
2. **Fatigue Index (피로 인덱스 - $FI \in [0, 100]$)**:
   - 스마트워치가 수집한 자율신경계 스트레스와 팝업 즉시 닫기 빈도가 결합된 뇌 피로도 지수.
3. **Retention Score (장기 기억 점수 - $RS \in [0, 100]$)**:
   - SuperMemo-2 Spaced Repetition E-Factor를 통해 도출된 주중 어휘 누적 리콜 암기율.

---

## 🤖 4. AI 보완 콘텐츠 생성 프롬프트 명세 (Adaptive AI Prompt Spec)

AI 동적 콘텐츠 생성 엔진(OpenAI GPT-4o 기반 API Gateway)은 위에서 도출된 $\vec{V}_{\text{focus}}$ 벡터 데이터를 프롬프트 인젝터(Dynamic Prompt Injector)로 입력받아, 세션 완결성 형태에 맞춰 예문 난이도와 보완 팁을 실시간으로 분기 생성합니다.

### 📝 AI Generator System Prompt Specification
```markdown
[SYSTEM_PROMPT: ADAPTIVE_CONTENT_GENERATOR]

당신은 "나야~" 플랫폼의 동적 콘텐츠 보완 생성 엔진입니다. 
아래 수신된 사용자 집중 완결성 벡터 프로필 데이터에 의거하여, 최적의 보완 문장과 츤데레 캐릭터 대사를 생성 계약 규격(JSON)에 맞춰 응답해야 합니다.

[INPUT_USER_FOCUS_PROFILE_VECTOR]
- Focus Score (집중 점수): {{USER_FS}} / 100
- Fatigue Index (피로 지수): {{USER_FI}} / 100
- Retention Score (장기 기억 점수): {{USER_RS}} / 100

[동적 보완 분기 매핑 규칙 (Branching Rules)]
1. 저집중 고피로군 (USER_FS < 40, USER_FI > 70):
   - 장황한 설명이나 예문은 피로를 가중시킵니다. 
   - 문장 길이를 단 3단어 이하의 극소 마찰력 문장(Ultra-Short Expression)으로 축소하십시오.
   - 캐릭터 성격은 도파민 자극을 위해 "Hype Rockstar" 또는 강력한 채찍질의 "Strict Coach" 칭찬을 가동하십시오.

2. 고집중 저기억군 (USER_FS >= 70, USER_RS < 50):
   - 집중도는 높으나 장기 기억 보존력이 심각하게 결여된 상태입니다.
   - 생성하는 JSON의 "supplementary_mnemonic" 필드에 어원 연상 힌트, B급 유머 연상 팁, 또는 한국어 소리 나는 드립 팁을 결합하여 망각 곡선을 강제로 꺾어 놓으십시오.
   - 예: 'Break a leg' ➔ "다리를 부러뜨리라니요?! 연극 시작 전 행운을 비는 B급 극장 유행어!"

3. 맥락 유실 탈출자 (최근 3회 연속 세션 스킵 감지):
   - 이전 서사의 흐름이 단절되었습니다.
   - "stitcher_preview" 필드에 지난 줄거리 3줄을 동적으로 요약 결합하여 서사의 완성도를 자동 복구하십시오.
```

---

## 🔌 5. 보완 콘텐츠 JSON 데이터 계약 규격 (Adaptive JSON Schema)

보완 콘텐츠 생성 모델이 백엔드 API Gateway와 주고받는 엄격한 JSON Output 스키마 포맷 정의서입니다.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AdaptiveSupplementedAsset",
  "type": "OBJECT",
  "properties": {
    "asset_id": { "type": "INTEGER" },
    "target_expression": { "type": "STRING" },
    "adaptive_difficulty_level": { "type": "INTEGER", "minimum": 1, "maximum": 5 },
    "focus_supplementation_applied": { "type": "BOOLEAN" },
    "supplement_type": { 
      "type": "STRING", 
      "enum": ["ULTRA_SHORT_PUNCHY", "MNEMONIC_ASSOCIATION", "NARRATIVE_STITCHER", "STANDARD"] 
    },
    "stitcher_preview": { 
      "type": "STRING",
      "description": "스토리 스킵자 대상 지난 화 3줄 요약 맥락 복합기"
    },
    "supplementary_mnemonic": { 
      "type": "STRING",
      "description": "어원 연상 힌트 및 B급 기억 자극 밈"
    },
    "wit_character_feedback": {
      "type": "OBJECT",
      "properties": {
        "lover_alleviation": { "type": "STRING" },
        "coach_retaliation": { "type": "STRING" }
      },
      "required": ["lover_alleviation", "coach_retaliation"]
    }
  },
  "required": [
    "target_expression", 
    "adaptive_difficulty_level", 
    "focus_supplementation_applied", 
    "supplement_type", 
    "wit_character_feedback"
  ]
}
```

본 **집중 완결성 분석 및 보완 모델 설계서**는 사용자의 불성실함이나 바쁜 일상, 또는 지적 한계로 인한 학습 이탈 징후를 과학적 통계로 진단하고, AI 콘텐츠 생성 파이프라인의 가변 프롬프트 튜너를 통해 실시간으로 단어 길이 조절 및 어원 힌트를 투입해 줌으로써 어떤 장애 요인 속에서도 **학습 완결성을 100% 견인**하는 완벽한 인공지능 기반 사후 관리 구조를 선언합니다.
