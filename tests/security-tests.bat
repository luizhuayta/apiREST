@echo off
setlocal

set "BASE_URL=%BASE_URL%"
if not defined BASE_URL set "BASE_URL=http://localhost:3500"
set "OUTPUT_DIR=%OUTPUT_DIR%"
if not defined OUTPUT_DIR set "OUTPUT_DIR=%~dp0..\results"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo === Prueba 1a: SQL Injection en acceso-personal ===
curl -s -X POST "%BASE_URL%/api/v2/tienda/acceso-personal" -H "Content-Type: application/json" -d "{\"usuario\": \"' OR '1'='1' --\", \"clave\": \"cualquiera\"}"
echo.

echo === Prueba 1b: SQL Injection clasica ===
curl -s -X POST "%BASE_URL%/api/v2/tienda/acceso-personal" -H "Content-Type: application/json" -d "{\"usuario\": \"' OR '1'='1\", \"clave\": \"' OR '1'='1\"}"
echo.

echo === Prueba 2: XSS en resenas ===
curl -s -X POST "%BASE_URL%/api/v2/tienda/resenas" -H "Content-Type: application/json" -d "{\"mensaje\": \"<script>alert(1)</script>\"}"
echo.

echo === GET resenas ===
curl -s "%BASE_URL%/api/v2/tienda/resenas"
echo.
