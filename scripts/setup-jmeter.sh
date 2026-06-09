#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JMETER_VERSION="5.6.3"
TOOLS_DIR="$ROOT_DIR/tools"
ARCHIVE="apache-jmeter-${JMETER_VERSION}.tgz"
URL="https://dlcdn.apache.org/jmeter/binaries/${ARCHIVE}"
TARGET_DIR="$TOOLS_DIR/apache-jmeter-${JMETER_VERSION}"

mkdir -p "$TOOLS_DIR"

if [[ -x "$TARGET_DIR/bin/jmeter" ]]; then
  echo "JMeter ya está instalado en: $TARGET_DIR"
  exit 0
fi

echo "Descargando Apache JMeter ${JMETER_VERSION}..."
curl -fsSL "$URL" -o "$TOOLS_DIR/$ARCHIVE"
tar -xzf "$TOOLS_DIR/$ARCHIVE" -C "$TOOLS_DIR"
rm -f "$TOOLS_DIR/$ARCHIVE"

echo ""
echo "JMeter instalado en: $TARGET_DIR"
echo "Puedes exportar JMETER_HOME si quieres:"
echo "  export JMETER_HOME=\"$TARGET_DIR\""
