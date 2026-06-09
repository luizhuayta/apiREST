# Guía Práctica N° 11 — Semana 11

## Informe del Taller

### Pruebas No Funcionales en TiendaVirtual API aplicando JMeter y OWASP Top 10

**Fecha:** Junio 2026

---

## Datos del proyecto

| Campo | Detalle |
|-------|---------|
| **Proyecto** | TiendaVirtual API (Node.js + Express + SQLite) |
| **Dominio** | E-commerce — procesamiento de pedidos y reseñas de clientes |
| **Entorno de pruebas** | `http://localhost:3500` (base de datos SQLite en memoria) |
| **Herramientas utilizadas** | Apache JMeter 5.6.3 (GUI), cURL (seguridad OWASP) |

---

## 1. Resumen Ejecutivo

Se desplegó la API de tienda virtual en entorno local y se ejecutaron pruebas de **carga**, **estrés** y **seguridad** (SQLi y XSS). Los resultados confirman dos hallazgos principales:

1. **Rendimiento:** Con un solo usuario, la latencia del endpoint `GET /api/v2/tienda/calcular-pedido` se mantiene en ~500 ms. Al escalar a 50 usuarios concurrentes, la latencia media sube a **6,1 s** y el percentil 95 alcanza **17,6 s**, superando el umbral aceptable de 2 s.
2. **Seguridad:** Se explotaron con éxito vulnerabilidades de **inyección SQL** en el acceso del personal y de **XSS almacenado** en reseñas, confirmando la ausencia de consultas parametrizadas y sanitización de entradas.

---

## 2. Objetivo del taller

Aplicar pruebas no funcionales sobre una API REST vulnerable para:

- Configurar escenarios de **carga** y **estrés** e interpretar métricas de rendimiento (latencia vs. usuarios concurrentes).
- Identificar al menos **dos vulnerabilidades** del OWASP Top 10 en un entorno local autorizado.
- Documentar hallazgos y proponer soluciones técnicas viables para cuellos de botella de rendimiento y fallas de seguridad.

---

## 3. Marco Teórico y Metodología

### 3.1 Conceptos clave

- **Pruebas no funcionales:** evalúan *cómo* se comporta el sistema (rendimiento, seguridad, escalabilidad), no *qué* hace funcionalmente.
- **Prueba de carga:** mide el comportamiento bajo una carga esperada y sostenida de usuarios concurrentes.
- **Prueba de estrés:** incrementa la carga progresivamente hasta hallar el *breakpoint* (punto de quiebre).
- **OWASP Top 10:** estándar que clasifica los diez riesgos de seguridad más críticos en aplicaciones web.
- **Apache JMeter:** herramienta de código abierto para pruebas de carga mediante planes `.jmx` e interfaz gráfica (GUI).

### 3.2 Entorno de prueba

| Componente | Especificación |
|------------|----------------|
| Sistema operativo | Windows / Linux |
| Runtime | Node.js + Express |
| Base de datos | SQLite (en memoria) |
| Herramienta de carga | Apache JMeter 5.6.3 (GUI) |
| Herramienta de seguridad | cURL |

### 3.3 Metodología aplicada

1. Despliegue del entorno local y verificación de endpoints.
2. Medición de línea base con un único usuario.
3. Ejecución de prueba de carga (50 threads) con JMeter GUI.
4. Ejecución de prueba de estrés escalonada (50→400 threads).
5. Pruebas de seguridad dirigidas (SQLi y XSS) en entorno autorizado.
6. Análisis de resultados y formulación de recomendaciones técnicas.

---

## 4. Fase 1 — Despliegue del Entorno

| Paso | Acción | Estado |
|------|--------|--------|
| 1 | `npm init -y` | Completado |
| 2 | `npm install express sqlite3` | Completado |
| 3 | Código fuente en `server.js` | Completado |
| 4 | Servidor en `http://localhost:3500` | Completado |

### Endpoints evaluados

| Método | Ruta | Propósito |
|--------|------|-----------|
| GET | `/api/v2/tienda/estado` | Verificación del servicio |
| GET | `/api/v2/tienda/calcular-pedido` | Prueba de rendimiento (bucle síncrono ~500 ms) |
| POST | `/api/v2/tienda/acceso-personal` | Prueba de inyección SQL |
| POST | `/api/v2/tienda/resenas` | Inyección de payload XSS |
| GET | `/api/v2/tienda/resenas` | Verificación de reflejo sin sanitizar |

---

## 5. Fase 2 — Pruebas de Rendimiento

### 5.1 Línea base (usuario único)

| Petición | Latencia |
|----------|----------|
| 1 | 501 ms |
| 2 | 501 ms |
| 3 | 501 ms |
| 4 | 501 ms |
| 5 | 501 ms |

**Conclusión:** Con concurrencia mínima, el tiempo de respuesta se mantiene en el rango esperado de **400–600 ms**.

### 5.2 Escenario 1: Prueba de Carga

**Herramienta:** Apache JMeter (`tests/jmeter/load-test.jmx`) — GUI

| Parámetro | Valor |
|-----------|-------|
| Usuarios concurrentes (Threads) | 50 |
| Ramp-up | 10 s |
| Duración en carga plena | 40 s |
| Endpoint | `GET /api/v2/tienda/calcular-pedido` |

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

Aunque no hubo errores HTTP con 50 usuarios concurrentes, la latencia deja de ser aceptable. Node.js es **single-thread**: el bucle síncrono en `calcular-pedido` bloquea el event loop y encola las peticiones entrantes.

### 5.3 Escenario 2: Prueba de Estrés (búsqueda del breakpoint)

**Herramienta:** Apache JMeter (`tests/jmeter/stress-test.jmx`) — GUI

| Etapa | Duración | Usuarios (Threads) objetivo |
|-------|----------|----------------------------|
| 1 | 15 s | 50 |
| 2 | 15 s | 100 |
| 3 | 15 s | 200 |
| 4 | 15 s | 300 |
| 5 | 15 s | 400 |

**Condición de parada:** detener cuando la tasa de error supere el 5 %.

**Resultado:**

| Métrica | Valor |
|---------|-------|
| Usuarios alcanzados antes del abort | **~39** |
| Tasa de error | **100 %** (timeouts a 10 s) |
| Latencia en fallos | ~10 s (timeout) |
| Peticiones completadas con fallo | 6 |

**Breakpoint identificado:** La API deja de responder de forma fiable con aproximadamente **35–40 usuarios concurrentes**, muy por debajo de los 200–400 planificados.

**Causa raíz — código bloqueante:**

```javascript
while (Date.now() - inicio < 500) {
  // Simulación síncrona de cálculo de inventario — bloquea el event loop
}
```

---

## 6. Fase 3 — Pruebas de Seguridad (OWASP Top 10)

> **Nota ética:** Todas las pruebas se ejecutaron exclusivamente contra el entorno local autorizado (`localhost:3500`). No se realizaron ataques contra sistemas externos.

### 6.1 Vulnerabilidad 1: Inyección SQL (SQLi)

| Campo | Valor |
|-------|-------|
| Endpoint | `POST /api/v2/tienda/acceso-personal` |
| Payload (usuario) | `' OR '1'='1' --` |
| Categoría OWASP | A03:2021 – Injection |
| Severidad | **Alta** |

**Evidencia de explotación:**

```json
{
  "acceso": true,
  "empleado": {
    "id": 1,
    "usuario": "gerente",
    "clave": "claveTienda2026!",
    "cargo": "gerente_general"
  }
}
```

**HTTP Status:** 200

**Hallazgo:** La API devuelve los datos del gerente sin validar la clave correcta. La consulta se construye por concatenación directa:

```javascript
const consulta = `SELECT * FROM personal_tienda WHERE usuario = '${usuario}' AND clave = '${clave}'`;
```

### 6.2 Vulnerabilidad 2: Cross-Site Scripting (XSS)

| Campo | Valor |
|-------|-------|
| Endpoint POST | `POST /api/v2/tienda/resenas` |
| Endpoint GET | `GET /api/v2/tienda/resenas` |
| Payload | `<script>alert(1)</script>` |
| Categoría OWASP | A03:2021 – Injection (XSS) |
| Severidad | **Media–Alta** |

**Evidencia POST (201 Created):**

```json
{"id": 1, "mensaje": "<script>alert(1)</script>"}
```

**Evidencia GET (reflejo sin sanitizar):**

```json
[
  {"id": 1, "mensaje": "<script>alert(1)</script>", "registrado_en": "..."}
]
```

**Cabeceras relevantes:**

```
X-XSS-Protection: 0
Content-Type: application/json; charset=utf-8
```

**Hallazgo:** El servidor almacena y devuelve el script inyectado sin escapar. La cabecera `X-XSS-Protection` está desactivada (`0`).

---

## 7. Fase 4 — Recomendaciones Técnicas

### 7.1 Soluciones de Infraestructura (rendimiento)

| Recomendación | Descripción |
|---------------|-------------|
| **Auto-scaling** | Escalar instancias cuando la latencia p95 supere 2 s o la CPU supere el 70 %. |
| **Balanceador de carga** | Distribuir peticiones entre múltiples réplicas (Nginx, ALB, HAProxy). |
| **Colas de trabajo** | Externalizar el cálculo de pedidos a workers (Bull, RabbitMQ, SQS). |
| **Monitoreo** | Alertas sobre latencia p95, tasa de error y profundidad de cola. |

### 7.2 Soluciones de Código (seguridad)

| Recomendación | Aplica a | Implementación |
|---------------|----------|----------------|
| **Consultas parametrizadas** | SQLi | `db.get('SELECT * FROM personal_tienda WHERE usuario = ? AND clave = ?', [usuario, clave])` |
| **Sanitización de inputs** | SQLi, XSS | Librerías `validator`, `DOMPurify` o `he` |
| **Hashing de contraseñas** | SQLi (impacto) | `bcrypt` / `argon2` |
| **Cabeceras de seguridad** | XSS | `helmet` en Express (CSP, X-XSS-Protection) |
| **Codificación de salida** | XSS | Escapar datos al renderizar en HTML |

### 7.3 Solución para el cuello de botella de rendimiento

```javascript
const { Worker } = require('worker_threads');

app.get('/api/v2/tienda/calcular-pedido', (_req, res) => {
  const worker = new Worker('./workers/calculo-pedido.js');
  worker.on('message', (resultado) => res.json(resultado));
});
```

---

## 8. Conclusión

Las pruebas no funcionales demuestran que TiendaVirtual API cumple el comportamiento esperado en condiciones normales (latencia ~500 ms con un usuario), pero **degrada de forma crítica bajo concurrencia** debido al modelo single-thread de Node.js y el código síncrono bloqueante. El breakpoint operativo se alcanza con menos de 40 usuarios concurrentes.

En seguridad, se confirmaron **dos vulnerabilidades del OWASP Top 10** (inyección SQL y XSS almacenado), mitigables con consultas parametrizadas, sanitización de entradas y cabeceras de protección adecuadas.

---

## 9. Anexos y reproducción

| Archivo | Contenido |
|---------|-----------|
| `tests/jmeter/load-test.jmx` | Plan JMeter — carga (50 threads) |
| `tests/jmeter/stress-test.jmx` | Plan JMeter — estrés (50→400 threads) |
| `tests/security-tests.bat` | Pruebas SQLi y XSS |
| `INFORME_ENTREGA.md` | Este informe |

**Pasos de reproducción:**

```bash
npm install
npm start
```

JMeter GUI:

1. **File → Open** → `tests/jmeter/load-test.jmx`
2. Clic en **Start** ▶
3. Repetir con `stress-test.jmx`

Seguridad:

```bat
scripts\run-jmeter-security.bat
```

---

## 10. Referencias

1. OWASP Foundation. (2021). *OWASP Top 10:2021*.
2. Apache Software Foundation. *Apache JMeter — User's Manual*.
3. Node.js Foundation. *The Node.js Event Loop*.
4. OWASP Foundation. *SQL Injection Prevention Cheat Sheet* y *XSS Prevention Cheat Sheet*.
