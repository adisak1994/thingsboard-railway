#!/usr/bin/env bash
set -euo pipefail

TB_DIR="/usr/share/thingsboard"
TB_BIN_DIR="$TB_DIR/bin"
TB_JAR="$TB_BIN_DIR/thingsboard.jar"
TB_INSTALL_SH="$TB_BIN_DIR/install/install.sh"
CONF_DIR="$TB_DIR/conf"
LOG_DIR="$TB_DIR/logs"

echo "[TB] Checking installation layout..."
ls -la "$TB_DIR" || true
ls -la "$TB_BIN_DIR" || true

# --- pick port from Railway ---
PORT="${PORT:-}"
if [ -z "$PORT" ]; then
  # บางโปรเจกต์ Railway ไม่ฉีด PORT — ให้ลองอ่านจาก .env/variables เอง
  # ถ้าไม่มีจริงๆ ให้ล้มเหลวเพื่อบอกปัญหาชัดเจน (ดีกว่ารันที่ 8080 แล้วเข้าไม่ได้)
  echo "[ERROR] PORT env is empty. Railway Web services must listen on the injected \$PORT."
  echo "Tips: Service type must be Web; do NOT hardcode port in Variables."
  exit 64
fi
echo "[TB] Starting ThingsBoard on port ${PORT} via java -jar"

exec java $JAVA_OPTS \
  -Dserver.address=0.0.0.0 \
  -Dserver.port="${PORT}" \
  -Dspring.config.additional-location="/usr/share/thingsboard/conf/" \
  -Dlogging.config="/usr/share/thingsboard/conf/logback.xml" \
  -jar "/usr/share/thingsboard/bin/thingsboard.jar"



if [ ! -f "$TB_JAR" ]; then
  echo "[ERROR] ThingsBoard JAR not found at $TB_JAR"
  exit 127
fi

mkdir -p /data "$LOG_DIR"

auto_map_db_envs() {
  if [ -n "${SPRING_DATASOURCE_URL:-}" ] && [ -n "${SPRING_DATASOURCE_USERNAME:-}" ] && [ -n "${SPRING_DATASOURCE_PASSWORD:-}" ]; then
    echo "[TB] SPRING_* provided explicitly."
    return 0
  fi

  if [ -n "${RAILWAY_PRIVATE_DOMAIN:-}" ] && [ -n "${PGPORT:-}" ] && [ -n "${PGDATABASE:-}" ] && [ -n "${PGUSER:-}" ] && [ -n "${PGPASSWORD:-}" ]; then
    export SPRING_DATASOURCE_URL="jdbc:postgresql://${RAILWAY_PRIVATE_DOMAIN}:${PGPORT}/${PGDATABASE}?sslmode=disable"
    export SPRING_DATASOURCE_USERNAME="${PGUSER}"
    export SPRING_DATASOURCE_PASSWORD="${PGPASSWORD}"
    echo "[TB] Derived SPRING_* from Railway PRIVATE endpoint."
    return 0
  fi

  if [ -n "${RAILWAY_TCP_PROXY_DOMAIN:-}" ] && [ -n "${PGPORT:-}" ] && [ -n "${PGDATABASE:-}" ] && [ -n "${PGUSER:-}" ] && [ -n "${PGPASSWORD:-}" ]; then
    export SPRING_DATASOURCE_URL="jdbc:postgresql://${RAILWAY_TCP_PROXY_DOMAIN}:${PGPORT}/${PGDATABASE}?sslmode=require"
    export SPRING_DATASOURCE_USERNAME="${PGUSER}"
    export SPRING_DATASOURCE_PASSWORD="${PGPASSWORD}"
    echo "[TB] Derived SPRING_* from Railway PUBLIC endpoint."
    return 0
  fi

  if [ -n "${DATABASE_URL:-}" ]; then
    proto="$(printf "%s" "$DATABASE_URL" | awk -F:// '{print $1}')"
    if [ "$proto" = "postgres" ] || [ "$proto" = "postgresql" ]; then
      rest="${DATABASE_URL#*://}"
      auth_host_db="${rest%%\?*}"
      params="${rest#*\?}"
      if [ "$params" = "$rest" ]; then params=""; fi
      userpass="${auth_host_db%@*}"
      hostdb="${auth_host_db#*@}"
      user="${userpass%%:*}"
      pass="${userpass#*:}"
      hostport="${hostdb%%/*}"
      db="${hostdb#*/}"
      if [ -z "$params" ]; then
        params="sslmode=require"
      fi
      export SPRING_DATASOURCE_URL="jdbc:postgresql://${hostport}/${db}?${params}"
      export SPRING_DATASOURCE_USERNAME="${user}"
      export SPRING_DATASOURCE_PASSWORD="${pass}"
      echo "[TB] Derived SPRING_* from DATABASE_URL."
      return 0
    fi
  fi

  echo "[TB] Could not auto-derive DB settings. You must set SPRING_DATASOURCE_URL, _USERNAME, _PASSWORD."
  return 1
}

auto_map_db_envs || {
  echo "[TB] Current env overview (masked):"
  echo "  RAILWAY_PRIVATE_DOMAIN=${RAILWAY_PRIVATE_DOMAIN:-<none>}  PGPORT=${PGPORT:-<none>}  PGDATABASE=${PGDATABASE:-<none>}"
  echo "  PGUSER=${PGUSER:-<none>}  PGPASSWORD=<masked>"
  echo "  RAILWAY_TCP_PROXY_DOMAIN=${RAILWAY_TCP_PROXY_DOMAIN:-<none>}  DATABASE_URL=${DATABASE_URL:-<none>}"
  exit 2
}

if [ "${TB_INSTALL:-}" = "true" ] && [ ! -f "/data/.tb_installed" ]; then
  echo "[TB] Running initial DB install..."
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
  touch /data/.tb_installed
  echo "[TB] Install complete."
fi

if [ "${1:-}" = "run" ]; then
  echo "[TB] Starting ThingsBoard via java -jar"
  exec java $JAVA_OPTS     -Dspring.config.additional-location="$CONF_DIR/"     -Dlogging.config="$CONF_DIR/logback.xml"     -jar "$TB_JAR"
fi

exec "$@"
