const jwt = require('jsonwebtoken');

// JWT secret key - should be loaded from environment variable in production
const JWT_SECRET = process.env.JWT_SECRET || 'YOUR_SECRET_KEY_CHANGE_IN_PRODUCTION';

/**
 * Middleware to authenticate JWT tokens
 */
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    
    // Check if Authorization header exists and starts with Bearer
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Access denied. No token provided.' });
    }
    
    const token = authHeader.split(' ')[1]; // Extract token after "Bearer "
    
    try {
        // Verify token and decode payload
        const decoded = jwt.verify(token, JWT_SECRET);
        
        // Attach user info to request object
        req.user = decoded;
        
        next(); // Proceed to route handler
    } catch (err) {
        if (err.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Token expired' });
        } else if (err.name === 'JsonWebTokenError') {
            return res.status(403).json({ error: 'Invalid token' });
        } else {
            console.error('Auth error:', err);
            return res.status(500).json({ error: 'Server error during authentication' });
        }
    }
}

/**
 * Middleware to extract user ID from request for telemetry logging
 */
function extractUserId(req, res, next) {
    if (req.user && req.user.id) {
        req.userId = req.user.id;
    } else {
        // Fallback: try to get from Authorization header without Bearer prefix
        const authHeader = req.headers['authorization'];
        if (authHeader) {
            const token = authHeader.split(' ')[1];
            try {
                const decoded = jwt.decode(token, { complete: true });
                if (decoded && decoded.payload?.id) {
                    req.userId = decoded.payload.id;
                }
            } catch (err) {
                console.error('Failed to extract user ID:', err);
            }
        }
    }
    
    next();
}

module.exports = {
    authenticateToken,
    extractUserId,
};
