const db = require('./database');

/**
 * Stats model class for analytics dashboard
 */
class StatsModel {
    /**
     * Get overall statistics
     */
    static async getOverallStats() {
        return new Promise((resolve, reject) => {
            const queries = [
                'SELECT COUNT(*) as total_users FROM users',
                'SELECT COUNT(DISTINCT id) as active_devices FROM learning_cards WHERE reviewed_at IS NOT NULL',
                'SELECT COUNT(*) as today_quizzes FROM learning_cards WHERE DATE(created_at) = DATE(\'now\')',
            ];
            
            let results = [];
            
            queries.forEach((query, index) => {
                db.get(query, [], (err, row) => {
                    if (err) return reject(err);
                    
                    results[index] = row;
                    
                    // When all queries are done
                    if (results.every(r => r !== undefined)) {
                        resolve(results);
                    }
                });
            });
        });
    }
    
    /**
     * Get weekly performance stats
     */
    static async getWeeklyStats() {
        return new Promise((resolve, reject) => {
            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            
            let results = {};
            
            days.forEach(day => {
                db.get(
                    `SELECT COUNT(*) as quizzes FROM learning_cards 
                     WHERE strftime('%w', created_at) = ?`,
                    [day],
                    (err, row) => {
                        if (err) return reject(err);
                        
                        results[day] = row.quizzes || 0;
                    }
                );
            });
            
            // Wait for all queries to complete
            setTimeout(() => resolve(results), 100);
        });
    }
    
    /**
     * Get retention rate stats
     */
    static async getRetentionStats() {
        return new Promise((resolve, reject) => {
            db.get(
                'SELECT COUNT(*) as total_users FROM users',
                [],
                (err, row1) => {
                    if (err) return reject(err);
                    
                    db.get(
                        'SELECT COUNT(*) as active_users FROM users WHERE last_active > datetime(\'now\', \'-7 days\')',
                        [],
                        (err, row2) => {
                            if (err) return reject(err);
                            
                            const total = row1.total_users || 1;
                            const active = row2.active_users || 0;
                            
                            resolve({
                                retention_rate: Math.round((active / total) * 100),
                                total_users: total,
                                active_users: active,
                            });
                        }
                    );
                }
            );
        });
    }
}

module.exports = StatsModel;
