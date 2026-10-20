# ParaBank — local app under test

Local [ParaBank](https://github.com/parasoft/parabank) (Parasoft's deliberately vulnerable demo bank) for functional and performance testing.
See [docs/testing-strategy.md](docs/testing-strategy.md) for the functional and performance testing approach.

## Start / stop

```bash
make up        # start; seeds a fresh DB via parabank-init (resets data)
make stop      # stop containers, KEEP data
make start     # resume after 'make stop', data kept
make smoke     # non-destructive check of UI, REST, SOAP, admin
make reset     # reset DB to seed data (run before each test run)
make restart   # restart the app and re-seed the DB
make down      # stop and REMOVE containers (data is lost)
make           # list all targets
```

> A fresh container has an **empty** database. `parabank-init` seeds it on `up`.
> Data lives in the container (`WEB-INF/db/`), so it survives `stop`/`start` but not `down`.
> Avoid a bare `docker compose start` or `make up` after `stop`: both re-run the seeder and reset the DB.
> A plain `docker restart parabank` does not re-seed it; use `make restart`, or run `make reset` afterwards.

## Endpoints

| What | URL |
|---|---|
| Web UI | http://localhost:8080/parabank/index.htm |
| Admin (DB init/clean, data access mode, loan provider) | http://localhost:8080/parabank/admin.htm |
| REST API base | http://localhost:8080/parabank/services/bank |
| REST docs (Swagger) | http://localhost:8080/parabank/api-docs/index.html |
| SOAP WSDL | http://localhost:8080/parabank/services/ParaBank?wsdl |
| HSQLDB | `localhost:9001` |
| ActiveMQ (JMS) | `localhost:61616` |

**Default user:** `john` / `demo` (customer id `12212`).

```bash
curl -H 'Accept: application/json' http://localhost:8080/parabank/services/bank/login/john/demo
```

## Notes for testing

- The container is limited to 4 CPUs / 4 GB (`docker-compose.yml`) so performance baselines are comparable between runs. Change both together and record the values with your results.
- The image is pinned by digest. To upgrade, run `docker pull parasoft/parabank:latest` and update the digest.
- Without a session, `index.htm` redirects to `initializeDB.htm`, which **resets the DB**. Keep that in mind for load scripts and monitors that hit the home page without cookies.


## Local App Under Test Credentials 
### ParaBank - UI
UI_BASE_URL=http://localhost:8080/parabank/
UI_USERNAME=john
UI_PASSWORD=demo

### ParaBank - API
API_BASE_URL=http://localhost:8080/parabank/services/bank
