FROM openjdk:17-jdk-slim

# ----- System deps -----
RUN apt-get update && apt-get install -y wget ca-certificates curl gnupg  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ----- Install ThingsBoard (DEB) -----
ARG TB_VERSION=4.2.1
# Use apt to install local .deb so dependencies resolve; fail fast if download breaks
RUN set -eux;     wget -O /tmp/thingsboard.deb https://sourceforge.net/projects/thingsboard.mirror/files/v$TB_VERSION/thingsboard-$TB_VERSION.deb/download;     apt-get update;     apt-get install -y /tmp/thingsboard.deb;     rm -f /tmp/thingsboard.deb;     rm -rf /var/lib/apt/lists/*

# ----- Env (can be overridden in Railway) -----
ENV DATABASE_ENTITIES_TYPE=sql     DATABASE_TS_TYPE=sql     TB_QUEUE_TYPE=in-memory     JAVA_OPTS="-Xms256M -Xmx512M"     SERVER_PORT=8080

# Expect these via Railway Variables:
# SPRING_DATASOURCE_URL=jdbc:postgresql://HOST:PORT/DB
# SPRING_DATASOURCE_USERNAME=USER
# SPRING_DATASOURCE_PASSWORD=PASS
# TB_INSTALL=true   # first deploy to init schema

# ----- Entrypoint: run initial DB install once if TB_INSTALL=true -----
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=10 CMD curl -fsS http://127.0.0.1:8080 || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/share/thingsboard/bin/thingsboard", "run"]
