# Guía Práctica N° 11 — Semana 11

## Informe del Taller

### Ejecución de Pruebas No Funcionales en una API REST aplicando JMeter y OWASP Top 10

**Integrantes:**
- Cano De La Cruz, Joseph Jesús
- Chávez De La Cruz, César Gonzalo
- Huayta Fernández, Luis Rodolfo
- Rebatta Torres, Jimmy Michael

**Fecha:** Junio 2026

---

## Datos del proyecto

| Campo | Detalle |
|-------|---------|
| **Proyecto** | API REST vulnerable (Node.js + Express + SQLite) |
| **Entorno de pruebas** | `http://localhost:3000` (base de datos SQLite en memoria) |
| **Herramientas utilizadas** | Apache JMeter 5.6.3 (rendimiento), cURL (seguridad OWASP) |
| **Repositorio** | https://github.com/luizhuayta/apiREST |

---

## 1. Resumen Ejecutivo

Se desplegó la API local, se ejecutaron pruebas de **carga**, **estrés** y **seguridad** (SQLi y XSS). Los resultados confirman dos hallazgos principales:

1. **Rendimiento:** Con un solo usuario, la latencia del endpoint `GET /api/v1/heavy-process` se mantiene en ~500 ms. Al escalar a 50 usuarios concurrentes, la latencia media sube a **6,1 s** y el percentil 95 alcanza **17,6 s**, superando el umbral aceptable de 2 s.
2. **Seguridad:** Se explotaron con éxito vulnerabilidades de **inyección SQL** en el login y de **XSS almacenado** en comentarios, confirmando la ausencia de consultas parametrizadas y sanitización de entradas.

---

## 2. Objetivo del taller

Aplicar pruebas no funcionales sobre una API REST vulnerable para:

- Configurar escenarios de **carga** y **estrés** e interpretar métricas de rendimiento (latencia vs. usuarios concurrentes).
- Identificar al menos **dos vulnerabilidades** del OWASP Top 10 en un entorno local autorizado.
- Documentar hallazgos y proponer soluciones técnicas viables para cuellos de botella de rendimiento y fallas de seguridad.

---

## 3. Fase 1 — Despliegue del Entorno

| Paso | Acción | Estado |
|------|--------|--------|
| 1 | `npm init -y` | Completado |
| 2 | `npm install express sqlite3` | Completado |
| 3 | Código fuente en `server.js` | Completado |
| 4 | Servidor en `http://localhost:3000` | Completado |

### Endpoints evaluados

| Método | Ruta | Propósito |
|--------|------|-----------|
| GET | `/api/v1/heavy-process` | Prueba de rendimiento (bucle síncrono ~500 ms) |
| POST | `/api/v1/login` | Prueba de inyección SQL |
| POST | `/api/v1/comments` | Inyección de payload XSS |
| GET | `/api/v1/comments` | Verificación de reflejo sin sanitizar |

---

## 4. Fase 2 — Pruebas de Rendimiento

### 4.1 Línea base (usuario único)

Antes de la prueba de carga, se midió la latencia con peticiones individuales:

| Petición | Latencia |
|----------|----------|
| 1 | 501 ms |
| 2 | 501 ms |
| 3 | 501 ms |
| 4 | 501 ms |
| 5 | 501 ms |

**Conclusión:** Con concurrencia mínima, el tiempo de respuesta se mantiene en el rango esperado de **400–600 ms**.

### 4.2 Escenario 1: Prueba de Carga

**Herramienta:** Apache JMeter (`tests/jmeter/load-test.jmx`)

| Parámetro | Valor |
|-----------|-------|
| Usuarios concurrentes (VUs) | 50 |
| Ramp-up | 10 s |
| Duración en carga plena | 30 s |
| Endpoint | `GET /api/v1/heavy-process` |

**Métricas obtenidas:**

| Métrica | Valor |
|---------|-------|
| Total de peticiones | 98 |
| Tasa de error HTTP | **0 %** |
| Latencia promedio | **6,15 s** |
| Latencia mediana (p50) | **4,91 s** |
| Percentil 90 (p90) | **9,19 s** |
| Percentil 95 (p95) | **17,59 s** |
| Latencia mínima | 502 ms |
| Latencia máxima | 43,0 s |
| Peticiones en rango ideal (400–600 ms) | 1 de 98 (**1 %**) |
| Peticiones bajo umbral de 2 s | 11 de 98 (**11 %**) |

**Interpretación — Latencia vs. Usuarios:**

| Usuarios concurrentes | Latencia típica | Evaluación |
|----------------------|-----------------|------------|
| 1 | ~500 ms | Dentro de 400–600 ms |
| 50 | ~4,9–6,1 s | Supera umbral de 2 s |

Aunque no hubo errores HTTP con 50 usuarios concurrentes, la latencia deja de ser aceptable. Node.js es **single-thread**: el bucle `while` síncrono en `heavy-process` bloquea el event loop y encola las peticiones entrantes, multiplicando el tiempo de espera de cada cliente.

### 4.3 Escenario 2: Prueba de Estrés (búsqueda del breakpoint)

**Herramienta:** Apache JMeter (`tests/jmeter/stress-test.jmx`)

| Etapa | Duración | VUs objetivo |
|-------|----------|--------------|
| 1 | 15 s | 50 |
| 2 | 15 s | 100 |
| 3 | 15 s | 200 |
| 4 | 15 s | 300 |
| 5 | 15 s | 400 |

**Condición de parada:** detener la prueba cuando la tasa de error supere el 5 %.

**Resultado:**

| Métrica | Valor |
|---------|-------|
| VUs alcanzados antes del abort | **~39** |
| Tasa de error | **100 %** (timeouts a 10 s) |
| Latencia en fallos | ~10 s (timeout) |
| Peticiones completadas | 6 (todas fallidas) |

**Breakpoint identificado:** La API deja de responder de forma fiable con aproximadamente **35–40 usuarios concurrentes**, muy por debajo de los 200–300 VUs planificados. La latencia efectiva supera los **2 000 ms** y evoluciona hacia **timeouts completos** porque el hilo único no puede atender la cola de peticiones bloqueadas por el bucle síncrono.

**Causa raíz — código bloqueante:**

```javascript
while (Date.now() - start < 500) {
  // Bucle síncrono que bloquea el event loop de Node.js
}
```

Cada petición ocupa el hilo ~500 ms de forma exclusiva; con N usuarios simultáneos, el tiempo de espera en cola crece de forma aproximadamente lineal.

---

## 5. Fase 3 — Pruebas de Seguridad (OWASP Top 10)

> **Nota ética:** Todas las pruebas se ejecutaron exclusivamente contra el entorno local autorizado (`localhost:3000`). No se realizaron escaneos ni ataques contra sistemas externos.

### 5.1 Vulnerabilidad 1: Inyección SQL (SQLi)

| Campo | Valor |
|-------|-------|
| Endpoint | `POST /api/v1/login` |
| Payload (username) | `' OR '1'='1' --` |
| Payload alternativo | `' OR '1'='1` en username y password |
| Severidad | **Alta** |

**Evidencia de explotación:**

```json
{
  "success": true,
  "user": {
    "id": 1,
    "username": "admin",
    "password": "supersecret123",
    "role": "administrator"
  }
}
```

**HTTP Status:** 200

**Hallazgo:** La API devuelve los datos del usuario administrador sin validar la contraseña correcta. La consulta se construye por concatenación directa:

```javascript
const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
```

El atacante manipula la lógica SQL para que la condición siempre sea verdadera, obteniendo acceso no autorizado.

### 5.2 Vulnerabilidad 2: Cross-Site Scripting (XSS)

| Campo | Valor |
|-------|-------|
| Endpoint POST | `POST /api/v1/comments` |
| Endpoint GET | `GET /api/v1/comments` |
| Payload | `<script>alert(1)</script>` |
| Severidad | **Media–Alta** |

**Evidencia POST (201 Created):**

```json
{"id": 2, "body": "<script>alert(1)</script>"}
```

**Evidencia GET (reflejo sin sanitizar):**

```json
[
  {"id": 1, "body": "<script>alert(1)</script>", "created_at": "2026-06-09 16:54:20"},
  {"id": 2, "body": "<script>alert(1)</script>", "created_at": "2026-06-09 16:54:42"}
]
```

**Cabeceras de respuesta relevantes:**

```
X-XSS-Protection: 0
Content-Type: application/json; charset=utf-8
```

**Hallazgo:** El servidor almacena y devuelve el script inyectado sin escapar ni filtrar. Además, la cabecera `X-XSS-Protection` está **explícitamente desactivada** (`0`), eliminando una capa de defensa del navegador. En un cliente web que renderice el campo `body` como HTML, el script se ejecutaría.

---

## 6. Fase 4 — Recomendaciones Técnicas

### 6.1 Soluciones de Infraestructura (rendimiento)

| Recomendación | Descripción |
|---------------|-------------|
| **Auto-scaling (autoescalado)** | Configurar políticas de escalado horizontal automático (p. ej. Kubernetes HPA o AWS Auto Scaling) que aumenten instancias cuando la latencia p95 supere 2 s o la CPU supere el 70 %. |
| **Balanceador de carga** | Colocar un load balancer (Nginx, ALB, HAProxy) delante de múltiples réplicas de la API para distribuir las peticiones y evitar que un único proceso Node.js sature. |
| **Colas de trabajo** | Externalizar el procesamiento pesado a workers (Bull, RabbitMQ, SQS) para liberar el event loop del hilo principal. |
| **Monitoreo** | Implementar alertas sobre latencia p95, tasa de error y profundidad de cola para detectar saturación antes del breakpoint. |

### 6.2 Soluciones de Código (seguridad)

| Recomendación | Aplica a | Implementación |
|---------------|----------|----------------|
| **Consultas parametrizadas (Prepared Statements)** | SQLi | Usar placeholders: `db.get('SELECT * FROM users WHERE username = ? AND password = ?', [username, password])` |
| **Sanitización de inputs** | SQLi, XSS | Validar y escapar entradas con librerías como `validator`, `DOMPurify` o `he`. |
| **Hashing de contraseñas** | SQLi (impacto) | Almacenar contraseñas con `bcrypt`/`argon2`. |
| **Cabeceras de seguridad** | XSS | Activar `helmet` en Express: CSP, `X-XSS-Protection`, `X-Content-Type-Options`. |
| **Codificación de salida** | XSS | Escapar datos al serializar para HTML/JSON cuando el consumidor pueda renderizarlos en el DOM. |

### 6.3 Solución de código para el cuello de botella de rendimiento

Reemplazar el bucle síncrono por procesamiento asíncrono o delegado:

```javascript
const { Worker } = require('worker_threads');

app.get('/api/v1/heavy-process', (_req, res) => {
  const worker = new Worker('./heavy-worker.js');
  worker.on('message', (result) => res.json(result));
});
```

---

## 7. Conclusión

Las pruebas no funcionales demuestran que la API cumple el comportamiento esperado en condiciones normales (latencia ~500 ms con un usuario), pero **degrada de forma crítica bajo concurrencia** debido al modelo single-thread de Node.js y el código síncrono bloqueante. El breakpoint operativo se alcanza con menos de 40 usuarios concurrentes.

En seguridad, se confirmaron **dos vulnerabilidades del OWASP Top 10** (inyección SQL y XSS almacenado), ambas mitigables con consultas parametrizadas, sanitización de entradas y cabeceras de protección adecuadas.

---

## 8. Anexos y reproducción

| Archivo | Contenido |
|---------|-----------|
| `tests/jmeter/load-test.jmx` | Plan JMeter — prueba de carga (50 usuarios) |
| `tests/jmeter/stress-test.jmx` | Plan JMeter — prueba de estrés (hasta 400 usuarios) |
| `tests/security-tests.sh` | Script de pruebas SQLi y XSS |
| `results/load-test-output.txt` | Salida completa de la prueba de carga |
| `results/stress-test-output.txt` | Salida completa de la prueba de estrés |
| `results/security-sqli.txt` | Evidencia de inyección SQL |
| `results/security-xss.txt` | Evidencia de XSS |

**Comandos de reproducción:**

```bash
npm install
node server.js

# En otra terminal:
./scripts/setup-jmeter.sh
npm run test:load
npm run test:stress
npm run test:security
```
