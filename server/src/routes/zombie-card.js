const express = require('express');
const router = express.Router();
const db = require('../../database').db;

// GET /api/v1/learning/zombie-card - Get daily zombie cards for review
router.get('/', (req, res) => {
  try {
    const userId = req.query.user_id || req.headers['x-user-id'];
    
    if (!userId) {
      return res.status(400).json({ error: 'user_id is required' });
    }

    // Get cards due for review today (next_review_date <= today)
    const today = new Date().toISOString().split('T')[0];
    
    const cards = db.prepare(`
      SELECT la.asset_id, la.subject_code, la.category, la.key_expression,
             la.pronunciation_or_tip, la.translation_meaning, 
             la.example_context_1, la.example_context_2,
             pl.exposure_count, pl.correct_count, pl.incorrect_count,
             pl.repetition_interval, pl.easiness_factor, pl.next_review_date,
             pl.last_status
      FROM learning_assets la
      JOIN learning_progress_logs pl ON la.asset_id = pl.asset_id
      WHERE pl.user_id = ? 
        AND pl.next_review_date <= ?
      ORDER BY pl.next_review_date ASC
      LIMIT 3
    `).all(userId, today);

    res.json({
      status: 'success',
      data: cards.length > 0 ? cards : null
    });
  } catch (error) {
    console.error('Zombie card GET error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
