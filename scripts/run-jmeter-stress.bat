@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0.."
set "RESULTS_DIR=%ROOT_DIR%\results\jmeter"

call "%~dp0jmeter-common.bat"
if errorlevel 1 exit /b 1

if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

if not defined HOST set "HOST=localhost"
if not defined PORT set "PORT=3500"

echo === Prueba de Estres JMeter ===
echo Plan: tests\jmeter\stress-test.jmx
echo API: http://%HOST%:%PORT%
echo JMeter: %JMETER_BIN%
echo.

cd /d "%JMETER_HOME_DIR%\bin"
call jmeter.bat -n ^
  -t "%ROOT_DIR%\tests\jmeter\stress-test.jmx" ^
  -l "%RESULTS_DIR%\stress-results.jtl" ^
  -j "%RESULTS_DIR%\stress-jmeter.log" ^
  -e -o "%RESULTS_DIR%\stress-report" ^
  -JHOST=%HOST% ^
  -JPORT=%PORT%

if errorlevel 1 (
  echo.
  echo Fallo la prueba. Prueba la GUI: scripts\abrir-jmeter-estres.bat
  exit /b 1
)

echo.
echo Listo. Abre el reporte:
echo   %RESULTS_DIR%\stress-report\index.html
