// selfhost-main.js
import express from 'express';
import path from 'path';
import morgan from 'morgan';

const app = express();
const PORT = process.env.PORT || 80;

// Middleware: logging
app.use(morgan('combined'));

// Middleware: serve static files from 'public' directory
app.use(express.static(path.resolve(process.cwd(), 'public')));

// Example API route
app.get('/api/status', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Fallback route: serve index.html for SPA support
app.get('*', (req, res) => {
  res.sendFile(path.resolve(process.cwd(), 'public', 'index.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal Server Error' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Self-hosted server running at http://localhost:${8080}`);
});
