const db = require('../database');

/**
 * LearningCard model class
 */
class LearningCardModel {
    /**
     * Create a new learning card
     */
    static async create(question, options) {
        const id = `card_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        db.run(
            'INSERT INTO learning_cards (id, question, options) VALUES (?, ?, ?)',
            [id, question, JSON.stringify(options)],
            function(err) {
                if (err) throw err;
                
                return { id, created_at: new Date().toISOString() };
            }
        );
    }
    
    /**
     * Get all cards for a user
     */
    static async getAll(limit = 3) {
        return new Promise((resolve, reject) => {
            db.all('SELECT * FROM learning_cards ORDER BY created_at DESC LIMIT ?', [limit], (err, rows) => {
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
    static async getById(id) {
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
    static async markReviewed(cardId) {
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
}

module.exports = LearningCardModel;
