FROM openjdk:17-jdk-slim

# ----- System deps -----
RUN apt-get update && apt-get install -y wget gnupg ca-certificates curl      && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ----- Install ThingsBoard (DEB) -----
ARG TB_VERSION=3.7.0
RUN wget -q https://github.com/thingsboard/thingsboard/releases/download/v${TB_VERSION}/thingsboard-${TB_VERSION}.deb      && apt-get update      && dpkg -i thingsboard-${TB_VERSION}.deb || true      && apt-get -f install -y      && rm -rf /var/lib/apt/lists/* thingsboard-${TB_VERSION}.deb

# ----- Environment (override on Railway) -----
ENV DATABASE_ENTITIES_TYPE=sql         DATABASE_TS_TYPE=sql         TB_QUEUE_TYPE=in-memory         JAVA_OPTS="-Xms256M -Xmx512M"         SERVER_PORT=8080

# These should be set via Railway Variables:
# SPRING_DATASOURCE_URL=jdbc:postgresql://HOST:PORT/DB
# SPRING_DATASOURCE_USERNAME=USER
# SPRING_DATASOURCE_PASSWORD=PASS
# TB_INSTALL=true   # only for first deploy to create schema

# ----- Entrypoint: run initial DB install once if TB_INSTALL=true -----
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=10 CMD curl -fsS http://127.0.0.1:8080 || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/share/thingsboard/bin/thingsboard", "run"]
