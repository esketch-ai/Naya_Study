const express = require('express');
const router = express.Router();
const db = require('../../database').db;

// POST /api/v1/learning/quiz/submit - Submit quiz answer and update SM-2 intervals
router.post('/', (req, res) => {
  try {
    const userId = req.body.user_id || req.headers['x-user-id'];
    const assetId = req.body.asset_id;
    const quality = req.body.score_quality;

    if (!userId || !assetId || quality === undefined) {
      return res.status(400).json({ 
        error: 'user_id, asset_id, and score_quality are required' 
      });
    }

    // Validate quality range (0-5)
    if (quality < 0 || quality > 5) {
      return res.status(400).json({ error: 'score_quality must be between 0 and 5' });
    }

    // Calculate SM-2 algorithm
    const currentProgress = db.prepare(`
      SELECT exposure_count, correct_count, incorrect_count, 
             repetition_interval, easiness_factor
      FROM learning_progress_logs 
      WHERE user_id = ? AND asset_id = ?
    `).get(userId, assetId);

    let nextReviewDate;
    let newInterval;
    let newEF;

    if (currentProgress) {
      // Apply SM-2 algorithm
      const result = db.calculateSM2(quality, currentProgress.correct_count + 1, 
                                      currentProgress.easiness_factor);
      
      newReps = result.reps;
      newInterval = result.intervalDays;
      newEF = result.ef;

      // Calculate next review date
      const today = new Date();
      const nextDate = new Date(today.getTime() + (newInterval * 24 * 60 * 60 * 1000));
      nextReviewDate = nextDate.toISOString().split('T')[0];

      // Update progress log
      db.prepare(`
        UPDATE learning_progress_logs 
        SET exposure_count = exposure_count + 1,
            correct_count = CASE WHEN ? >= 3 THEN correct_count + 1 ELSE correct_count END,
            incorrect_count = CASE WHEN ? < 3 THEN incorrect_count + 1 ELSE incorrect_count END,
            repetition_interval = ?,
            easiness_factor = ?,
            next_review_date = ?,
            last_status = CASE WHEN ? >= 3 THEN 'MEMORIZED' ELSE 'RETRY' END,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = ? AND asset_id = ?
      `).run(
        quality, 
        quality,
        newInterval,
        newEF,
        nextReviewDate,
        quality,
        userId,
        assetId
      );

    } else {
      // First exposure - initialize with default values
      const today = new Date();
      nextReviewDate = today.toISOString().split('T')[0];
      
      db.prepare(`
        INSERT INTO learning_progress_logs 
        (user_id, asset_id, exposure_count, correct_count, incorrect_count,
         repetition_interval, easiness_factor, next_review_date, last_status)
        VALUES (?, ?, 1, CASE WHEN ? >= 3 THEN 1 ELSE 0 END,
                CASE WHEN ? < 3 THEN 1 ELSE 0 END,
                CASE WHEN ? >= 3 THEN 6 ELSE 1 END,
                CASE WHEN ? >= 3 THEN 2.5 ELSE 2.5 END,
                ?, 'RETRY')
      `).run(
        userId, assetId, quality, quality,
        quality, quality,
        nextReviewDate
      );
    }

    res.json({
      status: 'success',
      data: {
        next_review_date: nextReviewDate || currentProgress?.next_review_date,
        repetition_interval: newInterval || currentProgress?.repetition_interval,
        easiness_factor: newEF || currentProgress?.easiness_factor
      }
    });
  } catch (error) {
    console.error('Quiz submit error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
