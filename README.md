# ThingsBoard on Railway – Starter Repo

Deploy a production-ready ThingsBoard CE using the official `.deb` inside a Docker image on Railway.
This setup skips Maven build to avoid memory/timeouts and uses Railway PostgreSQL.

## Architecture
```
Railway Project
├── Service: PostgreSQL (plugin)
└── Service: thingsboard (this repo, Dockerfile build)
```

## Quick Start
1. **Create a new Railway project**
2. **Add PostgreSQL** (from the `+ New` button) and note: HOST, PORT, DB, USER, PASSWORD
3. **Add a new service** → Deploy from GitHub (this repo) or upload
4. Make sure Railway uses **Dockerfile** (not Nixpacks)

### Variables (Service: thingsboard)
Set these in *Variables*:
- `SPRING_DATASOURCE_URL` = `jdbc:postgresql://<HOST>:<PORT>/<DB>`
- `SPRING_DATASOURCE_USERNAME` = `<USER>`
- `SPRING_DATASOURCE_PASSWORD` = `<PASSWORD>`
- `TB_QUEUE_TYPE` = `in-memory`
- `JAVA_OPTS` = `-Xms256M -Xmx512M`
- `TB_INSTALL` = `true`  ← **first deploy only** (creates schema)

> After the first successful deploy (schema created), set `TB_INSTALL` to `false` or remove it, then redeploy.

### First Login
Visit your Railway URL:
- Username: `tenant@thingsboard.org`
- Password: `tenant`

## Notes
- **RAM**: For more devices, increase plan RAM and tune `JAVA_OPTS`
- **Data**: All persistent data is in PostgreSQL; container restarts are fine
- **Demo Data**: To load demo dashboards/devices on first install, edit `docker-entrypoint.sh` and use `--loadDemo`

## Optional: Pin a specific ThingsBoard version
Edit the `ARG TB_VERSION=3.7.0` at the top of the Dockerfile to your preferred release.
