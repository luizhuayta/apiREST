@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0.."
set "JMETER_VERSION=5.6.3"
set "JMETER_BIN="
set "JMETER_HOME_DIR="

if defined JMETER_HOME if exist "%JMETER_HOME%\bin\ApacheJMeter.jar" (
  set "JMETER_HOME_DIR=%JMETER_HOME%"
  set "JMETER_BIN=%JMETER_HOME%\bin\jmeter.bat"
  goto :found
)

if exist "%ROOT_DIR%\tools\apache-jmeter-%JMETER_VERSION%\bin\ApacheJMeter.jar" (
  set "JMETER_HOME_DIR=%ROOT_DIR%\tools\apache-jmeter-%JMETER_VERSION%"
  set "JMETER_BIN=%JMETER_HOME_DIR%\bin\jmeter.bat"
  goto :found
)

if exist "%USERPROFILE%\apache-jmeter-%JMETER_VERSION%\bin\ApacheJMeter.jar" (
  set "JMETER_HOME_DIR=%USERPROFILE%\apache-jmeter-%JMETER_VERSION%"
  set "JMETER_BIN=%JMETER_HOME_DIR%\bin\jmeter.bat"
  goto :found
)

if exist "D:\apache-jmeter-%JMETER_VERSION%\bin\ApacheJMeter.jar" (
  set "JMETER_HOME_DIR=D:\apache-jmeter-%JMETER_VERSION%"
  set "JMETER_BIN=%JMETER_HOME_DIR%\bin\jmeter.bat"
  goto :found
)

if exist "E:\apache-jmeter-%JMETER_VERSION%\bin\ApacheJMeter.jar" (
  set "JMETER_HOME_DIR=E:\apache-jmeter-%JMETER_VERSION%"
  set "JMETER_BIN=%JMETER_HOME_DIR%\bin\jmeter.bat"
  goto :found
)

if exist "C:\apache-jmeter-%JMETER_VERSION%\bin\ApacheJMeter.jar" (
  set "JMETER_HOME_DIR=C:\apache-jmeter-%JMETER_VERSION%"
  set "JMETER_BIN=%JMETER_HOME_DIR%\bin\jmeter.bat"
  goto :found
)

where jmeter.bat >nul 2>&1
if %ERRORLEVEL%==0 (
  for /f "delims=" %%i in ('where jmeter.bat') do (
    set "JMETER_BIN=%%i"
    goto :found
  )
)

echo.
echo ============================================
echo  JMETER NO ENCONTRADO
echo ============================================
echo.
echo El error que viste pasa cuando la carpeta tools\ esta incompleta
echo o el PC de la universidad bloquea descargas.
echo.
echo OPCION A - En casa, descarga y copia al USB:
echo   https://jmeter.apache.org/download_jmeter.cgi
echo   Archivo: apache-jmeter-%JMETER_VERSION%.zip
echo   Descomprime y copia la carpeta completa a:
echo     %ROOT_DIR%\tools\apache-jmeter-%JMETER_VERSION%
echo   o a Documentos: %USERPROFILE%\apache-jmeter-%JMETER_VERSION%
echo.
echo OPCION B - Usa la GUI (mas facil en PC universitario):
echo   scripts\abrir-jmeter-carga.bat
echo   scripts\abrir-jmeter-estres.bat
echo.
echo Ver guia: GUIA-PC-UNIVERSIDAD.md
echo.
exit /b 1

:found
endlocal & set "JMETER_BIN=%JMETER_BIN%" & set "JMETER_HOME_DIR=%JMETER_HOME_DIR%" & exit /b 0
