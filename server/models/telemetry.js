const db = require('../database');

/**
 * Telemetry model class
 */
class TelemetryModel {
    /**
     * Insert telemetry data
     */
    static async insert(heartRate, hrvRmssd, deviceActivityState) {
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
     * Get recent telemetry data for a user
     */
    static async getRecent(userId, limit = 100) {
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
     * Get average heart rate over last hour
     */
    static async getAverageHeartRate(userId, hours = 1) {
        return new Promise((resolve, reject) => {
            const timeAgo = new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();
            
            db.get(
                `SELECT AVG(heart_rate) as avg_hr FROM telemetry 
                 WHERE userId = ? AND created_at > ?`,
                [userId, timeAgo],
                (err, row) => {
                    if (err) return reject(err);
                    
                    resolve(row.avg_hr || null);
                }
            );
        });
    }
    
    /**
     * Get average HRV RMSSD over last hour
     */
    static async getAverageHRV(userId, hours = 1) {
        return new Promise((resolve, reject) => {
            const timeAgo = new Date(Date.now() - hours * 60 * 60 * 1000).toISOString();
            
            db.get(
                `SELECT AVG(hrv_rmssd) as avg_hrv FROM telemetry 
                 WHERE userId = ? AND created_at > ?`,
                [userId, timeAgo],
                (err, row) => {
                    if (err) return reject(err);
                    
                    resolve(row.avg_hrv || null);
                }
            );
        });
    }
}

module.exports = TelemetryModel;
