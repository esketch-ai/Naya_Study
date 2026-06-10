const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// GET /api/v1/learning/zombie-card
router.get('/', authenticateToken, (req, res) => {
    const db = require('../database');
    
    // Fetch 3 most recent zombie cards for review
    db.all('SELECT * FROM learning_cards ORDER BY created_at DESC LIMIT 3', [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        
        // Format options as comma-separated string
        const formattedCards = rows.map(card => ({
            ...card,
            options: card.options.split(',').map(opt => opt.trim()),
        }));
        
        res.json(formattedCards);
    });
});

module.exports = router;
