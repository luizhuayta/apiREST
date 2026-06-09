@echo off
setlocal

set "ROOT_DIR=%~dp0.."
set "JMETER_VERSION=5.6.3"
set "TOOLS_DIR=%ROOT_DIR%\tools"
set "TARGET_DIR=%TOOLS_DIR%\apache-jmeter-%JMETER_VERSION%"
set "ARCHIVE=apache-jmeter-%JMETER_VERSION%.tgz"
set "URL=https://dlcdn.apache.org/jmeter/binaries/%ARCHIVE%"

if exist "%TARGET_DIR%\bin\jmeter.bat" (
  echo JMeter ya esta instalado en: %TARGET_DIR%
  exit /b 0
)

if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"

echo Descargando Apache JMeter %JMETER_VERSION%...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Invoke-WebRequest -Uri '%URL%' -OutFile '%TOOLS_DIR%\%ARCHIVE%'"

echo Extrayendo...
tar -xzf "%TOOLS_DIR%\%ARCHIVE%" -C "%TOOLS_DIR%"
del "%TOOLS_DIR%\%ARCHIVE%"

echo.
echo JMeter instalado en: %TARGET_DIR%
echo Opcional: set JMETER_HOME=%TARGET_DIR%
