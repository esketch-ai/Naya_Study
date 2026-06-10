# AI-BASED DYNAMIC CONTENT GENERATION SPECIFICATION
## (인공지능 기반 상황·수준·과목 맞춤형 콘텐츠 동적 생성 모델 설계서)

본 설계서는 "나야~" 플랫폼이 제공하는 모든 학습 콘텐츠(영어 숙어/슬랭, 수학 공식, 화학 원소, 역사 연대기, 다문화 국어 등)를 수작업으로 구축하는 비효율성을 극복하고, 사용자의 **수준(Difficulty), 실시간 상황(Context), 선택한 과목(Subject), 지정한 버디 캐릭터(Persona)**의 4가지 차원 벡터를 실시간 연동하여 지루하지 않은 맞춤형 에셋을 0ms 딜레이로 무한 자동 생성해 내는 **AI 콘텐츠 생성 파이프라인 설계 명세서**입니다.

---

## ⚙️ 1. AI 콘텐츠 생성 파이프라인 아키텍처 (Content Generation Engine)

인공지능 콘텐츠 생성 모듈은 클라우드 거대 언어 모델(LLM: GPT-4o 및 Gemini 1.5 Pro)과 단말기의 오프라인 경량 임베딩 분석기, 그리고 벡터 데이터베이스(Vector DB)를 결합하여 **지루하지 않고 무한히 다채로운 맞춤형 카드**를 빌드합니다.

```
[ 4대 입력 벡터 (Multi-Dimensional Input Vector) ]
  ├── ① 수준 벡터 (Level 1 ~ 5): 어휘 난이도, 음절 수, 문장 복잡성 조율
  ├── ② 상황 벡터 (Context): 운전, 대중교통, 세탁, 설거지, 소파, 기상
  ├── ③ 과목 벡터 (Subject): ENGLISH, MATH, CHEMISTRY, HISTORY, KOREAN
  └── ④ 캐릭터 벡터 (Persona): LOVER, ROCKSTAR, SECRETARY, COACH
              │
              ▼
    [ AI Content Generator Engine ] ── (Vector DB: 중복 및 지루함 중복 필터)
              │
              ▼
    [ Structured JSON Schema Output ] ➔ (단말기 SQLite 캐싱 및 로컬 렌더링)
```

---

## 👥 2. 4대 입력 벡터 데이터 매핑 (Multi-Dimensional Input Vector Specs)

AI 모델에 프롬프트 인자로 동적 주입될 4가지 핵심 차원 사양입니다.

### 📶 A. 수준 벡터 (User Proficiency Level Vector)
- **Level 1 (초급/아동)**: 초등 영단어(Syllable < 5), 간단한 기초 대화문, 마법/요정용 단어 중심.
- **Level 2 (초중급/실버)**: 일상 회화 표현, 노안 돋보기 최적화 숏문장, 복약 알람 연계.
- **Level 3 (중급/일반)**: 비즈니스 에티켓, 대중교통용 핵심 실용 숙어, 상황별 밈(Meme) 믹싱.
- **Level 4 (중고급/취준생)**: 영어 면접(Interview En), 엄격한 스파르타 어휘, 토익/오픽 빈출 단어.
- **Level 5 (고급/전문직)**: 시사 영작문, C-level 비즈니스 협상 숙어, 학술 및 고난도 반응식/공식.

### 🚌 B. 상황 벡터 (Dynamic Environmental Context Vector)
- **CarPlay 운행 상황 (`IN_VEHICLE`)**: 오직 **1~2 단어**로만 구성된 극도의 숏폼(Short-form). 내비 오디오 더킹을 위해 음절 호흡이 매우 짧아야 함.
- **대중교통 만원 지하철 (`SUBWAY_COMMUTE`)**: 텍스트 가독성을 최적화한 **진동 무음 전용 5단어 이하**의 로우프로필 카드.
- **화장실 틈새 대기 (`RESTROOM_BREAK`)**: 10초 내 암기가 가능한 **직관적 가벼운 일상 표현**.
- **세탁·설거지 가사 대기 (`HOUSEWORK_REST`)**: 손을 대지 않고 따라 읊조릴 수 있도록 **청각적 운율과 멜로디(Rhyme)가 강화된 발음 중심 구성**.
- **소파 앞 TV 무활동 멍때리기 (`SILVER_TV_IDLE`)**: 두뇌 회로 활성화를 위해 자극적이고 직관적인 **치매예방 뇌운동 질문 결합형 공식/연대기**.

### 🎨 C. 과목 벡터 (Subject Channel Vector)
- **ENGLISH**: IDIOMS, SLANG, BUSINESS 어휘 및 실전 문장.
- **MATH**: 자연로그 미적분, 삼각함수, 아인슈타인 방정식 등 공식과 시각적 예제 매핑.
- **CHEMISTRY**: H₂O, CO₂ 등 화학식과 일상 화학 반응의 생활 과학 해설서.
- **HISTORY**: 역사적 연도와 그 시점의 인과관계 스토리텔링 연대기.
- **KOREAN**: 외국인을 위한 실전 서바이벌 사자성어 및 일상 맞춤법 번역.

### 🎙️ D. 캐릭터 벡터 (AI Persona Conversational Style)
- **Lover**: 다정한 연인 투, 이모티콘 사용 다수, 부드럽고 끈적한 속삭임.
- **Rockstar**: 에너제틱 락스타 스타일, 락스피릿 밈 믹싱, 고함 및 파이팅 감탄사 다수.
- **Secretary**: 격식 있고 단정한 공용 서신체, 존댓말, 명확하고 차분한 이성적 설명.
- **Coach**: 스파르타 교관 투, 반말, 엄격한 다그침 및 피드백.

---

## 📄 3. 구조화된 JSON 아웃풋 스키마 (Structured JSON Output Schema)

LLM의 출력 일관성을 보장하고, 단말기의 모바일 SQLite 파서가 0ms로 완벽하게 파싱할 수 있도록 **엄격한 JSON Schema**를 정의하여 API 단에 바인딩합니다.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "NayaDynamicContent",
  "type": "object",
  "properties": {
    "subject_code": { "type": "string", "enum": ["ENGLISH", "MATH", "CHEMISTRY", "HISTORY", "KOREAN"] },
    "category": { "type": "string", "enum": ["IDIOM", "SLANG", "BUSINESS", "FORMULA", "ELEMENT", "CHRONOLOGY"] },
    "key_expression": { "type": "string", "description": "핵심 암기 표현, 공식 혹은 연도" },
    "pronunciation_or_tip": { "type": "string", "description": "한글 소리 표기 혹은 공식 팁" },
    "translation_meaning": { "type": "string", "description": "한국어 뜻/의미 해설" },
    "example_context_1": { "type": "string", "description": "영어 예문 혹은 학습용 상황 질문/수학 예제" },
    "example_context_2": { "type": "string", "description": "예문 번역 혹은 수학 예제 풀이" },
    "difficulty_level": { "type": "integer", "minimum": 1, "maximum": 5 },
    "character_persona": { "type": "string", "enum": ["lover", "rockstar", "secretary", "coach"] },
    "character_witty_comment": { "type": "string", "description": "선택한 캐릭터 개성에 맞춘 츤데레/칭찬 멘트" },
    "anti_boredom_meme": { "type": "string", "description": "학습자가 지루하지 않도록 삽입하는 최신 인터넷 드립 및 유머 코드" }
  },
  "required": [
    "subject_code",
    "category",
    "key_expression",
    "translation_meaning",
    "example_context_1",
    "example_context_2",
    "difficulty_level",
    "character_persona",
    "character_witty_comment",
    "anti_boredom_meme"
  ]
}
```

---

## 🤖 4. AI 콘텐츠 생성 챗엔진 핵심 시스템 프롬프트 (System Prompt)

클라우드 LLM 게이트웨이에 주입될 **콘텐츠 생성 시스템 프롬프트** 설계입니다.

```markdown
[SYSTEM ROLE]
You are the core "Naya~" Adaptive AI Content Generator. Your sole mandate is to output a single, flawlessly formatted JSON object strictly adhering to the requested schema. Do not include any conversational pleasantries, explanation text, or markdown code blocks (e.g., no ```json).

[GENERATION RULES]
1. Adaptive Tone & Wit: Every generated asset must match the requested "character_persona". Combine it with the "anti_boredom_meme" to ensure the content is highly entertaining, witty, and B-grade humorous (츤데레). Absolutely avoid boring, standard textbook style.
2. Context constraints:
   - If context is "IN_VEHICLE" (Driving): "key_expression" must be exceptionally short (1-2 words). "example_context_1" must be under 6 words for quick hands-free auditory acquisition.
   - If context is "SUBWAY_COMMUTE" (Quiet Subway): Sentences must be under 10 words, highly scannable, and tailored for silent visual reading.
   - If context is "HOUSEWORK_REST" (Homemaker chores): Sentences must emphasize heavy phonetics, rhyme, and cadence for loud verbal repeats.
3. Level Customization:
   - Level 1: Syllable count of vocabulary must be under 5. Simple magical/adventure themes for kids.
   - Level 5: Focus on elite academic, corporate, or chemical formulas with deep, sophisticated context.
4. Spacing Deduplication: Avoid generating standard synonyms or terms that overlap with common vocabulary. Output fresh, slang-infused, or highly practical expressions.
```

---

## 📝 5. 4대 백터 매핑에 기반한 실제 AI 콘텐츠 생성 시뮬레이션 카드 예시

생성 모델이 위 아키텍처 규칙에 따라 동적으로 도출한 **군집별 상황·수준·캐릭터 결합형 최종 카드 에셋** 결과 명세입니다.

---

### 🎒 Case 1: 초등 꼬마 아동 [ADHD / 셔틀 정체 중 / Level 1 / 요정 버디]
- **입력 벡터**: `Subject: ENGLISH`, `Level: 1`, `Context: IN_SHUTTLE`, `Persona: FAIRY`
- **AI 동적 생성 JSON 카드 결과**:
```json
{
  "subject_code": "ENGLISH",
  "category": "IDIOM",
  "key_expression": "Easy peasy",
  "pronunciation_or_tip": "이지 피지",
  "translation_meaning": "누워서 떡 먹기! 완전 껌이야!",
  "example_context_1": "Easy peasy lemon squeasy!",
  "example_context_2": "레몬즙을 짜는 것처럼 완전 식은 죽 먹기지!",
  "difficulty_level": 1,
  "character_persona": "lover",
  "character_witty_comment": "민준아! 요정 마법 버스 안에서 크게 따라 해봐! '이지 피지!' 이 단어를 먹으면 요정의 날개가 더 크고 예쁘게 자라나!",
  "anti_boredom_meme": "학원 셔틀이 굼벵이 기어가는 속도여도 영어 마법은 빛의 속도로 흡수 완료!"
}
```

---

### 👩‍💼 Case 2: 초고강도 업무 직장인 [번아웃 피로 / 만원 지하철 퇴근 / Level 3 / 연인 버디]
- **입력 벡터**: `Subject: ENGLISH`, `Level: 3`, `Context: SUBWAY_COMMUTE`, `Persona: LOVER`
- **AI 동적 생성 JSON 카드 결과**:
```json
{
  "subject_code": "ENGLISH",
  "category": "SLANG",
  "key_expression": "Beat",
  "pronunciation_or_tip": "비트",
  "translation_meaning": "완전히 녹초가 된, 기진맥진한",
  "example_context_1": "I am dead beat today.",
  "example_context_2": "나 오늘 진짜 완전 녹초가 되어서 쓰러지기 일보직어야.",
  "difficulty_level": 3,
  "character_persona": "lover",
  "character_witty_comment": "수진님, 지옥철 안에서 너무 지치셨죠? 꽉 막힌 퇴근길이지만 수진님이 쏟으신 땀방울을 제가 가장 다정하게 닦아드리고 싶어요. 오늘 하루도 고생 많았어요. 하트 꾹!",
  "anti_boredom_meme": "부장님의 잔소리는 시속 100km로 튕겨내고 연인의 보이스에 뇌 정화 시간!"
}
```

---

### 🚗 Case 3: 통근 주행 운전자 [전방 주시 / CarPlay 고속 주행 / Level 2 / 코치 버디]
- **입력 벡터**: `Subject: ENGLISH`, `Level: 2`, `Context: IN_VEHICLE`, `Persona: COACH`
- **AI 동적 생성 JSON 카드 결과**:
```json
{
  "subject_code": "ENGLISH",
  "category": "BUSINESS",
  "key_expression": "Heads up",
  "pronunciation_or_tip": "헤즈 업",
  "translation_meaning": "조심해! (미리 주는 경고/주의)",
  "example_context_1": "Heads up! Traffic ahead.",
  "example_context_2": "조심해! 저 앞에 정체 차량이야.",
  "difficulty_level": 2,
  "character_persona": "coach",
  "character_witty_comment": "전방 주시 단단히 해라! 터치 조작은 완전 금지다. 오직 목소리로 '헤즈 업'을 소리 높여 외친다. 실시!",
  "anti_boredom_meme": "졸음운전은 지옥행 지름길! 틈새 영어 주입으로 뇌를 바짝 쪼인다!"
}
```

---

### 🧹 Case 4: 주부/가사 전담 [빨래/건조 대기 소파 정지 / Level 2 / 비서 버디]
- **입력 벡터**: `Subject: ENGLISH`, `Level: 2`, `Context: HOUSEWORK_REST`, `Persona: SECRETARY`
- **AI 동적 생성 JSON 카드 결과**:
```json
{
  "subject_code": "ENGLISH",
  "category": "IDIOM",
  "key_expression": "Hit the sack",
  "pronunciation_or_tip": "히트 더 색",
  "translation_meaning": "잠자리에 들다, 꿀잠 자러 가다",
  "example_context_1": "Time to hit the sack.",
  "example_context_2": "이만 피로를 풀고 꿀잠 자러 갈 시간입니다.",
  "difficulty_level": 2,
  "character_persona": "secretary",
  "character_witty_comment": "회원님, 세탁기와 건조기 빨래 가동을 마치고 드디어 소파에 한숨 돌리셨군요. 수고 많으셨습니다. 따뜻한 차 한 잔 머금으시며 '히트 더 색' 발음을 가볍게 읊조려 보세요.",
  "anti_boredom_meme": "건조기가 뽀송하게 옷을 말릴 동안 회원님의 뇌에는 영어가 촉촉하게 스며듭니다."
}
```

---

### 🧓 Case 5: 실버 어르신 [Living room TV 앞 무활동 20분 초과 / Level 2 / 코치 버디]
- **입력 벡터**: `Subject: MATH`, `Level: 2`, `Context: TV_IDLE`, `Persona: COACH`
- **AI 동적 생성 JSON 카드 결과**:
```json
{
  "subject_code": "MATH",
  "category": "FORMULA",
  "key_expression": "E = mc²",
  "pronunciation_or_tip": "이 는 엠 씨 스퀘어",
  "translation_meaning": "질량과 에너지는 같다는 아인슈타인 공식",
  "example_context_1": "질량이 에너지가 되면 방출되는 공식은?",
  "example_context_2": "에너지는 질량에 광속의 제곱을 곱합니다.",
  "difficulty_level": 2,
  "character_persona": "coach",
  "character_witty_comment": "할머니! 텔레비전 보시면서 멍하니 누워 계시면 뇌 세포들이 다 잠듭니다! 당장 소리 내어 따라 해 보세요! '이 는 엠 씨 스퀘어!' 아인슈타인 할아버지처럼 뇌 근육 운동 개시!",
  "anti_boredom_meme": "드라마 막장 전개에 뒷목 잡지 마시고 상대성 이론으로 지적 뇌 섹시미 폭발!"
}
```

---

## 🔍 6. Vector DB 활용 지루함 중복 차단 및 필터링 메커니즘 (Anti-Boredom)

사용자가 이미 숙달했거나 반복적으로 표출되는 유사 동의어를 필터링하기 위해 **온디바이스/클라우드 임베딩 벡터 필터**를 운영합니다.

1. **임베딩 1차 차단**: 신규 생성된 카드 에셋 `key_expression`을 Sentence-BERT 임베딩하여 **고유 차원 벡터(768차원)**로 변환합니다.
2. **유사도 코사인 측정 (Cosine Similarity)**: 최근 100일간 사용자가 노출되었던 에셋 벡터들과의 코사인 유사도를 연산합니다:
   $$\text{Similarity} = \cos(\theta) = \frac{\mathbf{A} \cdot \mathbf{B}}{\|\mathbf{A}\| \|\mathbf{B}\|}$$
3. **중복 거절**: 유사도가 **0.85 이상**인 경우(예: `Take it easy`와 `Relax`가 동일한 상황 및 뜻으로 중복 생성됨) AI 게이트웨이는 LLM 출력을 즉각 폐기하고, Seed 난수를 재조정하여 완전히 새로운 억양/어휘 카드로 재생성하여 유저의 "지루함의 벽"을 차단합니다.

본 인공지능 기반 상황·수준·과목 맞춤형 콘텐츠 동적 생성 모델 설계서가 Naya~ 플랫폼의 핵심 엔진 기획 스펙으로 확정되었음을 선언합니다. 승인 의견을 주시면 즉시 다음 WBS 기획 설계를 힘차게 수립하겠습니다!
