# apiREST — Pruebas No Funcionales

API REST vulnerable para prácticas de rendimiento (K6) y seguridad (OWASP).

## Inicio rápido

```bash
npm install
npm start
```

## Pruebas

```bash
npm run test:load      # 50 usuarios concurrentes
npm run test:stress    # rampa hasta 400 VUs
npm run test:security  # SQLi y XSS
```

## Informe

Ver [INFORME_TECNICO.md](./INFORME_TECNICO.md) para métricas, hallazgos y recomendaciones.
