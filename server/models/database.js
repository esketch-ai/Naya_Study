const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Database connection
const dbPath = path.join(__dirname, '../../naya.db');
const db = new sqlite3.Database(dbPath);

/**
 * Initialize database schema
 */
function initDatabase() {
    console.log('Initializing database...');
    
    // Users table
    db.run(`CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        voice_preference TEXT DEFAULT 'eleven_labs',
        stress_threshold INTEGER DEFAULT 75,
        wakeup_time TEXT,
        sleep_time TEXT,
        reps INTEGER DEFAULT 0,
        interval_days INTEGER DEFAULT 1,
        ef REAL DEFAULT 1.3,
        last_active DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
    
    // Learning cards table
    db.run(`CREATE TABLE IF NOT EXISTS learning_cards (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        reviewed_at DATETIME
    )`);
    
    // Telemetry data table
    db.run(`CREATE TABLE IF NOT EXISTS telemetry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        heart_rate REAL,
        hrv_rmssd REAL,
        device_activity_state INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
    
    console.log('Database initialized successfully');
}

/**
 * Insert a new learning card
 */
function insertCard(question, options) {
    return new Promise((resolve, reject) => {
        const id = `card_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        db.run(
            'INSERT INTO learning_cards (id, question, options) VALUES (?, ?, ?)',
            [id, question, JSON.stringify(options)],
            function(err) {
                if (err) return reject(err);
                
                resolve({ id, created_at: new Date().toISOString() });
            }
        );
    });
}

/**
 * Get all cards for a user
 */
function getAllCards() {
    return new Promise((resolve, reject) => {
        db.all('SELECT * FROM learning_cards ORDER BY created_at DESC', [], (err, rows) => {
            if (err) return reject(err);
            
            const formattedRows = rows.map(row => ({
                ...row,
                options: JSON.parse(row.options),
            }));
            
            resolve(formattedRows);
        });
    });
}

/**
 * Get a single card by ID
 */
function getCardById(id) {
    return new Promise((resolve, reject) => {
        db.get('SELECT * FROM learning_cards WHERE id = ?', [id], (err, row) => {
            if (err) return reject(err);
            
            if (!row) return resolve(null);
            
            resolve({
                ...row,
                options: JSON.parse(row.options),
            });
        });
    });
}

/**
 * Mark a card as reviewed
 */
function markCardReviewed(cardId) {
    return new Promise((resolve, reject) => {
        db.run(
            'UPDATE learning_cards SET reviewed_at = CURRENT_TIMESTAMP WHERE id = ?',
            [cardId],
            function(err) {
                if (err) return reject(err);
                
                resolve({ changed: this.changes > 0 });
            }
        );
    });
}

/**
 * Insert telemetry data
 */
function insertTelemetry(heartRate, hrvRmssd, deviceActivityState) {
    return new Promise((resolve, reject) => {
        db.run(
            `INSERT INTO telemetry (heart_rate, hrv_rmssd, device_activity_state) VALUES (?, ?, ?)`,
            [heartRate, hrvRmssd, deviceActivityState],
            function(err) {
                if (err) return reject(err);
                
                resolve({ 
                    id: this.lastID,
                    created_at: new Date().toISOString()
                });
            }
        );
    });
}

/**
 * Get telemetry data for a user
 */
function getTelemetry(userId, limit = 100) {
    return new Promise((resolve, reject) => {
        db.all(
            `SELECT heart_rate, hrv_rmssd, device_activity_state, created_at 
             FROM telemetry 
             WHERE userId = ? 
             ORDER BY created_at DESC 
             LIMIT ?`,
            [userId, limit],
            (err, rows) => {
                if (err) return reject(err);
                
                resolve(rows || []);
            }
        );
    });
}

/**
 * Close database connection
 */
function closeDatabase() {
    return new Promise((resolve, reject) => {
        db.close((err) => {
            if (err) return reject(err);
            
            console.log('Database connection closed');
            resolve();
        });
    });
}

module.exports = {
    initDatabase,
    insertCard,
    getAllCards,
    getCardById,
    markCardReviewed,
    insertTelemetry,
    getTelemetry,
    closeDatabase,
};
