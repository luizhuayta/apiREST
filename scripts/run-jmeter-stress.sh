#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=jmeter-common.sh
source "$ROOT_DIR/scripts/jmeter-common.sh"

ensure_jmeter
JMETER_BIN="$(resolve_jmeter_bin)"
RESULTS_DIR="${RESULTS_DIR:-$ROOT_DIR/results/jmeter}"
mkdir -p "$RESULTS_DIR"

HOST="${HOST:-localhost}"
PORT="${PORT:-3000}"

echo "=== Prueba de Estrés JMeter ==="
echo "Plan: tests/jmeter/stress-test.jmx"
echo "API: http://${HOST}:${PORT}"
echo "Resultados: ${RESULTS_DIR}/stress"
echo ""

"$JMETER_BIN" -n \
  -t "$ROOT_DIR/tests/jmeter/stress-test.jmx" \
  -l "$RESULTS_DIR/stress-results.jtl" \
  -j "$RESULTS_DIR/stress-jmeter.log" \
  -e -o "$RESULTS_DIR/stress-report" \
  -JHOST="$HOST" \
  -JPORT="$PORT"

echo ""
echo "Listo. Abre el reporte HTML en:"
echo "  ${RESULTS_DIR}/stress-report/index.html"
