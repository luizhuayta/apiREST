# Guía para PC de Universidad (sin permisos de admin)

Si `run-jmeter-stress.bat` da error como:

```
Unable to access jarfile ... jmeter.batApacheJMeter.jar
```

**Significa que JMeter NO está instalado completo.** El PC bloqueó la descarga o la carpeta `tools\` quedó a medias.

---

## Opción 1 — La más fácil: JMeter en USB (recomendada)

Haz esto **en casa** con internet:

1. Descarga: https://jmeter.apache.org/download_jmeter.cgi  
   Archivo: **`apache-jmeter-5.6.3.zip`** (Binaries)
2. Descomprime el ZIP.
3. Copia la carpeta **`apache-jmeter-5.6.3`** completa a:
   - Un **USB**, o
   - `C:\Users\UPSJB\Documents\apache-jmeter-5.6.3`

4. En la universidad, copia esa carpeta a:
   ```
   C:\Users\UPSJB\Documents\apiREST-main\tools\apache-jmeter-5.6.3
   ```
   Debe existir este archivo:
   ```
   tools\apache-jmeter-5.6.3\bin\ApacheJMeter.jar
   ```

5. Ejecuta de nuevo:
   ```bat
   scripts\run-jmeter-load.bat
   scripts\run-jmeter-stress.bat
   ```

---

## Opción 2 — Solo GUI (sin scripts, sin instalar nada)

Si tienes JMeter en USB o en Documentos:

1. Doble clic en:
   ```
   apache-jmeter-5.6.3\bin\jmeter.bat
   ```
2. En otra terminal:
   ```bat
   npm start
   ```
3. En JMeter: **File → Open** → abre:
   - `tests\jmeter\load-test.jmx` (50 usuarios)
   - `tests\jmeter\stress-test.jmx` (50→400 usuarios)
4. Clic en el botón verde **Start** ▶

**No tienes que configurar usuarios.** Ya están en el plan:
- Carga: **50 threads**, ramp-up **10 s**
- Estrés: etapas **50, 100, 200, 300, 400**

5. Para ver resultados en GUI: agrega listener **View Results Tree** o **Summary Report** (clic derecho en Thread Group → Add → Listener).

---

## Opción 3 — Scripts que abren la GUI directo

Si ya copiaste JMeter a `tools\` o Documentos:

```bat
scripts\abrir-jmeter-carga.bat
scripts\abrir-jmeter-estres.bat
```

Abre JMeter con el plan cargado. Solo das **Start**.

---

## Checklist rápido

| Paso | Comando / acción |
|------|------------------|
| 1 | `npm install` (solo primera vez) |
| 2 | `npm start` (dejar abierto) |
| 3 | Tener JMeter completo con `ApacheJMeter.jar` |
| 4 | GUI: abrir `.jmx` → Start |
| 5 | Seguridad: `scripts\run-jmeter-security.bat` |

---

## Seguridad (no necesita JMeter)

```bat
scripts\run-jmeter-security.bat
```

O manualmente con Postman/curl los endpoints de login y comments.

---

## ¿Por qué falla en la universidad?

| Causa | Solución |
|-------|----------|
| Sin internet / firewall | Llevar JMeter en USB desde casa |
| No puede ejecutar `setup-jmeter.bat` | Copiar carpeta ya descomprimida |
| Carpeta `tools\` incompleta | Borrar `tools\` y copiar JMeter completo |
| Sin Java | JMeter necesita Java 8+ instalado |

Verifica Java:
```bat
java -version
```

Si no hay Java, en algunos PCs de universidad JMeter portable con Java incluido no funciona — usa un PC con Java o pide al profe el laboratorio con JMeter instalado.
