#!/usr/bin/env bash
set -e

MARKER="/data/.tb_installed"
mkdir -p /data

if [ "${TB_INSTALL}" = "true" ] && [ ! -f "${MARKER}" ]; then
  echo "[TB] Running initial DB install..."
  : "${SPRING_DATASOURCE_URL:?Missing SPRING_DATASOURCE_URL}"
  : "${SPRING_DATASOURCE_USERNAME:?Missing SPRING_DATASOURCE_USERNAME}"
  : "${SPRING_DATASOURCE_PASSWORD:?Missing SPRING_DATASOURCE_PASSWORD}"

  # Create DB schema (no demo by default)
  /usr/share/thingsboard/bin/install/install.sh

  # If you want demo data, comment the above and uncomment this:
  # /usr/share/thingsboard/bin/install/install.sh --loadDemo

  touch "${MARKER}"
  echo "[TB] Install complete."
fi

exec "$@"
