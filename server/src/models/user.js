const db = require('../database');

/**
 * User model class
 */
class UserModel {
    /**
     * Create a new user
     */
    static async create(username, password) {
        const saltRounds = 10;
        
        // Hash password
        const hash = await bcrypt.hash(password, saltRounds);
        
        const id = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        
        db.run(
            'INSERT INTO users (id, username, password_hash) VALUES (?, ?, ?)',
            [id, username, hash],
            function(err) {
                if (err) throw err;
                
                return { id, username };
            }
        );
    }
    
    /**
     * Get user by ID
     */
    static async getById(id) {
        db.get('SELECT * FROM users WHERE id = ?', [id], (err, row) => {
            if (err) throw err;
            
            return row || null;
        });
    }
    
    /**
     * Get user by username
     */
    static async getByUsername(username) {
        db.get('SELECT * FROM users WHERE username = ?', [username], (err, row) => {
            if (err) throw err;
            
            return row || null;
        });
    }
    
    /**
     * Update user profile
     */
    static async update(id, updates) {
        const fields = [];
        const values = [];
        
        for (const [key, value] of Object.entries(updates)) {
            if (value !== undefined && value !== null) {
                fields.push(`${key} = ?`);
                values.push(value);
            }
        }
        
        if (fields.length === 0) return;
        
        fields.push('WHERE id = ?');
        values.push(id);
        
        db.run(`UPDATE users SET ${fields.join(', ')}`, values, function(err) {
            if (err) throw err;
            
            console.log(`Updated user ${id}: ${this.changes} rows affected`);
        });
    }
    
    /**
     * Update user password
     */
    static async updatePassword(id, newPassword) {
        const saltRounds = 10;
        const hash = await bcrypt.hash(newPassword, saltRounds);
        
        db.run(
            'UPDATE users SET password_hash = ? WHERE id = ?',
            [hash, id],
            function(err) {
                if (err) throw err;
                
                console.log(`Updated password for user ${id}`);
            }
        );
    }
    
    /**
     * Mark user as active recently
     */
    static async markActive(id) {
        db.run(
            'UPDATE users SET last_active = CURRENT_TIMESTAMP WHERE id = ?',
            [id],
            function(err) {
                if (err) throw err;
                
                console.log(`Marked user ${id} as active`);
            }
        );
    }
    
    /**
     * Get all users with optional pagination
     */
    static async getAll(limit = 10, offset = 0) {
        return new Promise((resolve, reject) => {
            db.all(
                'SELECT id, username, voice_preference, last_active FROM users ORDER BY last_active DESC LIMIT ? OFFSET ?',
                [limit, offset],
                (err, rows) => {
                    if (err) return reject(err);
                    
                    resolve(rows || []);
                }
            );
        });
    }
}

module.exports = UserModel;
