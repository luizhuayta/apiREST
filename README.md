# apiREST — Pruebas No Funcionales (Semana 11)

API REST vulnerable para prácticas de rendimiento con **Apache JMeter** y seguridad **OWASP**.

## Requisitos

- Node.js 18+
- Java 8+ (para JMeter)

## Inicio rápido (3 pasos)

### 1. Levantar la API

```bash
npm install
npm start
```

La API queda en `http://localhost:3000`.

### 2. Instalar JMeter (solo la primera vez)

**Windows:**
```bat
scripts\setup-jmeter.bat
```

**Linux / Mac:**
```bash
chmod +x scripts/*.sh
./scripts/setup-jmeter.sh
```

> También puedes descargar JMeter manualmente desde https://jmeter.apache.org/download_jmeter.cgi y definir `JMETER_HOME`.

### 3. Ejecutar pruebas

**Windows:**
```bat
scripts\run-jmeter-load.bat
scripts\run-jmeter-stress.bat
scripts\run-jmeter-security.bat
```

**Linux / Mac:**
```bash
npm run test:load
npm run test:stress
npm run test:security
```

## Reportes generados

| Prueba | Reporte HTML |
|--------|--------------|
| Carga | `results/jmeter/load-report/index.html` |
| Estrés | `results/jmeter/stress-report/index.html` |
| Seguridad | `results/security-*.txt` |

## Estructura del proyecto

```
server.js                  # API vulnerable
tests/jmeter/
  load-test.jmx            # 50 usuarios, ramp-up 10s
  stress-test.jmx          # hasta 400 usuarios
tests/security-tests.sh    # SQLi y XSS
scripts/
  setup-jmeter.sh/.bat     # descarga JMeter automático
  run-jmeter-load.sh/.bat
  run-jmeter-stress.sh/.bat
INFORME_TECNICO.md         # Informe completo
INFORME_NOTION_SEMANA11.md # Formato para Notion
```

## Abrir planes en JMeter GUI

1. Abre Apache JMeter
2. **File → Open** → `tests/jmeter/load-test.jmx`
3. Clic en **Start** (botón verde)

Ver detalle en [tests/jmeter/README.md](./tests/jmeter/README.md).

## Informe del taller

Ver [INFORME_TECNICO.md](./INFORME_TECNICO.md) para métricas, hallazgos y recomendaciones.

## Versiones

| Tag | Descripción |
|-----|-------------|
| `v1.0.0` | Primera versión con K6 |
| `v1.1.0` | JMeter configurado + scripts listos para ejecutar |
