# DATABASE SCHEMA DEFINITION (데이터베이스 설계서)

본 문서는 "나야~ 영어" 및 후속 확장 과목 시리즈 플랫폼의 로컬(SQLite) 및 클라우드(PostgreSQL)용 관계형 데이터베이스 설계 명세서입니다.

---

## 1. 관계형 스키마 설계 (Entity Relationship & DDL)

데이터베이스는 사용자의 생체 상태, 일상 틈새 노출 이력, 퀴즈 정답률을 기록하여 오답 주기를 맞춤 설계할 수 있도록 설계되었습니다.

```sql
-- ====================================================================
-- 1. USER PROFILE TABLE (사용자 기본 및 보이스 설정)
-- ====================================================================
CREATE TABLE user_profiles (
    user_id TEXT PRIMARY KEY,
    user_name TEXT NOT NULL,
    wakeup_time TEXT DEFAULT '07:00',      -- 좀비 기상 모드 감지 기준
    sleep_time TEXT DEFAULT '23:00',       -- 좀비 Mute 진입 기준
    preferred_voice TEXT DEFAULT 'lover',  -- lover, energetic, secretary, coach
    stress_threshold INTEGER DEFAULT 75,   -- Lover 보이스 자동 매칭 임계치
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_wakeup_sleep ON user_profiles(wakeup_time, sleep_time);

-- ====================================================================
-- 2. LEARNING ASSETS TABLE (다과목 공용 통합 학습 풀)
-- ====================================================================
CREATE TABLE learning_assets (
    asset_id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject_code TEXT NOT NULL,            -- 'ENGLISH', 'MATH', 'CHEMISTRY', 'HISTORY'
    category TEXT NOT NULL,                -- 'IDIOM', 'FORMULA', 'ELEMENT', 'CHRONOLOGY'
    key_expression TEXT NOT NULL,          -- 핵심 키워드 (예: 'Take it easy', 'E=mc²')
    pronunciation_or_tip TEXT,             -- 공식 팁 또는 발음 기호
    translation_meaning TEXT NOT NULL,     -- 뜻 / 해설
    example_context_1 TEXT,                -- 영어 예문 또는 수학 예제 문제
    example_context_2 TEXT,                -- 예문 번역 또는 예제 공식 해설
    difficulty_level INTEGER DEFAULT 1,     -- 난이도 (1 ~ 5)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_asset_subject_diff ON learning_assets(subject_code, difficulty_level);

-- ====================================================================
-- 3. WEARABLE HEALTH LOGS TABLE (워치 생체 신호 적재)
-- ====================================================================
CREATE TABLE wearable_health_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    heart_rate INTEGER,
    stress_index INTEGER,                  -- HRV RMSSD 기반 환산 스트레스 (0~100)
    detected_activity TEXT,                -- 'STILL', 'WALKING', 'IN_VEHICLE'
    logged_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_health_user_time ON wearable_health_logs(user_id, logged_time DESC);

-- ====================================================================
-- 4. LEARNING PROGRESS LOGS TABLE (망각곡선 학습 상태 관리)
-- ====================================================================
CREATE TABLE learning_progress_logs (
    progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    asset_id INTEGER NOT NULL,
    exposure_count INTEGER DEFAULT 0,      -- 좀비 팝업으로 사용자에게 강제 노출된 횟수
    correct_count INTEGER DEFAULT 0,       -- 저녁 12문제 퀴즈에서 맞춘 횟수
    incorrect_count INTEGER DEFAULT 0,     -- 저녁 퀴즈에서 틀린 횟수
    repetition_interval INTEGER DEFAULT 1, -- SM-2 알고리즘 기준 다음 노출 간격 (일)
    easiness_factor REAL DEFAULT 2.5,      -- SM-2 알고리즘 난이도 계수 (E-Factor)
    next_review_date TEXT NOT NULL,        -- 다음 학습 노출일자 ('YYYY-MM-DD')
    last_status TEXT DEFAULT 'RETRY',      -- 'MEMORIZED', 'RETRY'
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    FOREIGN KEY(asset_id) REFERENCES learning_assets(asset_id) ON DELETE CASCADE,
    UNIQUE(user_id, asset_id)
);

CREATE INDEX idx_progress_user_review ON learning_progress_logs(user_id, next_review_date);
```

---

## 2. 에빙하우스 망각곡선 최적화 알고리즘 (SuperMemo-2)

유저에게 단어를 주입하고 저녁에 채점한 뒤, 데이터베이스에 저장될 E-Factor와 복습 주기(Interval)를 업데이트하는 공식 명세입니다.

### 📈 SM-2 알고리즘 수학 구조
저녁 퀴즈 채점 점수(Quality, $q$: 0: 완전 오답 ~ 5: 즉시 정답)에 따른 동적 연산:

1. **난이도 계수 ($EF$, Easiness Factor) 업데이트**:
   $$EF' = EF + (0.1 - (5 - q) \times (0.08 + (5 - q) \times 0.02))$$
   *(단, $EF'$의 최소 한계치는 $1.3$으로 고정)*
2. **복습 간격 ($I$, Interval 일수) 업데이트**:
   - $n = 1$ (최초 암기 성공 시): $I(1) = 1$
   - $n = 2$ (두 번째 성공 시): $I(2) = 6$
   - $n > 2$ (세 번째 이상 성공 시): $I(n) = I(n-1) \times EF'$

### 💻 Database Update Trigger (SQL / Node.js)
퀴즈가 채점되었을 때 PROGRESS 테이블을 동적으로 갱신하는 쿼리 및 산출 로직입니다.

```javascript
// Node.js Express 기반 SM-2 스케줄러 갱신 코드 예시
function calculateSM2(q, prevInterval, prevEF) {
  let ef = prevEF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  if (ef < 1.3) ef = 1.3;

  let interval = 1;
  if (q >= 3) {
    if (prevInterval === 1) {
      interval = 6;
    } else {
      interval = Math.round(prevInterval * ef);
    }
  } else {
    interval = 1; // 오답 시 최초 복습 주기로 폴백
  }
  
  return { interval, ef };
}
```

---

## 3. 다과목 확장 및 공용 데이터 모델링

"나야~" 플랫폼 코어 엔진은 `{learning_assets}`의 `subject_code`와 `category` 컬럼을 이용해 콘텐츠 타입을 동적으로 해석합니다.

### 🔄 과목별 데이터 구조 맵핑 명세서 (Common Subject Mapping)

- **영어 (`ENGLISH`)**:
  - `key_expression`: 단어/숙어/패턴 문장 (예: *"Kill two birds with one stone"*)
  - `pronunciation_or_tip`: 발음 기호 (예: *"[kɪl tuː bɜːdz wɪð wʌn stəʊn]"*)
  - `translation_meaning`: 한국어 뜻 번역 (예: *"일석이조, 일거양득"*)
  - `example_context_1`: 영어 예문
  - `example_context_2`: 한글 번역 해설
- **수학 (`MATH`)**:
  - `key_expression`: 암기할 필수 공식 (예: *"$\int \frac{1}{x} dx = \ln|x| + C$"*)
  - `pronunciation_or_tip`: 공식 적용 공식명 (예: *"자연로그 적분 공식"*)
  - `translation_meaning`: 한글 의미 (예: *"역수 x분의 1을 부정적분하면 자연로그의 절댓값 x가 됨"*)
  - `example_context_1`: 틈새 암산 유도 문제 (예: *"$\int \frac{2}{2x+3} dx$의 부정적분은?"*)
  - `example_context_2`: 수학 풀이 공식 (예: *"치환적분법에 의해 $\ln|2x+3| + C$ 입니다."*)
- **화학 (`CHEMISTRY`)**:
  - `key_expression`: 원소 기호 및 반응식 (예: *"$\text{NaCl}$"*)
  - `pronunciation_or_tip`: 물질 이름 (예: *"염화나트륨"*)
  - `translation_meaning`: 한국어 설명 (예: *"나트륨 이온과 염화 이온이 결합한 소금의 주성분"*)
  - `example_context_1`: 퀴즈 유도 반응식 (예: *"산($\text{HCl}$)과 염기($\text{NaOH}$)가 반응하면 물($\text{H}_2\text{O}$)과 형성되는 염은?"*)
  - `example_context_2`: 화학 반응식 완성 해설 (예: *"중화 반응에 의해 $\text{NaCl}$이 형성됩니다."*)
