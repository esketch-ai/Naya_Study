const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// POST /api/wearable/log
router.post('/', authenticateToken, (req, res) => {
    const db = require('../database');
    
    const { type, value } = req.body;
    
    // Validate inputs
    if (!type || value === undefined) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Map telemetry types to database columns
    let column;
    switch (type) {
        case 'heart_rate':
            column = 'heart_rate';
            break;
        case 'hrv':
            column = 'hrv_rmssd';
            break;
        case 'activity':
            column = 'device_activity_state';
            break;
        default:
            return res.status(400).json({ error: 'Invalid telemetry type' });
    }
    
    // Insert telemetry data
    db.run(
        `INSERT INTO telemetry (${column}, created_at) VALUES (?, CURRENT_TIMESTAMP)`,
        [value],
        function(err) {
            if (err) return res.status(500).json({ error: err.message });
            
            // Get the inserted row for confirmation
            db.get(`SELECT ${column} as value, type FROM telemetry ORDER BY created_at DESC LIMIT 1`, [], (err, row) => {
                if (err) return res.status(500).json({ error: err.message });
                
                res.json({ 
                    message: 'Telemetry logged successfully',
                    data: { type, value: row.value }
                });
            });
        }
    );
});

module.exports = router;
