#!/usr/bin/env bash
set -e

TB_DIR="/usr/share/thingsboard"
TB_BIN_DIR="$TB_DIR/bin"
TB_JAR="$TB_BIN_DIR/thingsboard.jar"
TB_INSTALL_SH="$TB_BIN_DIR/install/install.sh"
CONF_DIR="$TB_DIR/conf"
LOG_DIR="$TB_DIR/logs"

echo "[TB] Checking installation layout..."
ls -la "$TB_DIR" || true
ls -la "$TB_BIN_DIR" || true

if [ ! -f "$TB_JAR" ]; then
  echo "[ERROR] ThingsBoard JAR not found at $TB_JAR"
  exit 127
fi

mkdir -p /data "$LOG_DIR"

if [ "${TB_INSTALL}" = "true" ] && [ ! -f "/data/.tb_installed" ]; then
  echo "[TB] Running initial DB install..."
  : "${SPRING_DATASOURCE_URL:?Missing SPRING_DATASOURCE_URL}"
  : "${SPRING_DATASOURCE_USERNAME:?Missing SPRING_DATASOURCE_USERNAME}"
  : "${SPRING_DATASOURCE_PASSWORD:?Missing SPRING_DATASOURCE_PASSWORD}"

  if [ -x "$TB_INSTALL_SH" ]; then
    set +e
    "$TB_INSTALL_SH"
    rc=$?
    set -e
    if [ $rc -ne 0 ]; then
      echo "[ERROR] Install script failed with code $rc"
      ls -la "$LOG_DIR" || true
      tail -n 200 "$LOG_DIR"/thingsboard.log 2>/dev/null || true
      exit $rc
    fi
  else
    echo "[ERROR] Install script not executable or missing at $TB_INSTALL_SH"
    ls -la "$TB_BIN_DIR/install" || true
    exit 127
  fi

  touch /data/.tb_installed
  echo "[TB] Install complete."
fi

if [ "$1" = "run" ]; then
  echo "[TB] Starting ThingsBoard via java -jar"
  exec java $JAVA_OPTS     -Dspring.config.additional-location="$CONF_DIR/"     -Dlogging.config="$CONF_DIR/logback.xml"     -jar "$TB_JAR"
fi

# Fallback to exec any custom command
exec "$@"
