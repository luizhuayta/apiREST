# Guía Práctica N° 11 — Semana 11

## Informe del Taller

### Pruebas No Funcionales en TiendaVirtual API aplicando JMeter y OWASP Top 10

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
| **Proyecto** | TiendaVirtual API (Node.js + Express + SQLite) |
| **Dominio** | E-commerce — cálculo de pedidos y reseñas de clientes |
| **Entorno** | `http://localhost:3500` |
| **Herramientas** | Apache JMeter 5.6.3 (GUI), cURL |
| **Repositorio** | Rama `cursor/tienda-virtual-entrega-ac48` |

---

## 1. Resumen Ejecutivo

Se desplegó la API de tienda virtual y se ejecutaron pruebas de **carga**, **estrés** y **seguridad**. Hallazgos principales:

1. **Rendimiento:** Con 1 usuario, `GET /api/v2/tienda/calcular-pedido` responde en ~500 ms. Con 50 threads, la latencia media supera **6 s** (p95 ~17,6 s).
2. **Seguridad:** SQLi en `acceso-personal` y XSS almacenado en `resenas` confirmados.

---

## 2. Endpoints evaluados

| Método | Ruta | Propósito |
|--------|------|-----------|
| GET | `/api/v2/tienda/calcular-pedido` | Cálculo síncrono de pedido (~500 ms) |
| POST | `/api/v2/tienda/acceso-personal` | Autenticación del personal (SQLi) |
| POST | `/api/v2/tienda/resenas` | Publicar reseña (XSS) |
| GET | `/api/v2/tienda/resenas` | Listar reseñas sin sanitizar |

---

## 3. Pruebas de rendimiento (JMeter GUI)

### Carga — `load-test.jmx`

| Parámetro | Valor |
|-----------|-------|
| Threads | 50 |
| Ramp-up | 10 s |
| Duración | 40 s |
| Endpoint | `GET /api/v2/tienda/calcular-pedido` |

### Estrés — `stress-test.jmx`

Etapas: **50 → 100 → 200 → 300 → 400** threads (15 s c/u).

Breakpoint observado: ~**35–40 usuarios** concurrentes.

---

## 4. Pruebas de seguridad

### SQLi — `POST /api/v2/tienda/acceso-personal`

Payload: `' OR '1'='1' --` en campo `usuario` → acceso como gerente sin clave válida.

### XSS — `POST/GET /api/v2/tienda/resenas`

Payload: `<script>alert(1)</script>` en `mensaje` → almacenado y devuelto sin filtrar. Cabecera `X-XSS-Protection: 0`.

---

## 5. Recomendaciones

**Infraestructura:** auto-scaling, balanceador de carga, colas de trabajo, monitoreo p95.

**Código:** consultas parametrizadas, sanitización de inputs, `helmet`, worker threads para cálculo de pedidos.

---

## 6. Reproducción

```bash
npm install
npm start
```

JMeter GUI → abrir `tests/jmeter/load-test.jmx` → **Start**.

Seguridad: `scripts\run-jmeter-security.bat`
