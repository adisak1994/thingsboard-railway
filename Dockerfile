FROM openjdk:17-jdk-slim

RUN apt-get update && apt-get install -y wget ca-certificates curl gnupg  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG TB_VERSION=4.2.1
RUN set -eux;     wget -O /tmp/thingsboard.deb https://sourceforge.net/projects/thingsboard.mirror/files/v$TB_VERSION/thingsboard-$TB_VERSION.deb/download;     apt-get update;     apt-get install -y /tmp/thingsboard.deb;     rm -f /tmp/thingsboard.deb;     rm -rf /var/lib/apt/lists/*

ENV DATABASE_ENTITIES_TYPE=sql     DATABASE_TS_TYPE=sql     TB_QUEUE_TYPE=in-memory     JAVA_OPTS="-Xms256M -Xmx768M"     SERVER_PORT=8080

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=10 \
  CMD bash -lc 'curl -fsS http://127.0.0.1:${PORT:-8080}/api/health || exit 1'

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["run"]
