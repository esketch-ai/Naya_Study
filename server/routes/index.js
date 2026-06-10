const express = require('express');
const router = express.Router();

// Import route handlers
const profileRoutes = require('./profile');
const zombieCardsRoutes = require('./zombie-cards');
const quizSubmitRoutes = require('./quiz-submit');
const telemetryLogRoutes = require('./telemetry-log');
const statsRoutes = require('./stats');

// Mount routes with API version prefix
router.use('/api/v1/profile', profileRoutes);
router.use('/api/v1/learning/zombie-card', zombieCardsRoutes);
router.use('/api/v1/learning/quiz/submit', quizSubmitRoutes);
router.use('/api/wearable/log', telemetryLogRoutes);
router.use('/api/v1/stats', statsRoutes);

module.exports = router;
