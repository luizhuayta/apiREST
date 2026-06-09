# TiendaVirtual API — Pruebas No Funcionales (Semana 11)

API REST de una **tienda en línea** (intencionalmente vulnerable) para prácticas con **Apache JMeter** y **OWASP**.

> **Rama de entrega:** `cursor/tienda-virtual-entrega-ac48` — variante diferenciada del proyecto base.

## Requisitos

- Node.js 18+
- Java 8+ (JMeter GUI o portable)

## Inicio rápido

```bash
npm install
npm start
```

La API queda en **`http://localhost:3500`**.

## Endpoints

| Método | Ruta | Uso |
|--------|------|-----|
| GET | `/api/v2/tienda/estado` | Health check |
| GET | `/api/v2/tienda/calcular-pedido` | Prueba de rendimiento (JMeter) |
| POST | `/api/v2/tienda/acceso-personal` | Login — prueba SQLi |
| POST/GET | `/api/v2/tienda/resenas` | Reseñas — prueba XSS |

## Pruebas con JMeter GUI

1. `npm start`
2. Abrir JMeter → **File → Open**
3. Cargar `tests/jmeter/load-test.jmx` o `stress-test.jmx`
4. Clic en **Start** ▶

Los planes ya tienen **50 usuarios** (carga) y **50→400** (estrés) configurados.

## Pruebas de seguridad

```bat
scripts\run-jmeter-security.bat
```

## Informe

Ver `INFORME_TIENDA_VIRTUAL.md`
