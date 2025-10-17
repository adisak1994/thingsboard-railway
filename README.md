# ThingsBoard on Railway – Starter (runs JAR directly)

This repo installs ThingsBoard CE (4.2.1) from the official `.deb` and runs it
via `java -jar` because some builds don't ship the `bin/thingsboard` launcher script.

## Railway setup
- Add a PostgreSQL service.
- In the ThingsBoard service Variables:
  - `SPRING_DATASOURCE_URL=jdbc:postgresql://HOST:PORT/DB?sslmode=require`
  - `SPRING_DATASOURCE_USERNAME=USER`
  - `SPRING_DATASOURCE_PASSWORD=PASS`
  - `TB_QUEUE_TYPE=in-memory`
  - `JAVA_OPTS=-Xms256M -Xmx768M`
  - `TB_INSTALL=true` (first deploy only)

After first successful deploy, remove or set `TB_INSTALL=false` and redeploy.

Login: `tenant@thingsboard.org` / `tenant`
