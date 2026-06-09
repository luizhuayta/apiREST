@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0.."
set "JMETER_VERSION=5.6.3"
set "TOOLS_DIR=%ROOT_DIR%\tools"
set "TARGET_DIR=%TOOLS_DIR%\apache-jmeter-%JMETER_VERSION%"
set "ZIP_FILE=%TOOLS_DIR%\apache-jmeter-%JMETER_VERSION%.zip"
set "URL=https://dlcdn.apache.org/jmeter/binaries/apache-jmeter-%JMETER_VERSION%.zip"

if exist "%TARGET_DIR%\bin\ApacheJMeter.jar" (
  echo JMeter OK en: %TARGET_DIR%
  exit /b 0
)

echo ============================================
echo  Instalando JMeter %JMETER_VERSION% (portable)
echo  Carpeta: %TARGET_DIR%
echo ============================================
echo.

if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"

if exist "%TARGET_DIR%" rmdir /s /q "%TARGET_DIR%"

echo [1/2] Descargando ZIP...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP_FILE%' -UseBasicParsing"
if errorlevel 1 (
  echo.
  echo ERROR: No se pudo descargar. Posibles causas:
  echo   - Sin internet en el PC de la universidad
  echo   - Firewall bloqueando la descarga
  echo.
  echo SOLUCION: Descarga en casa este archivo y descomprime en tools\
  echo   %URL%
  echo   Debe quedar: tools\apache-jmeter-%JMETER_VERSION%\bin\ApacheJMeter.jar
  exit /b 1
)

echo [2/2] Descomprimiendo...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%TOOLS_DIR%' -Force"
if errorlevel 1 (
  echo ERROR al descomprimir. Borra tools\ e intenta de nuevo.
  exit /b 1
)

del /f /q "%ZIP_FILE%" 2>nul

if not exist "%TARGET_DIR%\bin\ApacheJMeter.jar" (
  echo ERROR: Instalacion incompleta. Falta ApacheJMeter.jar
  exit /b 1
)

echo.
echo LISTO. JMeter instalado en:
echo   %TARGET_DIR%
echo.
exit /b 0
