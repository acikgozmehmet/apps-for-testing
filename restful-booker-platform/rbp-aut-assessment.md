# Restful Booker Platform — Assessment as an Application Under Test

Short version: it's a good fit for functional testing. It's also a good fit for performance testing, provided you load-test a copy running on your own machine and never the public demo.

## What it is

Restful Booker Platform (https://github.com/mwinteringham/restful-booker-platform) is a bed-and-breakfast booking system. Mark Winteringham built it for training testers. It's still maintained (last commit July 2026), and a public copy runs at **https://automationintesting.online** (the home page responded with 200 in about 0.8s).

### How it's built

- **Frontend:** Next.js 16 and React 19. It serves the guest site and an admin panel, and it forwards `/api/*` calls to the backend.
- **Backend:** 6 Spring Boot microservices in Java (JDK 26), each with its own in-memory H2 database:

| Service  | Port | Main endpoints                                                                   | Login needed     |
|----------|------|----------------------------------------------------------------------------------|------------------|
| auth     | 3004 | `POST /login`, `/validate`, `/logout`                                            | –                |
| room     | 3001 | `GET/POST /room`, `GET/PUT/DELETE /room/{id}`                                    | Changes only     |
| booking  | 3000 | `GET/POST /booking`, `GET/PUT/DELETE /booking/{id}`, `/unavailable`, `/summary`  | Mostly           |
| message  | 3006 | `GET/POST /message`, `/count`, `/{id}`, `PUT /{id}/read`                         | Mark-read and delete (reads are public) |
| branding | 3002 | `GET/PUT /branding`                                                              | Changes only     |
| report   | 3005 | `GET /report`, `/report/room/{id}`                                               | Yes              |

- **Login:** `admin` / `password`. A successful login returns a `token` cookie, and the other services check that cookie.
- **API docs:** each service ships an interactive Swagger page, for example https://automationintesting.online/api/booking/swagger-ui/index.html.
- **Data resets:** each service can wipe its database back to seed data on a timer, set by the `dbRefresh` environment variable. If the public demo uses this, your test data there won't stay put.

## For functional testing

### Strengths

- **Realistic user journeys:**
  - Guest side: browse rooms, check availability on a calendar, book, send a contact message.
  - Admin side: login, room CRUD, booking management, inbox, reports, branding.
- **Clear validation rules to test boundaries against.** For a booking:
  - first name 3–18 characters
  - last name 3–30 characters
  - phone 11–21 characters
  - a valid email
  - `roomid ≥ 1`
- **Room for every test layer:** UI tests (Playwright, Selenium, Cypress), API tests (REST Assured, Postman, Playwright's request API), contract tests between services, and tests where one step goes through the API and the next through the UI.
- **Security cases:** login-required endpoints called without a token, an expired token, or after logout.
- **Examples in the repo:** a Selenium/JUnit smoke suite using page objects (`end-to-end-tests/`), Jest component tests, and unit and integration tests for each service.

### Watch out for

- **The public demo is shared.** Other people's activity and any timed resets can change your data mid-run. Have each test create its own data, and don't assert on exact counts or IDs.
- **No CAPTCHA, which helps you.** Booking and contact forms can be fully automated.

## For performance testing

### Strengths

- **Lots of stateless read endpoints:** `GET /room`, `/branding`, `/booking/unavailable`, `/report`.
- **Write-heavy flows with contention.** Concurrent `POST /booking` calls on the same room and dates should expose double-booking or race conditions.
- **Six services, each with a published port,** so you can test the stack through the Next.js proxy or hit one service directly, and find which one is slowest.
- **Easy to run locally:** `docker compose up` brings up the whole stack. It also has a health endpoint (`/actuator/health`) you can poll during runs.

### Limits and caveats

- **Don't load-test automationintesting.online.** It's a free public service. Heavy traffic would hurt other learners, and the network between you and it would distort your results. Run it in Docker on your machine.
- **The in-memory H2 databases don't behave like production databases.** Figures you get won't predict how a real deployment performs. Treat the app as a place to practice the techniques (correlating values between requests, think time, ramp-up, keeping test data separate, spotting bottlenecks), not as a benchmark.
- **Data builds up during a soak test** unless you set `dbRefresh`. That's either a problem or useful, depending on what you want to see.
- **Suitable tools:** k6, JMeter, Gatling, Locust. Each needs to log in once, store the `token` cookie, and send it on later requests.

## Suggested next steps

1. Run the stack locally: `docker compose up -d` in the cloned repo (frontend on :3003, services on :3000–3002 and :3004–3006).
2. Set up a test project with three parts:
   - API tests (REST Assured or Playwright request)
   - UI tests (Playwright)
   - load scripts (k6)
3. Choose separate target URLs for each environment: use local Docker for performance tests and either local or the public demo for functional smoke tests.
