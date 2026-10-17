# Apps for testing

This folder holds applications under test (AUTs) for practising functional, API and performance testing. Each app has its own folder and **is deployed locally with Docker**, and `make` targets wrap the Docker commands. A local copy keeps your test data and timings separate from the shared public demos. Other testers disrupt those demos, and they must never be load-tested.

## Prerequisites

- Docker with Compose v2 (`docker compose`)
- `make`
- `curl` (used by the `smoke` targets)

## Apps

| App | What it is | Interfaces | Main URL | Login | Docs |
|---|---|---|---|---|---|
| [ParaBank](parabank/) | Parasoft's demo bank, deliberately vulnerable | Web UI, REST, SOAP, HSQLDB, ActiveMQ (JMS) | http://localhost:8080/parabank/index.htm | `john` / `demo` | [README](parabank/README.md), [testing strategy](parabank/docs/testing-strategy.md) |
| [Restful Booker Platform](restful-booker-platform/) | B&B booking system: Next.js UI + 6 Spring Boot microservices | Web UI, admin panel, REST (per service + UI proxy) | http://localhost:3003 | admin: `admin` / `password` | [README](restful-booker-platform/README.md), [API.md](restful-booker-platform/API.md), [assessment](restful-booker-platform/rbp-aut-assessment.md) |

## Quick start

```bash
cd parabank                # or: cd restful-booker-platform
make up                    # pull images, start, wait until healthy
make smoke                 # non-destructive check that everything answers
make                       # list all targets
make down                  # stop and remove containers
```

## Common make targets

Both apps provide these targets. Each app's README lists its extras (for example, RBP's `pause`, `unpause` and `docs`).

| Target | What it does |
|---|---|
| `make up` | Start the app and wait until healthy |
| `make down` | Stop and remove containers |
| `make stop` / `make start` | Stop / start containers (see data notes below) |
| `make restart` / `make reset` | Reset data to the seed state |
| `make status` | Show container status |
| `make logs` | Follow logs |
| `make smoke` | Quick non-destructive health check |
| `make shell` | Open a shell in a container |
| `make clean` | Remove containers, network and pulled images |

## Data persistence differs between apps

| App | Data kept across | Data reset by |
|---|---|---|
| ParaBank | `stop` / `start` | `up`, `restart`, `reset`, `down` |
| Restful Booker Platform | `pause` / `unpause` only (in-memory H2) | `stop`, `restart`, `reset`, `down` |

Run `make reset` before each test run to start from known seed data.

## Ports

| App | Host ports |
|---|---|
| ParaBank | 8080 (web/REST/SOAP), 9001 (HSQLDB), 61616 (ActiveMQ) |
| Restful Booker Platform | 3000–3002, 3004–3006 (APIs), 3003 (web UI, set by `RBP_WEB_PORT` in `.env`) |

The port ranges don't overlap, so both apps can run at the same time.

## Folder layout

```
apps-for-testing/
├── parabank/
│   ├── docker-compose.yml
│   ├── Makefile
│   ├── README.md
│   ├── docs/testing-strategy.md
│   └── scripts/reset-db.sh
└── restful-booker-platform/
    ├── docker-compose.yml
    ├── .env
    ├── Makefile
    ├── README.md
    ├── API.md
    └── rbp-aut-assessment.md
```

## Adding another app

Give each new app its own folder containing:

- a `docker-compose.yml`, with images pinned by tag or digest where possible
- a `Makefile` with at least `help`, `up`, `down` and `smoke`
- a `README.md` covering URLs, credentials and data lifetime

Then add a row to the [Apps](#apps) and [Ports](#ports) tables above.
