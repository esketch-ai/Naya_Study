const express = require('express');
const router = express.Router();
const { authenticateToken } = require('./middleware/auth');

// POST /api/v1/learning/quiz/submit
router.post('/', authenticateToken, (req, res) => {
    const db = require('../database');
    
    const { cardId, answerIndex } = req.body;
    
    // Validate inputs
    if (!cardId || answerIndex === undefined) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Get card and user data
    db.get('SELECT * FROM learning_cards WHERE id = ?', [cardId], (err, card) => {
        if (err) return res.status(500).json({ error: err.message });
        
        if (!card) {
            return res.status(404).json({ error: 'Card not found' });
        }
        
        db.get('SELECT * FROM users WHERE id = ?', [req.user.id], (err, user) => {
            if (err) return res.status(500).json({ error: err.message });
            
            // SM-2 algorithm implementation
            let reps = 0;
            let intervalDays = 1;
            let ef = user.ef || 1.3;
            
            const options = card.options.split(',').map(opt => opt.trim());
            const isCorrect = answerIndex === parseInt(options[answerIndex]);
            
            if (isCorrect) {
                // Correct answer - quality = 3
                const quality = 3;
                
                if (reps === 0) {
                    intervalDays = 1;
                } else if (reps === 1) {
                    intervalDays = 6;
                } else {
                    intervalDays = Math.round(intervalDays * ef);
                }
                
                reps += 1;
            } else {
                // Incorrect answer - reset
                reps = 0;
                intervalDays = 1;
            }
            
            // EF update formula: EF = EF + (0.1 - (5 - quality) * (0.8 + (5 - quality) * 0.2))
            const newEf = ef + (0.1 - (5 - quality) * (0.8 + (5 - quality) * 0.2));
            
            // EF floor: minimum 1.3
            if (newEf < 1.3) {
                newEf = 1.3;
            }
            
            // Update user data
            db.run(
                'UPDATE users SET reps = ?, interval_days = ?, ef = ? WHERE id = ?',
                [reps, intervalDays, newEf, req.user.id],
                function(err) {
                    if (err) return res.status(500).json({ error: err.message });
                    
                    // Update card status with review timestamp
                    db.run(
                        'UPDATE learning_cards SET reviewed_at = CURRENT_TIMESTAMP WHERE id = ?',
                        [cardId]
                    );
                    
                    res.json({
                        success: true,
                        message: isCorrect ? 'Correct!' : 'Try again',
                        reps,
                        intervalDays,
                        ef: newEf,
                        quality: isCorrect ? 3 : 1,
                    });
                }
            );
        });
    });
});

module.exports = router;
