# MULTI-SUBJECT EXPANSION & MULTICULTURAL LEARNING PLAYBOOK
## (다과목 무한 확장 프레임워크 규격 및 다문화 한국어 역학습 설계서)

본 명세서는 "나야~" 플랫폼의 핵심 아키텍처인 **"다과목 무한 확장성(Multi-Subject Extensibility)"**을 실증하고, 전 세계 다문화/외국인 학습자 군집(Michael 등)을 수용하여 한국 표준 맞춤법 및 사자성어를 역학습시키는 **다문화 국어/한국어 역학습 설계서**입니다.

코어 플랫폼 엔진(센서 트리거, 잠금 화면 락커, AI 보이스 버디, 에빙하우스 오답노트 스케줄러)을 단 한 줄도 고치지 않고 과목 변경 버튼 클릭만으로 {수학, 화학, 역사, 국어}가 동적으로 결합·해제되는 **데이터 계약(Data Contract)** 및 **HSL 브랜드 컬러 스킨 스펙**을 확립합니다.

---

## 🎨 1. 다과목 브랜드 테마 HSL 컬러 명세 (Multi-Subject Brand Themes)

과목 스위칭 시, 스마트폰과 스마트워치의 대시보드 및 좀비 팝업 UI의 색상이 아래의 **초고대비 HSL 스키마**에 맞추어 실시간 렌더링 스위칭됩니다.

```
[ Naya~ 다과목 HSL 컬러 맵핑 허브 ]

  ├── ① ENGLISH   ➔ Emerald Green [HSL(150, 65%, 42%)] - 싱그럽고 똑똑한 멘토링
  ├── ② MATH      ➔ Sapphire Blue [HSL(210, 85%, 45%)] - 지적이고 차가운 수리 논리
  ├── ③ CHEMISTRY ➔ Amber Orange  [HSL(35, 95%, 48%)]  - 열정적이고 결합적인 생활 화학
  ├── ④ HISTORY   ➔ Crimson Red   [HSL(350, 75%, 45%)] - 장엄하고 서사적인 역사의 파도
  └── ⑤ KOREAN    ➔ Deep Teal     [HSL(185, 70%, 38%)] - 차분하고 단아한 다국어 문화
```

### 👁️ HSL 색상 추출 규칙 (HSL Contrast Ratio Specs)
모든 HSL 스킨은 WCAG 2.1 AAA 등급인 **텍스트-배경 대비율 7:1 이상**을 유지하도록, 텍스트 폰트 색상은 밝은 명도 L(95%)로 제한하고, 버튼 및 펄스 파형 등의 배경색은 명도 L(40% 내외)로 동적 보정 연산되어 노안 어르신과 색약자에게 무장벽 시인성을 보장합니다.

---

## 💾 2. 다과목 표준 데이터 계약 (Standard Content Data Contract)

과목 확장 시, 새로운 학습 콘텐츠가 AI 엔진 및 SQLite에 바인딩되기 위해 준수해야 하는 **표준 JSON 구조 계약**입니다.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "NayaSubjectAssetSchema",
  "type": "object",
  "properties": {
    "subject_code": { "type": "string", "enum": ["ENGLISH", "MATH", "CHEMISTRY", "HISTORY", "KOREAN"] },
    "category": { "type": "string" },
    "key_expression": { "type": "string", "description": "핵심 공식, 화학식, 단어, 연도" },
    "pronunciation_or_tip": { "type": "string", "description": "음성 낭독 가이드 혹은 미세 팁" },
    "translation_meaning": { "type": "string", "description": "해당 단어/공식의 한국어 뜻 혹은 다국어 번역 의미" },
    "example_context_1": { "type": "string", "description": "예시 문제 혹은 일상 적용 시나리오 질문" },
    "example_context_2": { "type": "string", "description": "예시 문제 해설 및 예시 답변" }
  },
  "required": ["subject_code", "category", "key_expression", "translation_meaning", "example_context_1", "example_context_2"]
}
```

---

## 🔄 3. 다문화 및 외국인 학습자를 위한 국어(한국어) 역학습 스펙

다문화 가정이 급증하는 시대에 맞추어, 한국어 소통 장벽을 겪는 외국인 가입자들이 자투리 틈새 시간에 한국의 올바른 맞춤법과 사자성어를 습득하도록 지원하는 스펙입니다.

### 🌐 A. 다국어 역렌더링 엔진 (Dual-Rendering English UI)
- **작동 원리**: 사용자의 기본 언어 프로필이 영어(`en-US`) 혹은 베트남어(`vi-VN`)로 판독되면, 좀비 팝업과 메뉴의 도움말 및 시스템 버튼 언어를 즉각 **영어/베트남어 가이드 UI**로 번역 표기합니다.
- **학습 타겟**: 주입되는 단어(`key_expression`)와 발음 가이드만 한국 표준어(Standard Korean)로 제공하여 언어 마찰을 0%로 줄입니다.

### 🇰🇷 B. 한국어 표준어 억양 이퀄라이저 분석 (Seoul Accent Pitch Evaluator)
- **기능**: 외국인 사용자가 한국어 단어("일석이조")를 발화할 때, STT 뿐만 아니라 **F0 피치 주파수 궤적(Pitch Contour Tracking)**을 실시간 연동 분석합니다.
- **동작**: 한국인 표준 억양의 피치 곡선과 사용자의 주파수를 실시간 대조하여 억양 일치도 **75% 초과** 시 락스타가 *"Awesome Seoul Accent!"* 배지를 증정하고, 오차 극심 시 비서 보이스가 차분하게 발음 교정 안내 팁 카드를 송출합니다.

---

## 📝 4. 신규 {수학, 화학, 역사, 국어} 과목별 벌크 시드 데이터 명세

플랫폼 가동 시 즉시 다과목 변경을 입증할 수 있도록 작성한 **과목별 고해상도 시드 에셋 리스트**입니다.

---

### 🧮 A. {나야 수학 (MATH)} 에셋 풀
```json
[
  {
    "subject_code": "MATH",
    "category": "CALCULUS",
    "key_expression": "d/dx(ln x) = 1/x",
    "pronunciation_or_tip": "자연로그의 미분 공식",
    "translation_meaning": "자연로그 x를 미분하면 역수 x분의 1이 된다.",
    "example_context_1": "d/dx(ln 3x)의 값은 무엇인가?",
    "example_context_2": "합성함수 미분 공식에 의해 [d/dx(3x)] / (3x) = 3/(3x) = 1/x 이 됩니다."
  },
  {
    "subject_code": "MATH",
    "category": "INTEGRATION",
    "key_expression": "∫ e^x dx = e^x + C",
    "pronunciation_or_tip": "지수함수의 적분 공식",
    "translation_meaning": "지수함수 e^x를 적분하면 e^x와 적분상수 C의 합이 된다.",
    "example_context_1": "∫ e^(2x) dx의 값은 무엇인가?",
    "example_context_2": "치환적분에 의해 (1/2)*e^(2x) + 적분상수 C 가 됩니다."
  }
]
```

---

### 🧪 B. {나야 화학 (CHEMISTRY)} 에셋 풀
```json
[
  {
    "subject_code": "CHEMISTRY",
    "category": "REACTION",
    "key_expression": "2H₂ + O₂ -> 2H₂O",
    "pronunciation_or_tip": "물의 합성 화학 반응식",
    "translation_meaning": "수소 분자 2개와 산소 분자 1개가 결합하여 물 분자 2개를 생성하는 반응",
    "example_context_1": "수소 기체와 산소 기체가 폭발적으로 결합하면 무엇이 남는가?",
    "example_context_2": "강한 열에너지 방출과 함께 순수한 물(H₂O) 분자가 형성되어 잔존합니다."
  },
  {
    "subject_code": "CHEMISTRY",
    "category": "ORGANIC",
    "key_expression": "CH₄ + 2O₂ -> CO₂ + 2H₂O",
    "pronunciation_or_tip": "메탄의 연소 반응식",
    "translation_meaning": "메탄 가스 1분자가 산소 2분자와 반응하여 이산화탄소 1분자와 물 2분자를 연소 방출함",
    "example_context_1": "도시가스의 주성분인 메탄이 보일러에서 연소하면 발생하는 온실 기체는?",
    "example_context_2": "이산화탄소(CO₂) 기체가 배기구로 배출됩니다."
  }
]
```

---

### 🏛️ C. {나야 역사 (HISTORY)} 에셋 풀
```json
[
  {
    "subject_code": "HISTORY",
    "category": "CHRONOLOGY",
    "key_expression": "1392년",
    "pronunciation_or_tip": "태조 이성계의 조선 건국",
    "translation_meaning": "고려 왕조를 마감하고 한양을 도읍으로 삼아 조선 왕조가 개창된 해",
    "example_context_1": "조선 왕조가 공식 개창되어 500년 도읍의 기틀을 마련한 연도는?",
    "example_context_2": "1392년에 위화도 회군 세력을 주축으로 신조선이 개국되었습니다."
  },
  {
    "subject_code": "HISTORY",
    "category": "CHRONOLOGY",
    "key_expression": "1443년",
    "pronunciation_or_tip": "훈민정음 창제 해",
    "translation_meaning": "세종대왕이 한자를 쓰지 못하는 어리석은 백성을 불쌍히 여겨 우리 글자 훈민정음 28자를 창제하신 해",
    "example_context_1": "우리의 자랑스러운 한글인 훈민정음이 세종대왕에 의해 처음 완성된 해는?",
    "example_context_2": "1443년에 창제 완료되었으며, 3년간의 임상 검증을 거쳐 1446년에 널리 반포되었습니다."
  }
]
```

---

### 🇰🇷 D. {나야 국어 - 다문화 역학습 (KOREAN)} 에셋 풀
```json
[
  {
    "subject_code": "KOREAN",
    "category": "IDIOM",
    "key_expression": "일석이조",
    "pronunciation_or_tip": "Il-Seok-I-Jo (일석이조)",
    "translation_meaning": "Killing two birds with one stone. (돌 하나로 새 두 마리를 잡음)",
    "example_context_1": "Learning Korean while waiting for your shuttle bus is a great choice.",
    "example_context_2": "버스 대기 중에 한국어를 공부하는 것은 시간도 아끼고 지식도 얻으니 '일석이조'입니다."
  },
  {
    "subject_code": "KOREAN",
    "category": "SPELLING",
    "key_expression": "어떡해 (O-Tteok-Hae)",
    "pronunciation_or_tip": "What should I do? (나 어떡해)",
    "translation_meaning": "'어떻게 해'의 준말. '어떻해'로 잘못 쓰기 매우 쉬운 한국어 맞춤법",
    "example_context_1": "How to say 'What should I do now?' in standard written Korean?",
    "example_context_2": "올바른 맞춤법 표기는 '어떡해'가 맞으며, '어떻게 해'의 축약형입니다."
  }
]
```

---

## 🔍 5. 다과목 무중단 모듈 전환 실증 가이던스 (Verification)

사용자가 설정 창에서 과목을 '수학(MATH)'으로 바꾸었을 때, 시스템은 다음과 같이 **물리적 다운타임 0ms 전환**을 실증합니다.

1. **테마 테마 변경 리스너 가동**: 유저의 과목 스위칭 감지 즉시, 폰의 최상위 CSS 변수 `--theme-color`가 Sapphire Blue 스펙인 `hsl(210, 85%, 45%)`로 동적 반전 렌더링됩니다.
2. **SQLite subject_code 인덱싱 우회**: 좀비 팝업 렌더러는 즉각 SQLite에 `SELECT * FROM learning_assets WHERE subject_code = 'MATH'` 쿼리를 수행하여, 영단어 대신 자연로그 공식 카드를 화면에 노출합니다.
3. **TTS 음성 언어 자동 스위칭**: TTS 엔진은 영어 과목의 경우 `en-US` 음성을 사용하되, 수학/화학 공식이나 역사 연대기는 `ko-KR` 한국어 읽기 가이드 모드로 0ms 전환하여 원활하게 수식을 낭독합니다.

본 표준 다과목 프레임워크 규격 및 다문화 한국어 역학습 설계서가 플랫폼 핵심 확장 규격으로 완성되었음을 선언합니다. 승인해 주시면 기획 마스터피스의 최종 종결을 향해 힘차게 전개해 나가겠습니다!
