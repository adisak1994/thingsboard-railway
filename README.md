# ThingsBoard on Railway – Starter Repo (TB 4.2.1)

Deploy ThingsBoard CE using the official `.deb` inside a Docker image on Railway.
This skips Maven build and uses Railway PostgreSQL.

## Railway Postgres SSL tip
If your install crashes during DB init, set:
`SPRING_DATASOURCE_URL=jdbc:postgresql://HOST:PORT/DB?sslmode=require`

## Variables (Service: thingsboard)
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `TB_QUEUE_TYPE=in-memory`
- `JAVA_OPTS=-Xms256M -Xmx512M`
- `TB_INSTALL=true` (first deploy only)

Login: `tenant@thingsboard.org` / `tenant`
