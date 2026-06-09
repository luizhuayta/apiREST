const express = require('express');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = 3000;

app.use(express.json());
app.disable('x-powered-by');

const db = new sqlite3.Database(':memory:');

db.serialize(() => {
  db.run(`
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL
    )
  `);
  db.run(`
    INSERT INTO users (username, password, role)
    VALUES ('admin', 'supersecret123', 'administrator')
  `);
  db.run(`
    CREATE TABLE comments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      body TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);
});

app.get('/api/v1/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.get('/api/v1/heavy-process', (_req, res) => {
  const start = Date.now();
  while (Date.now() - start < 500) {
    // Bucle síncrono que bloquea el event loop de Node.js
  }
  res.json({
    message: 'Proceso pesado completado',
    latencyMs: Date.now() - start,
  });
});

app.post('/api/v1/login', (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: 'username y password son requeridos' });
  }

  const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;

  db.get(query, (err, row) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    if (row) {
      return res.json({ success: true, user: row });
    }
    return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
  });
});

app.post('/api/v1/comments', (req, res) => {
  const { body } = req.body;

  if (!body) {
    return res.status(400).json({ error: 'body es requerido' });
  }

  const query = `INSERT INTO comments (body) VALUES ('${body}')`;

  db.run(query, function onInsert(err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    return res.status(201).json({ id: this.lastID, body });
  });
});

app.get('/api/v1/comments', (_req, res) => {
  res.setHeader('X-XSS-Protection', '0');

  db.all('SELECT id, body, created_at FROM comments', (err, rows) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    return res.json(rows);
  });
});

app.listen(PORT, () => {
  console.log(`API vulnerable escuchando en http://localhost:${PORT}`);
});
