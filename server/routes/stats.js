const express = require('express');
const router = express.Router();
const { authenticateToken } = require('./middleware/auth');
const StatsModel = require('../models/stats');

// GET /api/v1/stats
router.get('/', authenticateToken, async (req, res) => {
    try {
        const [overallStats, weeklyStats, retentionStats] = await Promise.all([
            StatsModel.getOverallStats(),
            StatsModel.getWeeklyStats(),
            StatsModel.getRetentionStats(),
        ]);
        
        // Combine results into single response object
        res.json({
            total_users: overallStats[0].total_users || 0,
            active_devices: overallStats[1].active_devices || 0,
            today_quizzes: overallStats[2].today_quizzes || 0,
            weekly_performance: weeklyStats,
            retention_rate: retentionStats.retention_rate || 0,
        });
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json({ error: 'Failed to fetch statistics' });
    }
});

module.exports = router;
