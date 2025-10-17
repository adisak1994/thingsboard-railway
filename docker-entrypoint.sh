#!/usr/bin/env bash
set -e

TB_BIN="/usr/share/thingsboard/bin/thingsboard"
INSTALL_SH="/usr/share/thingsboard/bin/install/install.sh"

echo "[TB] Verifying ThingsBoard binaries..."
if [ ! -e "$TB_BIN" ]; then
  echo "[ERROR] ThingsBoard binary not found at $TB_BIN"
  echo "== /usr/share =="
  ls -la /usr/share || true
  echo "== /usr/share/thingsboard =="
  ls -la /usr/share/thingsboard || true
  echo "== /usr/share/thingsboard/bin =="
  ls -la /usr/share/thingsboard/bin || true
  exit 127
fi

if [ ! -x "$TB_BIN" ]; then
  echo "[WARN] $TB_BIN is not executable. Applying chmod +x"
  chmod +x "$TB_BIN" || true
fi

MARKER="/data/.tb_installed"
mkdir -p /data

if [ "${TB_INSTALL}" = "true" ] && [ ! -f "$MARKER" ]; then
  echo "[TB] Running initial DB install..."
  : "${SPRING_DATASOURCE_URL:?Missing SPRING_DATASOURCE_URL}"
  : "${SPRING_DATASOURCE_USERNAME:?Missing SPRING_DATASOURCE_USERNAME}"
  : "${SPRING_DATASOURCE_PASSWORD:?Missing SPRING_DATASOURCE_PASSWORD}"

  echo "[TB] Using SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}"
  if [ -x "$INSTALL_SH" ]; then
    set +e
    "$INSTALL_SH"
    rc=$?
    set -e
    if [ $rc -ne 0 ]; then
      echo "[ERROR] TB install script exited with code $rc"
      echo "== /usr/share/thingsboard/logs (if any) =="
      ls -la /usr/share/thingsboard/logs || true
      echo "== Recent logs (if present) =="
      tail -n 200 /usr/share/thingsboard/logs/thingsboard.log 2>/dev/null || true
      exit $rc
    fi
  else
    echo "[ERROR] Install script not found at $INSTALL_SH"
    ls -la /usr/share/thingsboard/bin || true
    exit 127
  fi

  touch "$MARKER"
  echo "[TB] Install complete."
fi

echo "[TB] Starting ThingsBoard..."
exec "$TB_BIN" run
