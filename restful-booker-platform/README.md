# Restful Booker Platform — local AUT

Local deployment of [Restful Booker Platform](https://github.com/mwinteringham/restful-booker-platform) using the author's prebuilt Docker Hub images (`mwinteringham/restfulbookerplatform_*`). Background: [rbp-aut-assessment.md](rbp-aut-assessment.md).

## Quick start

Requires Docker with Compose v2 and `make`.

```sh
make up      # pull images on first run, start, wait until healthy
make smoke   # verify everything answers
```

Then open http://localhost:3003.

## Make targets

Run `make` (or `make help`) to list them.

| Target | What it does |
|---|---|
| `make up` | Start RBP and wait until all services are healthy |
| `make down` | Stop and remove containers |
| `make stop` / `make start` | Stop / start containers — **data is lost** (see below) |
| `make pause` / `make unpause` | Freeze / resume containers, **keeping data** |
| `make restart` / `make reset` | Restart all services, resetting data to seed |
| `make status` | Show container status |
| `make logs SVC=room` | Follow one service's logs (`booking` default; also `room`, `branding`, `auth`, `report`, `message`, `assets`) |
| `make smoke` | Non-destructive check: API health, UI pages, `/api/room`, admin login |
| `make docs` | Print Swagger UI and OpenAPI spec URLs |
| `make shell SVC=auth` | Open a shell inside a service container |
| `make clean` | Remove containers, network and pulled images |

**Data lifetime:** every service keeps its data in an in-memory H2 database. Anything that stops a service's JVM (`stop`, `restart`, `down`) brings it back with the seed data. Use `pause`/`unpause` to keep test data between sessions, and `reset` to get a clean state before a test run.

To update to newer images: `docker compose pull && make up`.

## Configuration

Settings live in `.env` (read by both Compose and the Makefile):

| Variable | Default | Meaning |
|---|---|---|
| `RBP_TAG` | `latest` | Image tag for all services (e.g. `2.2`) |
| `RBP_WEB_PORT` | `3003` | Host port for the web UI |
| `RBP_DB_REFRESH` | `0` | Auto-reset each service's data every N minutes (0 = off) |

Apply changes with `make up`.

## URLs

- Site: http://localhost:3003
- Admin: http://localhost:3003/admin (login `admin` / `password`)
- API through the UI proxy: `http://localhost:3003/api/{room,booking,branding,auth,message,report}`

Each API service is also published on its own port:

| Service | Direct base URL | Swagger UI |
|---|---|---|
| booking | http://localhost:3000/booking | http://localhost:3000/booking/swagger-ui/index.html |
| room | http://localhost:3001/room | http://localhost:3001/room/swagger-ui/index.html |
| branding | http://localhost:3002/branding | http://localhost:3002/branding/swagger-ui/index.html |
| auth | http://localhost:3004/auth | http://localhost:3004/auth/swagger-ui/index.html |
| report | http://localhost:3005/report | http://localhost:3005/report/swagger-ui/index.html |
| message | http://localhost:3006/message | http://localhost:3006/message/swagger-ui/index.html |

Health: `<direct base URL>/actuator/health`.

## Notes

- **Files:** `docker-compose.yml` (services), `.env` (settings), `Makefile` (shortcuts), [API.md](API.md) (API reference: auth rules, status codes, quirks), [rbp-aut-assessment.md](rbp-aut-assessment.md) (AUT assessment).
- **API reference:** the Swagger pages list paths only. See [API.md](API.md) for what each endpoint does, which need a token, and the status codes they really return.
- **Auth:** `POST /api/auth/login` with `{"username":"admin","password":"password"}` returns `{"token":"..."}` in the body. Send it as a cookie (`Cookie: token=<value>`) on protected calls.
- **Swagger** returns 500 when opened through the UI proxy (`/api/booking/swagger-ui/...`); use the direct ports above. The compose file overrides `SPRINGDOC_SWAGGERUI_*` because the images' prod profile points Swagger at the public demo's `/api/<svc>` paths.
- **Raw OpenAPI specs** (for Postman/codegen import): `<direct base URL>/v3/api-docs`, e.g. http://localhost:3000/booking/v3/api-docs
