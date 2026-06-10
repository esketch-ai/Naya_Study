# API SPECIFICATION (API 설계서 및 프로토콜 규격서)

본 문서는 "나야~ 영어" 및 후속 확장 시리즈 플랫폼의 클라이언트와 백엔드 서버 간의 RESTful API 엔드포인트 및 클라우드 AI 서비스(OpenAI, ElevenLabs) 연동 규격을 정의합니다.

---

## 1. RESTful HTTP API 엔드포인트

모든 API는 JSON 형식으로 데이터를 수신 및 반환하며, 공통 헤더로 `Authorization: Bearer <Token>`을 탑재합니다.

### 🔌 1.1. 사용자 설정 프로필 연동 (User Profile)
- **Endpoint**: `/api/v1/profile`
- **Method**: `GET` / `PUT`
- **Description**: 기상/수면 지정 시간, 기본 보이스 톤(연인, 비서 등) 설정을 관리합니다.

**Request Payload (PUT)**:
```json
{
  "wakeup_time": "06:30",
  "sleep_time": "23:30",
  "preferred_voice": "energetic",
  "stress_threshold": 80
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "user_id": "usr_9f81a7b8e",
    "user_name": "홍길동",
    "wakeup_time": "06:30",
    "sleep_time": "23:30",
    "preferred_voice": "energetic",
    "stress_threshold": 80
  }
}
```

### 🔌 1.2. 데일리 좀비 집중 카드 배정 (Zombie Card Fetch)
- **Endpoint**: `/api/v1/learning/zombie-card`
- **Method**: `GET`
- **Description**: 오늘 하루 유저가 반복해서 습득할 3개의 카드 정보를 가져옵니다.

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": [
    {
      "asset_id": 1,
      "subject_code": "ENGLISH",
      "category": "Daily Idiom",
      "key_expression": "Take it easy",
      "pronunciation_or_tip": "[teɪk ɪt ˈiːzi]",
      "translation_meaning": "진정해, 서두르지 마, 편하게 생각해",
      "example_context_1": "Take it easy! We still have plenty of time.",
      "example_context_2": "진정해! 우리 아직 시간 많이 남아있어."
    }
  ]
}
```

### 🔌 1.3. 밤 10시 12문항 스파르타 테스트 제출 (Evening Quiz Logs)
- **Endpoint**: `/api/v1/learning/quiz/submit`
- **Method**: `POST`
- **Description**: 저녁 퀴즈의 개별 답변 결과를 채점하고 복습 주기를 갱신합니다.

**Request Payload**:
```json
{
  "asset_id": 1,
  "score_quality": 5  // 유저의 정답 등급 (0: 완전 모름 ~ 5: 즉시 정답)
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "next_review_date": "2026-06-05",
    "repetition_interval": 6,
    "easiness_factor": 2.62
  }
}
```

---

## 2. ElevenLabs 음성 합성 (TTS) API 규격

사용자의 워치 생체 정보(HRV 스트레스 지수)에 따라 실시간 렌더링할 ElevenLabs API의 구조입니다.

- **Endpoint**: `https://api.elevenlabs.io/v1/text-to-speech/{voice_id}/stream`
- **Headers**:
  - `xi-api-key`: `xi_apiKey_abcdef12345`
  - `Content-Type`: `application/json`

**Request Payload**:
```json
{
  "text": "Please, take it easy. You are doing absolutely amazing.",
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.4,       // 낮을수록 감정 굴곡이 커짐 (연인/락스타에 활용)
    "similarity_boost": 0.8, // 1.0에 가까울수록 원본 음성과 완전히 일치
    "style": 0.6            // 클로닝 보이스의 독창적 톤 강화
  }
}
```

---

## 3. OpenAI GPT-4o 실전 프리토킹 파이프라인

주말 5분 대화 시, 백엔드 서버가 유저의 STT 발화를 받고 OpenAI GPT-4o와 통신하여 **'다정한 대답 텍스트'와 '실시간 문법 오답 교정'**을 구조화된 JSON 데이터로 출력하는 규격입니다.

- **Endpoint**: `https://api.openai.com/v1/chat/completions`
- **Structured JSON Schema (강제 JSON 아웃풋 명세)**:

**JSON Response Schema Definition**:
```json
{
  "type": "object",
  "properties": {
    "buddy_reply_english": {
      "type": "string",
      "description": "선택한 캐릭터(Lover, Rockstar 등)의 페르소나와 감정을 가득 담아 유저에게 던질 다정한 영어 답변 대사"
    },
    "buddy_reply_korean": {
      "type": "string",
      "description": "다정한 톤앤매너로 작성된 쳇 화면용 한국어 텍스트 피드백"
    },
    "has_grammatical_error": {
      "type": "boolean",
      "description": "유저의 영어 입력에 사소한 문법적 에러 또는 부자연스러운 영작이 감지되었는지 여부"
    },
    "grammar_correction_tip": {
      "type": "string",
      "description": "오류가 있을 경우, 이를 다정하게 보듬어 제안해 줄 올바른 교정 표현 (오류가 없으면 null)"
    }
  },
  "required": ["buddy_reply_english", "buddy_reply_korean", "has_grammatical_error", "grammar_correction_tip"]
}
```

**AI Buddy Response Payload (Lover Voice active, User says: "I fine")**:
```json
{
  "buddy_reply_english": "Oh honey, I'm so glad to hear you are doing fine! It makes me smile just thinking about you.",
  "buddy_reply_korean": "어구구, 우리 자기 잘 지내고 있다니 정말 마음이 놓이네! 내 생각 하면서 기운 내!",
  "has_grammatical_error": true,
  "grammar_correction_tip": "I am fine. 또는 I'm doing great, darling! ❤️"
}
```
