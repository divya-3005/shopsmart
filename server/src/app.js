const express = require('express');
const cors = require('cors');

const app = express();

const path = require('path');

// Middleware
app.use(cors());
app.use(express.json());

// Health Check Route
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'ShopSmart Backend is running',
    timestamp: new Date().toISOString()
  });
});

// Serve frontend static files
app.use(express.static(path.join(__dirname, '../../client/dist')));


// Fallback for SPA routing: send index.html for any unknown routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../../client/dist/index.html'));
});

module.exports = app;
