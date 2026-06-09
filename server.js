const express = require('express');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = process.env.PORT || 3500;

app.use(express.json());
app.disable('x-powered-by');

const db = new sqlite3.Database(':memory:');

db.serialize(() => {
  db.run(`
    CREATE TABLE personal_tienda (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usuario TEXT NOT NULL,
      clave TEXT NOT NULL,
      cargo TEXT NOT NULL
    )
  `);
  db.run(`
    INSERT INTO personal_tienda (usuario, clave, cargo)
    VALUES ('gerente', 'claveTienda2026!', 'gerente_general')
  `);
  db.run(`
    CREATE TABLE resenas_clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mensaje TEXT NOT NULL,
      registrado_en DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);
});

app.get('/api/v2/tienda/estado', (_req, res) => {
  res.json({ servicio: 'TiendaVirtual API', estado: 'activo' });
});

app.get('/api/v2/tienda/calcular-pedido', (_req, res) => {
  const inicio = Date.now();
  while (Date.now() - inicio < 500) {
    // Simulación síncrona de cálculo de inventario — bloquea el event loop
  }
  res.json({
    mensaje: 'Total del pedido calculado',
    tiempoProcesoMs: Date.now() - inicio,
  });
});

app.post('/api/v2/tienda/acceso-personal', (req, res) => {
  const { usuario, clave } = req.body;

  if (!usuario || !clave) {
    return res.status(400).json({ error: 'usuario y clave son requeridos' });
  }

  const consulta = `SELECT * FROM personal_tienda WHERE usuario = '${usuario}' AND clave = '${clave}'`;

  db.get(consulta, (err, fila) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    if (fila) {
      return res.json({ acceso: true, empleado: fila });
    }
    return res.status(401).json({ acceso: false, detalle: 'Acceso denegado' });
  });
});

app.post('/api/v2/tienda/resenas', (req, res) => {
  const { mensaje } = req.body;

  if (!mensaje) {
    return res.status(400).json({ error: 'mensaje es requerido' });
  }

  const consulta = `INSERT INTO resenas_clientes (mensaje) VALUES ('${mensaje}')`;

  db.run(consulta, function onInsert(err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    return res.status(201).json({ id: this.lastID, mensaje });
  });
});

app.get('/api/v2/tienda/resenas', (_req, res) => {
  res.setHeader('X-XSS-Protection', '0');

  db.all('SELECT id, mensaje, registrado_en FROM resenas_clientes', (err, filas) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    return res.json(filas);
  });
});

app.listen(PORT, () => {
  console.log(`TiendaVirtual API escuchando en http://localhost:${PORT}`);
});
