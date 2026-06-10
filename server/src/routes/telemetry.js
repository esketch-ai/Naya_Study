const express = require('express');
const router = express.Router();
const db = require('../../database').db;

// POST /api/wearable/log - Receive HRV/PPG telemetry from watch
router.post('/', (req, res) => {
  try {
    const userId = req.body.user_id || req.headers['x-user-id'];
    const heartRate = req.body.heart_rate;
    const stressIndex = req.body.stress_index;
    const activityState = req.body.detected_activity;

    if (!userId) {
      return res.status(400).json({ error: 'user_id is required' });
    }

    // Insert wearable health log
    db.prepare(`
      INSERT INTO wearable_health_logs 
      (user_id, heart_rate, stress_index, detected_activity, logged_time)
      VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
    `).run(userId, heartRate || null, stressIndex || null, activityState || 'UNKNOWN');

    // Check for sleep mode detection (STILL + low HRV HF)
    if (activityState === 'STILL' && stressIndex && stressIndex < 50) {
      // Potential sleep mode - could trigger mute filter
      console.log(`⚠️ Sleep mode detected for user ${userId}: STILL, HRV=${stressIndex}`);
    }

    res.json({
      status: 'success',
      message: 'Telemetry received'
    });
  } catch (error) {
    console.error('Telemetry log error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/wearable/log - Get recent telemetry logs for a user
router.get('/', (req, res) => {
  try {
    const userId = req.query.user_id || req.headers['x-user-id'];
    const limit = parseInt(req.query.limit) || 10;

    if (!userId) {
      return res.status(400).json({ error: 'user_id is required' });
    }

    const logs = db.prepare(`
      SELECT log_id, heart_rate, stress_index, detected_activity, logged_time
      FROM wearable_health_logs 
      WHERE user_id = ?
      ORDER BY logged_time DESC
      LIMIT ?
    `).all(userId, limit);

    res.json({
      status: 'success',
      data: logs
    });
  } catch (error) {
    console.error('Telemetry log GET error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
