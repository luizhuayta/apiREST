#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"
OUTPUT_DIR="${OUTPUT_DIR:-/workspace/results}"
mkdir -p "$OUTPUT_DIR"

echo "=== Prueba 1a: SQL Injection (payload en username) ===" | tee "$OUTPUT_DIR/security-sqli.txt"
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "'\'' OR '\''1'\''='\''1'\'' --", "password": "cualquiera"}' \
  -w "\nHTTP_STATUS:%{http_code}\n" | tee -a "$OUTPUT_DIR/security-sqli.txt"

echo "" | tee -a "$OUTPUT_DIR/security-sqli.txt"
echo "=== Prueba 1b: SQL Injection (payload clásico en username y password) ===" | tee -a "$OUTPUT_DIR/security-sqli.txt"
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "'\'' OR '\''1'\''='\''1", "password": "'\'' OR '\''1'\''='\''1"}' \
  -w "\nHTTP_STATUS:%{http_code}\n" | tee -a "$OUTPUT_DIR/security-sqli.txt"

echo "" | tee -a "$OUTPUT_DIR/security-sqli.txt"
echo "=== Prueba 2: XSS en POST /api/v1/comments ===" | tee "$OUTPUT_DIR/security-xss.txt"
curl -s -X POST "$BASE_URL/api/v1/comments" \
  -H "Content-Type: application/json" \
  -d '{"body": "<script>alert(1)</script>"}' \
  -w "\nHTTP_STATUS:%{http_code}\n" | tee -a "$OUTPUT_DIR/security-xss.txt"

echo "" | tee -a "$OUTPUT_DIR/security-xss.txt"
echo "=== Verificación GET /api/v1/comments (reflejo sin sanitizar) ===" | tee -a "$OUTPUT_DIR/security-xss.txt"
curl -s -D "$OUTPUT_DIR/security-xss-headers.txt" "$BASE_URL/api/v1/comments" | tee -a "$OUTPUT_DIR/security-xss.txt"
echo "" | tee -a "$OUTPUT_DIR/security-xss.txt"
echo "=== Cabeceras de respuesta ===" | tee -a "$OUTPUT_DIR/security-xss.txt"
cat "$OUTPUT_DIR/security-xss-headers.txt" | tee -a "$OUTPUT_DIR/security-xss.txt"
