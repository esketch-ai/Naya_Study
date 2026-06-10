const express = require('express');
const router = express.Router();
const { authenticateToken } = require('./middleware/auth');

// GET /api/v1/profile
router.get('/', authenticateToken, (req, res) => {
    const db = require('../database');
    
    db.get('SELECT * FROM users WHERE id = ?', [req.user.id], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        
        // Format response with readable timestamps
        const formattedProfile = {
            ...row,
            wakeup_time: row.wakeup_time ? new Date(row.wakeup_time).toLocaleTimeString() : null,
            sleep_time: row.sleep_time ? new Date(row.sleep_time).toLocaleTimeString() : null,
        };
        
        res.json(formattedProfile);
    });
});

// PUT /api/v1/profile
router.put('/', authenticateToken, (req, res) => {
    const db = require('../database');
    
    const { voice_preference, stress_threshold, wakeup_time, sleep_time } = req.body;
    
    // Validate inputs
    if (!['eleven_labs', 'child_actor'].includes(voice_preference)) {
        return res.status(400).json({ error: 'Invalid voice preference' });
    }
    
    if (stress_threshold < 1 || stress_threshold > 100) {
        return res.status(400).json({ error: 'Stress threshold must be between 1 and 100' });
    }
    
    db.run(
        'UPDATE users SET voice_preference = ?, stress_threshold = ?, wakeup_time = ?, sleep_time = ? WHERE id = ?',
        [voice_preference, stress_threshold, wakeup_time, sleep_time, req.user.id],
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            
            // Get updated profile
            db.get('SELECT * FROM users WHERE id = ?', [req.user.id], (err, row) => {
                if (err) return res.status(500).json({ error: err.message });
                
                const formattedProfile = {
                    ...row,
                    wakeup_time: row.wakeup_time ? new Date(row.wakeup_time).toLocaleTimeString() : null,
                    sleep_time: row.sleep_time ? new Date(row.sleep_time).toLocaleTimeString() : null,
                };
                
                res.json({ 
                    message: 'Profile updated successfully',
                    profile: formattedProfile 
                });
            });
        }
    );
});

module.exports = router;
