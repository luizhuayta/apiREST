#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JMETER_VERSION="5.6.3"
JMETER_DIR="${JMETER_HOME:-$ROOT_DIR/tools/apache-jmeter-$JMETER_VERSION}"

resolve_jmeter_bin() {
  if [[ -n "${JMETER_HOME:-}" && -x "$JMETER_HOME/bin/jmeter" ]]; then
    echo "$JMETER_HOME/bin/jmeter"
    return 0
  fi

  if [[ -x "$JMETER_DIR/bin/jmeter" ]]; then
    echo "$JMETER_DIR/bin/jmeter"
    return 0
  fi

  if command -v jmeter >/dev/null 2>&1; then
    command -v jmeter
    return 0
  fi

  return 1
}

ensure_jmeter() {
  if resolve_jmeter_bin >/dev/null; then
    return 0
  fi

  echo "JMeter no encontrado. Ejecutando instalación automática..."
  "$ROOT_DIR/scripts/setup-jmeter.sh"
}
