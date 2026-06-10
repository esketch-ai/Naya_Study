const Database = require('better-sqlite3');
const path = require('path');

// SQLite database path
const DB_PATH = process.env.DB_PATH || './database.sqlite';

let db;

// Initialize database connection
function initDatabase() {
  if (db) return db;
  
  // Use in-memory or file-based SQLite
  const isDev = process.env.NODE_ENV === 'development';
  db = new Database(isDev ? ':memory:' : DB_PATH);
  
  // Enable foreign keys
  db.pragma('foreign_keys = ON');
  
  return db;
}

// Initialize database schema
function initializeSchema() {
  const db = initDatabase();
  
  // User profiles table
  db.exec(`
    CREATE TABLE IF NOT EXISTS user_profiles (
      user_id TEXT PRIMARY KEY,
      user_name TEXT NOT NULL,
      wakeup_time TEXT DEFAULT '07:00',
      sleep_time TEXT DEFAULT '23:00',
      preferred_voice TEXT DEFAULT 'lover',
      stress_threshold INTEGER DEFAULT 75,
      active_error_state TEXT DEFAULT 'NORMAL',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_user_wakeup_sleep ON user_profiles(wakeup_time, sleep_time);
  `);

  // Learning assets table
  db.exec(`
    CREATE TABLE IF NOT EXISTS learning_assets (
      asset_id INTEGER PRIMARY KEY AUTOINCREMENT,
      subject_code TEXT NOT NULL,
      category TEXT NOT NULL,
      key_expression TEXT NOT NULL,
      pronunciation_or_tip TEXT,
      translation_meaning TEXT NOT NULL,
      example_context_1 TEXT,
      example_context_2 TEXT,
      difficulty_level INTEGER DEFAULT 1,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS idx_asset_subject_diff ON learning_assets(subject_code, difficulty_level);
  `);

  // Wearable health logs table
  db.exec(`
    CREATE TABLE IF NOT EXISTS wearable_health_logs (
      log_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      heart_rate INTEGER,
      stress_index INTEGER,
      detected_activity TEXT,
      logged_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE
    );
    
    CREATE INDEX IF NOT EXISTS idx_health_user_time ON wearable_health_logs(user_id, logged_time DESC);
  `);

  // Learning progress logs table
  db.exec(`
    CREATE TABLE IF NOT EXISTS learning_progress_logs (
      progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      asset_id INTEGER NOT NULL,
      exposure_count INTEGER DEFAULT 0,
      correct_count INTEGER DEFAULT 0,
      incorrect_count INTEGER DEFAULT 0,
      repetition_interval INTEGER DEFAULT 1,
      easiness_factor REAL DEFAULT 2.5,
      next_review_date TEXT NOT NULL,
      last_status TEXT DEFAULT 'RETRY',
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES user_profiles(user_id) ON DELETE CASCADE,
      FOREIGN KEY(asset_id) REFERENCES learning_assets(asset_id) ON DELETE CASCADE,
      UNIQUE(user_id, asset_id)
    );
    
    CREATE INDEX IF NOT EXISTS idx_progress_user_review ON learning_progress_logs(user_id, next_review_date);
  `);

  // Telemetry error logs table
  db.exec(`
    CREATE TABLE IF NOT EXISTS telemetry_error_logs (
      log_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      error_code TEXT NOT NULL,
      error_message TEXT,
      stress_level_at_error REAL,
      status TEXT DEFAULT 'ACTIVE',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      resolved_at DATETIME,
      resolution_action TEXT
    );
  `);

  console.log('✅ Database schema initialized');
}

// SM-2 Algorithm Implementation
function calculateSM2(quality, prevReps, prevEF) {
  let reps = prevReps;
  let ef = prevEF;
  let intervalDays = 1;

  if (quality >= 3) { // Correct answer
    intervalDays = reps === 0 ? 1 : reps === 1 ? 6 : Math.round(intervalDays * ef);
    reps += 1;
  } else { // Incorrect - reset
    reps = 0;
    intervalDays = 1;
  }

  // EF update formula
  ef = ef + (0.1 - (5 - quality) * (0.8 + (5 - quality) * 0.2));
  if (ef < 1.3) ef = 1.3;

  return { reps, intervalDays, ef };
}

// Seed initial learning assets (4 subjects)
function seedLearningAssets() {
  const db = initDatabase();
  
  const englishWords = [
    { expression: "Take it easy", meaning: "진정해, 서두르지 마", example1: "Take it easy! We still have plenty of time.", example2: "진정해! 우리 아직 시간 많이 남아있어." },
    { expression: "Kill two birds with one stone", meaning: "일석이조", example1: "I'll kill two birds with one stone by studying while commuting.", example2: "통근하면서 공부하면 일석이조야!" },
    { expression: "Break a leg", meaning: "성공해 (축하)", example1: "You got the interview? Break a leg!", example2: "면접 봤어? 성공해!" }
  ];

  const mathFormulas = [
    { expression: "∫(1/x)dx = ln|x| + C", meaning: "역수 적분 공식", example1: "∫(2/(2x+3))dx 의 부정적분은?", example2: "치환적분법에 의해 ln|2x+3| + C 입니다." },
    { expression: "E=mc²", meaning: "질량 - 에너지 등가원리", example1: "핵반응에서 질량의 일부가 에너지로 변환됨.", example2: "아인슈타인의 유명한 공식이지!" }
  ];

  const chemistryElements = [
    { expression: "NaCl", meaning: "염화나트륨 (소금)", example1: "산(HCl)과 염기(NaOH)가 반응하면?", example2: "중화 반응에 의해 NaCl 이 형성됩니다." },
    { expression: "H₂O", meaning: "물 분자", example1: "수소와 산소가 결합한 화합물.", example2: "생명체의 필수 구성 성분이지!" }
  ];

  const historyChronologies = [
    { expression: "Industrial Revolution", meaning: "산업혁명 (1760-1840)", example1: "영국에서 시작된 기술 혁신의 시대.", example2: "공장制度和 도시화가 시작되었어요." },
    { expression: "World War II", meaning: "제 2 차 세계대전 (1939-1945)", example1: "최대 규모의 전쟁으로 유엔 설립.", example2: " Холокост과 원자폭탄이 끝이었죠." }
  ];

  // Insert English words
  englishWords.forEach(item => {
    db.prepare(`INSERT INTO learning_assets 
      (subject_code, category, key_expression, pronunciation_or_tip, translation_meaning, 
       example_context_1, example_context_2, difficulty_level)
      VALUES ('ENGLISH', 'IDIOM', ?, NULL, ?, ?, ?, 1)`).run(
      item.expression, item.meaning, item.example1, item.example2
    );
  });

  // Insert math formulas
  mathFormulas.forEach(item => {
    db.prepare(`INSERT INTO learning_assets 
      (subject_code, category, key_expression, pronunciation_or_tip, translation_meaning, 
       example_context_1, example_context_2, difficulty_level)
      VALUES ('MATH', 'FORMULA', ?, ?, ?, ?, ?, 2)`).run(
      item.expression, item.meaning, item.example1, item.example2
    );
  });

  // Insert chemistry elements
  chemistryElements.forEach(item => {
    db.prepare(`INSERT INTO learning_assets 
      (subject_code, category, key_expression, pronunciation_or_tip, translation_meaning, 
       example_context_1, example_context_2, difficulty_level)
      VALUES ('CHEMISTRY', 'ELEMENT', ?, NULL, ?, ?, ?, 1)`).run(
      item.expression, item.meaning, item.example1, item.example2
    );
  });

  // Insert history chronologies
  historyChronologies.forEach(item => {
    db.prepare(`INSERT INTO learning_assets 
      (subject_code, category, key_expression, pronunciation_or_tip, translation_meaning, 
       example_context_1, example_context_2, difficulty_level)
      VALUES ('HISTORY', 'CHRONOLOGY', ?, NULL, ?, ?, ?, 2)`).run(
      item.expression, item.meaning, item.example1, item.example2
    );
  });

  console.log('✅ Learning assets seeded (4 subjects)');
}

// Export functions
module.exports = {
  initDatabase,
  initializeSchema,
  calculateSM2,
  seedLearningAssets,
  db: null // Will be set after initialization
};
