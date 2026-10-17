# ParaBank Testing Strategy

Using [ParaBank](https://github.com/parasoft/parabank) by Parasoft as an Application Under Test (AUT) is an excellent way to practice or demonstrate software testing. The public demo site is shared globally and other testers disrupt it often, so your first step should always be to deploy it in your own local or isolated environment. [[1]][forum] [[2]][gh] [[3]][soatest]

---

## 🚀 1. Local Deployment & Setup

Running ParaBank locally keeps your performance metrics free of network latency and server rate limits. [[1]][forum]

### The quickest method: Docker

Pull and start the official image:

```bash
docker run -d -p 8080:8080 parasoft/parabank
```

Once it's running, the application is available at <http://localhost:8080/parabank>. [[1]][forum] [[2]][soatest]

> **In this project:** use `make up` instead. It runs the pinned image through `docker-compose.yml` and seeds the database, which starts **empty** in a fresh container. See the [README](../README.md).

### Default seed account (for script onboarding)

| Field | Value |
|---|---|
| Username | `john` |
| Password | `demo` |

[[1]][script]

---

## 🛠️ 2. Functional Testing Strategy

ParaBank has a complete web UI alongside fully accessible SOAP and REST API backends. [[1]][gh] [[2]][docsbot]

### UI automation (Selenium, Playwright, Cypress)

- **Core flows to target:** focus on end-to-end (E2E) transactions such as User Registration, Account Overview, Fund Transfers and Loan Request Approvals. [[1]][scribd]
- **State management tip:** automated UI tests corrupt data over time. ParaBank's Administration Page (`/admin.htm`) has database **Initialize** and **Clean** buttons. Trigger them from your test setup or teardown code (`@BeforeMethod` / `beforeEach`), through an API call or a UI click, so every test run starts from a clean slate. [[1]][admin] [[2]][forum] [[3]][docsbot]

> **In this project:** `make reset` (or `scripts/reset-db.sh`) does this through the REST endpoints `POST /services/bank/cleanDB` and `POST /services/bank/initializeDB`.
> Note: opening `index.htm` without a session cookie redirects to `initializeDB.htm`, which also resets the DB.

### API testing (Postman, REST Assured)

You can skip the UI and test the raw endpoints directly. The endpoints and API schemas are available here: [[1]][docsbot] [[2]][services]

| Resource | URL |
|---|---|
| Services directory (WSDLs + OpenAPI link) | <http://localhost:8080/parabank/services.htm> |
| Swagger / OpenAPI UI | <http://localhost:8080/parabank/api-docs/index.html> |
| SOAP WSDL | <http://localhost:8080/parabank/services/ParaBank?wsdl> |
| REST base | <http://localhost:8080/parabank/services/bank> |

---

## 📈 3. Performance & Load Testing Strategy

ParaBank is excellent for practicing non-functional testing. Because it uses a lightweight internal HyperSQL (HSQLDB) database, it bottlenecks quickly under realistic stress, which makes it a good target for finding architectural breaking points. [[1]][devto] [[2]][gh]

### Tooling & setup (JMeter, Gatling, k6)

- **Record your script:** use the JMeter HTTP(S) Script Recorder or the k6 browser extension to capture a user logging in, checking their balance, transferring $100 and logging out. [[1]][script]
- **Dynamic correlation (crucial):** ParaBank relies heavily on session IDs (`JSESSIONID`). Your performance scripts must capture session cookies dynamically with correlation extractors (e.g. RegEx or JSONPath post-processors). Otherwise your virtual users will get unauthorized (403) or session-timeout errors.

### Graduated load testing profiles

Structure your performance test scripts into three distinct profiles:

| Test type | Objective | Load strategy |
|---|---|---|
| **Smoke / Baseline** | Verify script accuracy and capture baseline response times. | 1–5 virtual users (VUs) for 2–5 minutes. |
| **Load Test** | Assess how the app performs under the expected standard volume. | 20–50 concurrent VUs, ramped up over 10 minutes. |
| **Stress / Break Test** | Push the app until the local database or Tomcat server fails. | Ramp up quickly to 100+ VUs until error rates spike. |

> **In this project:** the container is capped at 4 CPUs / 4 GB (`docker-compose.yml`), so results are comparable between runs. Record these limits with your results.

---

## 💡 Core Automation Testing Checklist

- [ ] **Local sandbox:** deployed via Docker to eliminate network variability.
- [ ] **Data isolation:** reset the database through `/admin.htm` (or `make reset`) before each test suite runs.
- [ ] **Correlation configured:** dynamic tokens and cookies are captured in performance tools so concurrent sessions stay intact.

[[1]][soatest] [[2]][docsbot] [[3]][admin]

---

## References

1. [Parasoft Forum: Unable to login to ParaBank using valid username and password][forum]
2. [GitHub: parasoft/parabank][gh]
3. [Parasoft Blog: Continuous Integration with Parasoft SOAtest][soatest]
4. [OnTestAutomation: script.pdf][script]
5. [DocsBot: ParaBank Requirements Specification][docsbot]
6. [Scribd: ParaBank Test Plan][scribd]
7. [ParaBank Admin Page (public demo)][admin]
8. [ParaBank Services (public demo)][services]
9. [DEV Community: Building a Test Strategy from the Ground Up, the ParaBank Example][devto]

[forum]: https://forums.parasoft.com/discussion/5661/unable-to-login-to-parabank-using-valid-username-and-password
[gh]: https://github.com/parasoft/parabank
[soatest]: https://www.parasoft.com/blog/continuous-integration-with-parasoft-soatest/
[script]: https://www.ontestautomation.com/assets/script.pdf
[docsbot]: https://docsbot.ai/prompts/business/parabank-requirements-specification
[scribd]: https://www.scribd.com/document/1048118089/ParaBank-TestPlan
[admin]: https://parabank.parasoft.com/parabank/admin.htm
[services]: https://parabank.parasoft.com/parabank/services.htm
[devto]: https://dev.to/baskotapradip/building-a-test-strategy-from-the-ground-up-the-parabank-example-1h00
