@echo off
setlocal enabledelayedexpansion

set "ROOT_DIR=%~dp0.."
set "JMETER_VERSION=5.6.3"
set "RESULTS_DIR=%ROOT_DIR%\results\jmeter"

if defined JMETER_HOME (
  set "JMETER_BIN=%JMETER_HOME%\bin\jmeter.bat"
) else if exist "%ROOT_DIR%\tools\apache-jmeter-%JMETER_VERSION%\bin\jmeter.bat" (
  set "JMETER_BIN=%ROOT_DIR%\tools\apache-jmeter-%JMETER_VERSION%\bin\jmeter.bat"
) else (
  where jmeter >nul 2>&1
  if %ERRORLEVEL%==0 (
    set "JMETER_BIN=jmeter"
  ) else (
    echo JMeter no encontrado. Ejecuta primero: scripts\setup-jmeter.bat
    exit /b 1
  )
)

if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

if not defined HOST set "HOST=localhost"
if not defined PORT set "PORT=3000"

echo === Prueba de Carga JMeter ===
echo Plan: tests\jmeter\load-test.jmx
echo API: http://%HOST%:%PORT%
echo.

call "%JMETER_BIN%" -n ^
  -t "%ROOT_DIR%\tests\jmeter\load-test.jmx" ^
  -l "%RESULTS_DIR%\load-results.jtl" ^
  -j "%RESULTS_DIR%\load-jmeter.log" ^
  -e -o "%RESULTS_DIR%\load-report" ^
  -JHOST=%HOST% ^
  -JPORT=%PORT%

echo.
echo Listo. Abre el reporte HTML en:
echo   %RESULTS_DIR%\load-report\index.html
