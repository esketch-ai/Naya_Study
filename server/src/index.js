const express = require('express');
const cors = require('cors');
const path = require('path');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Import routes from unified router
const routes = require('../routes');

// Mount all routes with API version prefix
app.use(routes);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    
    // Log to file in production
    if (process.env.NODE_ENV === 'production') {
        const fs = require('fs');
        const logPath = path.join(__dirname, '../../error.log');
        
        try {
            fs.appendFileSync(logPath, `[${new Date().toISOString()}] ${err.message}\n`);
        } catch (fileErr) {
            console.error('Failed to write error log:', fileErr);
        }
    }
    
    res.status(err.status || 500).json({ 
        error: err.message,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
