@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0.."
set "RESULTS_DIR=%ROOT_DIR%\results\jmeter"

call "%~dp0jmeter-common.bat"
if errorlevel 1 exit /b 1

if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

if not defined HOST set "HOST=localhost"
if not defined PORT set "PORT=3000"

echo === Prueba de Carga JMeter ===
echo Plan: tests\jmeter\load-test.jmx
echo API: http://%HOST%:%PORT%
echo JMeter: %JMETER_BIN%
echo.

cd /d "%JMETER_HOME_DIR%\bin"
call jmeter.bat -n ^
  -t "%ROOT_DIR%\tests\jmeter\load-test.jmx" ^
  -l "%RESULTS_DIR%\load-results.jtl" ^
  -j "%RESULTS_DIR%\load-jmeter.log" ^
  -e -o "%RESULTS_DIR%\load-report" ^
  -JHOST=%HOST% ^
  -JPORT=%PORT%

if errorlevel 1 (
  echo.
  echo Fallo la prueba. Prueba la GUI: scripts\abrir-jmeter-carga.bat
  exit /b 1
)

echo.
echo Listo. Abre el reporte:
echo   %RESULTS_DIR%\load-report\index.html
