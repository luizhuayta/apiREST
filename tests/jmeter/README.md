# Pruebas JMeter — Guía Práctica 11

Planes de prueba listos para abrir en **Apache JMeter 5.6.3** o ejecutar por línea de comandos.

## Opción A — Solo ejecutar (recomendado)

### Windows

```bat
npm install
npm start

REM En otra terminal:
scripts\setup-jmeter.bat
scripts\run-jmeter-load.bat
scripts\run-jmeter-stress.bat
```

### Linux / Mac

```bash
npm install
npm start

# En otra terminal:
./scripts/setup-jmeter.sh
./scripts/run-jmeter-load.sh
./scripts/run-jmeter-stress.sh
```

Los reportes HTML quedan en `results/jmeter/load-report/` y `results/jmeter/stress-report/`.

## Opción B — JMeter ya instalado en tu PC

1. Descarga JMeter: https://jmeter.apache.org/download_jmeter.cgi
2. Descomprime y define `JMETER_HOME` apuntando a la carpeta.
3. Ejecuta los scripts `.bat` o `.sh` del paso anterior.

## Opción C — Abrir en la GUI de JMeter

1. Abre JMeter → **File → Open**
2. Carga `tests/jmeter/load-test.jmx` o `tests/jmeter/stress-test.jmx`
3. Verifica que la API esté en `http://localhost:3000`
4. Clic en el botón verde **Start**

## Configuración de los planes

### `load-test.jmx` — Prueba de Carga

| Parámetro | Valor |
|-----------|-------|
| Thread Group (usuarios) | 50 |
| Ramp-up | 10 segundos |
| Duración | 40 segundos |
| Endpoint | `GET /api/v1/heavy-process` |
| Think Time | 100 ms |

### `stress-test.jmx` — Prueba de Estrés

| Parámetro | Valor |
|-----------|-------|
| Thread Group (usuarios) | 400 (máximo) |
| Ramp-up | 75 segundos |
| Duración | 90 segundos |
| Timeout | 10 segundos |
| Endpoint | `GET /api/v1/heavy-process` |

## Variables de entorno opcionales

| Variable | Default | Descripción |
|----------|---------|-------------|
| `HOST` | `localhost` | Host de la API |
| `PORT` | `3000` | Puerto de la API |
| `JMETER_HOME` | `./tools/apache-jmeter-5.6.3` | Ruta de instalación JMeter |
