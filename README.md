# ThingsBoard on Railway – Auto-env Starter (TB 4.2.1)

Auto-detects Railway Postgres env vars and maps them to Spring datasource if you
didn't set SPRING_* yourself.

Order:
1) Private (no egress): RAILWAY_PRIVATE_DOMAIN + PG* → sslmode=disable
2) Public: RAILWAY_TCP_PROXY_DOMAIN + PG* → sslmode=require
3) DATABASE_URL (postgres://...) → converted to JDBC

First deploy: set `TB_INSTALL=true` to create schema, then remove/false and redeploy.
Login: `tenant@thingsboard.org / tenant`
