@echo off
setlocal

set "BASE_URL=%BASE_URL%"
if not defined BASE_URL set "BASE_URL=http://localhost:3000"
set "OUTPUT_DIR=%OUTPUT_DIR%"
if not defined OUTPUT_DIR set "OUTPUT_DIR=%~dp0..\results"

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo === Prueba 1a: SQL Injection (payload en username) ===
curl -s -X POST "%BASE_URL%/api/v1/login" -H "Content-Type: application/json" -d "{\"username\": \"' OR '1'='1' --\", \"password\": \"cualquiera\"}"
echo.

echo === Prueba 1b: SQL Injection (payload clasico) ===
curl -s -X POST "%BASE_URL%/api/v1/login" -H "Content-Type: application/json" -d "{\"username\": \"' OR '1'='1\", \"password\": \"' OR '1'='1\"}"
echo.

echo === Prueba 2: XSS en POST /api/v1/comments ===
curl -s -X POST "%BASE_URL%/api/v1/comments" -H "Content-Type: application/json" -d "{\"body\": \"<script>alert(1)</script>\"}"
echo.

echo === Verificacion GET /api/v1/comments ===
curl -s "%BASE_URL%/api/v1/comments"
echo.
