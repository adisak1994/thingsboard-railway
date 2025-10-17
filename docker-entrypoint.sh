#!/usr/bin/env bash
set -e

TB_BIN="/usr/share/thingsboard/bin/thingsboard"
INSTALL_SH="/usr/share/thingsboard/bin/install/install.sh"

if [ ! -x "$TB_BIN" ]; then
  echo "[ERROR] ThingsBoard binary not found at $TB_BIN"
  echo "Listing /usr/share/thingsboard for debugging:"
  ls -la /usr/share || true
  ls -la /usr/share/thingsboard || true
  exit 127
fi

MARKER="/data/.tb_installed"
mkdir -p /data

if [ "{${TB_INSTALL}}" = "true" ] && [ ! -f "$MARKER" ]; then
  echo "[TB] Running initial DB install..."
  : "${SPRING_DATASOURCE_URL:?Missing SPRING_DATASOURCE_URL}"
  : "${SPRING_DATASOURCE_USERNAME:?Missing SPRING_DATASOURCE_USERNAME}"
  : "${SPRING_DATASOURCE_PASSWORD:?Missing SPRING_DATASOURCE_PASSWORD}"

  if [ -x "$INSTALL_SH" ]; then
    "$INSTALL_SH"
    # For demo data, replace the above with: "$INSTALL_SH" --loadDemo
  else
    echo "[ERROR] Install script not found at $INSTALL_SH"
    ls -la /usr/share/thingsboard/bin || true
    exit 127
  fi

  touch "$MARKER"
  echo "[TB] Install complete."
fi

exec "$@"
