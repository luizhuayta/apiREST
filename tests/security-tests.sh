#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3500}"
OUTPUT_DIR="${OUTPUT_DIR:-$(cd "$(dirname "$0")/.." && pwd)/results}"
mkdir -p "$OUTPUT_DIR"

echo "=== Prueba 1a: SQL Injection en acceso-personal ===" | tee "$OUTPUT_DIR/security-sqli.txt"
curl -s -X POST "$BASE_URL/api/v2/tienda/acceso-personal" \
  -H "Content-Type: application/json" \
  -d '{"usuario": "'\'' OR '\''1'\''='\''1'\'' --", "clave": "cualquiera"}' \
  -w "\nHTTP_STATUS:%{http_code}\n" | tee -a "$OUTPUT_DIR/security-sqli.txt"

echo "" | tee -a "$OUTPUT_DIR/security-sqli.txt"
echo "=== Prueba 1b: SQL Injection (payload en usuario y clave) ===" | tee -a "$OUTPUT_DIR/security-sqli.txt"
curl -s -X POST "$BASE_URL/api/v2/tienda/acceso-personal" \
  -H "Content-Type: application/json" \
  -d '{"usuario": "'\'' OR '\''1'\''='\''1", "clave": "'\'' OR '\''1'\''='\''1"}' \
  -w "\nHTTP_STATUS:%{http_code}\n" | tee -a "$OUTPUT_DIR/security-sqli.txt"

echo "" | tee -a "$OUTPUT_DIR/security-sqli.txt"
echo "=== Prueba 2: XSS en POST /api/v2/tienda/resenas ===" | tee "$OUTPUT_DIR/security-xss.txt"
curl -s -X POST "$BASE_URL/api/v2/tienda/resenas" \
  -H "Content-Type: application/json" \
  -d '{"mensaje": "<script>alert(1)</script>"}' \
  -w "\nHTTP_STATUS:%{http_code}\n" | tee -a "$OUTPUT_DIR/security-xss.txt"

echo "" | tee -a "$OUTPUT_DIR/security-xss.txt"
echo "=== Verificación GET /api/v2/tienda/resenas ===" | tee -a "$OUTPUT_DIR/security-xss.txt"
curl -s -D "$OUTPUT_DIR/security-xss-headers.txt" "$BASE_URL/api/v2/tienda/resenas" | tee -a "$OUTPUT_DIR/security-xss.txt"
echo "" | tee -a "$OUTPUT_DIR/security-xss.txt"
echo "=== Cabeceras de respuesta ===" | tee -a "$OUTPUT_DIR/security-xss.txt"
cat "$OUTPUT_DIR/security-xss-headers.txt" | tee -a "$OUTPUT_DIR/security-xss.txt"
