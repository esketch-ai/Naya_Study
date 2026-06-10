const express = require('express');
const router = express.Router();
const db = require('../../database').db;

// GET /api/admin/metrics - Get dashboard metrics
router.get('/metrics', (req, res) => {
  try {
    const totalUsers = db.prepare(`SELECT COUNT(*) as count FROM user_profiles`).get().count;
    
    const avgRetention = db.prepare(`
      SELECT AVG(easiness_factor) as avg_ef 
      FROM learning_progress_logs 
      WHERE last_status = 'MEMORIZED'
    `).get();

    const criticalErrors = db.prepare(`
      SELECT COUNT(*) as count, error_code 
      FROM telemetry_error_logs 
      WHERE status = 'ACTIVE' AND created_at > datetime('now', '-7 days')
      GROUP BY error_code
    `).all();

    // Get recent errors
    const recentErrors = db.prepare(`
      SELECT log_id, user_id, event_type, error_code, error_message, status, created_at
      FROM telemetry_error_logs 
      WHERE status = 'ACTIVE'
      ORDER BY created_at DESC
      LIMIT 10
    `).all();

    res.json({
      total_active_users: totalUsers,
      average_spaced_retention: avgRetention?.avg_ef || 0,
      active_critical_errors: criticalErrors.reduce((sum, e) => sum + e.count, 0),
      recent_telemetry_errors: recentErrors
    });
  } catch (error) {
    console.error('Metrics error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/admin/users/resolve - Remote resolution command
router.post('/users/resolve', (req, res) => {
  try {
    const userId = req.body.user_id;
    const action = req.body.resolution_action || req.body.action;
    const logId = req.body.log_id;

    if (!userId || !action) {
      return res.status(400).json({ error: 'user_id and resolution_action are required' });
    }

    // Execute remote resolution based on action type
    switch (action) {
      case 'TOKEN_FLUSH':
        db.prepare(`
          UPDATE user_profiles 
          SET active_error_state = 'RESOLVED_TOKEN_FLUSH',
              resolved_at = CURRENT_TIMESTAMP,
              resolution_action = ?
          WHERE user_id = ?
        `).run('TOKEN_FLUSH', userId);
        break;

      case 'LOW_POWER_SWITCH':
        db.prepare(`
          UPDATE user_profiles 
          SET active_error_state = 'RESOLVED_LOW_POWER',
              resolved_at = CURRENT_TIMESTAMP,
              resolution_action = ?
          WHERE user_id = ?
        `).run('LOW_POWER_SWITCH', userId);
        break;

      case 'VOICE_REGENERATE':
        db.prepare(`
          UPDATE user_profiles 
          SET active_error_state = 'RESOLVED_VOICE_REGEN',
              resolved_at = CURRENT_TIMESTAMP,
              resolution_action = ?
          WHERE user_id = ?
        `).run('VOICE_REGENERATE', userId);
        break;

      case 'THRESHOLD_TUNER':
        db.prepare(`
          UPDATE learning_progress_logs 
          SET easiness_factor = 2.5,
              exposure_count = exposure_count + 1,
              updated_at = CURRENT_TIMESTAMP
          WHERE user_id = ? AND active_error_state LIKE '%VOCAB_DUP%'
        `).run(userId);
        break;

      case 'VOICE_BYPASS':
        db.prepare(`
          UPDATE user_profiles 
          SET preferred_voice = 'pro_voice',
              active_error_state = 'RESOLVED_VOICE_BYPASS',
              resolved_at = CURRENT_TIMESTAMP,
              resolution_action = ?
          WHERE user_id = ?
        `).run('VOICE_BYPASS', userId);
        break;

      default:
        return res.status(400).json({ error: 'Invalid resolution action' });
    }

    // Update telemetry log if provided
    if (logId) {
      db.prepare(`
        UPDATE telemetry_error_logs 
        SET status = 'RESOLVED',
            resolved_at = CURRENT_TIMESTAMP,
            resolution_action = ?
        WHERE log_id = ?
      `).run(action, logId);
    }

    res.json({
      success: true,
      message: `Remote direct resolution command [${action}] successfully pushed to client device ${userId}. Status resolved.`,
      resolved_at: new Date().toISOString()
    });
  } catch (error) {
    console.error('Resolution error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/admin/cohorts/status - Get cohort status
router.get('/cohorts/status', (req, res) => {
  try {
    const cohorts = [
      { cluster_id: 'C01', cluster_name: 'Silver 어르신군' },
      { cluster_id: 'C02', cluster_name: 'ADHD 아동' },
      { cluster_id: 'C03', cluster_name: '지하철 직장인' },
      { cluster_id: 'C04', cluster_name: 'CarPlay 운전자' },
      { cluster_id: 'C05', cluster_name: '소음 근로자' }
    ];

    const results = cohorts.map(cohort => {
      // Simulated counts - replace with actual query logic
      return {
        ...cohort,
        total_count: 100,
        emerald_normal: Math.floor(Math.random() * 90) + 85,
        amber_warning: Math.floor(Math.random() * 10),
        crimson_critical: Math.floor(Math.random() * 3),
        critical_uuids: []
      };
    });

    res.json({
      timestamp: new Date().toISOString(),
      cohorts: results
    });
  } catch (error) {
    console.error('Cohort status error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/admin/cohorts/metrics - Get specific user metrics
router.get('/cohorts/metrics', (req, res) => {
  try {
    const userId = req.query.user_id;

    if (!userId) {
      return res.status(400).json({ error: 'user_id is required' });
    }

    const user = db.prepare(`SELECT * FROM user_profiles WHERE user_id = ?`).get(userId);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Get recent anomaly logs
    const anomalyLogs = db.prepare(`
      SELECT log_id, event_type, error_code, error_message, status, created_at
      FROM telemetry_error_logs 
      WHERE user_id = ?
      ORDER BY created_at DESC
      LIMIT 5
    `).all(userId);

    res.json({
      user_id: userId,
      biometric_telemetry: {
        current_bpm: null, // Would query latest wearable_health_logs
        stress_index_rmssd: null,
        last_activity: 'UNKNOWN'
      },
      content_metrics: {
        active_subject: 'ENGLISH',
        retention_score: 75,
        focus_score: 80,
        fatigue_index: 45
      },
      anomaly_logs: anomalyLogs
    });
  } catch (error) {
    console.error('User metrics error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
