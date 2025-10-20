// Express server wrapper for Digital Ocean Droplet deployment
// This wraps the Vercel serverless functions into a traditional Express server

import express from 'express';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS headers (adjust origin as needed)
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  next();
});

// Serve static files
app.use(express.static(__dirname, {
  extensions: ['html']
}));

// Import API handlers
import submitHandler from './api/submit.js';
import countHandler from './api/count.js';
import commentsHandler from './api/comments.js';

// API Routes - wrap serverless functions for Express
app.all('/api/submit', async (req, res) => {
  try {
    await submitHandler(req, res);
  } catch (error) {
    console.error('Error in submit handler:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.all('/api/count', async (req, res) => {
  try {
    await countHandler(req, res);
  } catch (error) {
    console.error('Error in count handler:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.all('/api/comments', async (req, res) => {
  try {
    await commentsHandler(req, res);
  } catch (error) {
    console.error('Error in comments handler:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Serve index.html for root and unknown routes
app.get('/', (req, res) => {
  res.sendFile(join(__dirname, 'index.html'));
});

app.get('*', (req, res) => {
  // Serve index.html for any other routes (SPA behavior)
  if (!req.path.startsWith('/api/')) {
    res.sendFile(join(__dirname, 'index.html'));
  } else {
    res.status(404).json({ error: 'API endpoint not found' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║  Street Justice Petition Server       ║
║  ────────────────────────────────────  ║
║  🚀 Server running on port ${PORT.toString().padEnd(4)}       ║
║  🌐 http://localhost:${PORT}            ║
║  📊 Health: http://localhost:${PORT}/health  ║
╚════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully...');
  process.exit(0);
});
