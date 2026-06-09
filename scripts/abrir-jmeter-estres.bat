@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0.."

call "%~dp0jmeter-common.bat"
if errorlevel 1 (
  echo.
  echo Si no tienes JMeter, abre manualmente jmeter.bat y carga:
  echo   %ROOT_DIR%\tests\jmeter\stress-test.jmx
  pause
  exit /b 1
)

echo Abriendo JMeter GUI - Prueba de ESTRES (50 a 400 usuarios)
echo 1. Verifica que npm start este corriendo
echo 2. Clic en el boton verde START
echo.

cd /d "%JMETER_HOME_DIR%\bin"
start "" jmeter.bat -t "%ROOT_DIR%\tests\jmeter\stress-test.jmx"
