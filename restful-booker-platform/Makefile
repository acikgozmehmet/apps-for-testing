# Restful Booker Platform - local app under test
-include .env
RBP_WEB_PORT ?= 3003
RBP_URL      ?= http://localhost:$(RBP_WEB_PORT)
COMPOSE      ?= docker compose
SVC          ?= booking
APIS         := 3000/booking 3001/room 3002/branding 3004/auth 3005/report 3006/message

.DEFAULT_GOAL := help
.PHONY: help up down stop start pause unpause restart reset status logs smoke docs shell clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(firstword $(MAKEFILE_LIST)) | awk -F':.*## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

up: ## Start RBP (waits until healthy)
	$(COMPOSE) up -d --wait
	@echo "RBP ready at $(RBP_URL) (admin: $(RBP_URL)/admin, admin / password)"

down: ## Stop and REMOVE containers
	$(COMPOSE) down

# Databases are in-memory H2: stopping a container ends its JVM and loses its data.
stop: ## Stop containers (data is lost - use 'make pause' to keep it)
	$(COMPOSE) stop

start: ## Start stopped containers (fresh seed data)
	$(COMPOSE) up -d --wait
	@echo "RBP ready at $(RBP_URL) (seed data)"

pause: ## Freeze containers, keeping data in memory (resume with 'make unpause')
	$(COMPOSE) pause

unpause: ## Resume paused containers (data kept)
	$(COMPOSE) unpause
	@echo "RBP ready at $(RBP_URL) (data kept)"

restart: ## Restart all services, resetting data to seed
	$(COMPOSE) restart
	$(COMPOSE) up -d --wait
	@echo "RBP ready at $(RBP_URL) (seed data)"

reset: restart ## Reset all data to the default seed (same as restart)

status: ## Show container status
	$(COMPOSE) ps -a

logs: ## Follow logs of one service (SVC=booking|room|branding|auth|report|message|assets)
	$(COMPOSE) logs -f rbp-$(SVC)

smoke: ## Quick check (non-destructive): API health, UI pages, proxy API, admin login
	@set -e; \
	for a in $(APIS); do \
	  curl -fsS "http://localhost:$$a/actuator/health" | grep -q '"status":"UP"' \
	    || { echo "FAIL health $$a"; exit 1; }; echo "ok   health $$a"; \
	done; \
	for p in / /admin; do \
	  code=$$(curl -s -o /dev/null -w '%{http_code}' "$(RBP_URL)$$p"); \
	  [ "$$code" = 200 ] || { echo "FAIL $$p -> $$code"; exit 1; }; echo "ok   UI $$p"; \
	done; \
	curl -fsS "$(RBP_URL)/api/room" | grep -q '"roomName"' \
	  || { echo "FAIL /api/room"; exit 1; }; echo "ok   API /api/room"; \
	curl -fsS -X POST "$(RBP_URL)/api/auth/login" -H 'Content-Type: application/json' \
	  -d '{"username":"admin","password":"password"}' | grep -q '"token"' \
	  || { echo "FAIL login admin/password"; exit 1; }; echo "ok   login admin/password"

docs: ## List Swagger UI and OpenAPI spec URLs
	@for a in $(APIS); do \
	  echo "  http://localhost:$$a/swagger-ui/index.html   (spec: http://localhost:$$a/v3/api-docs)"; \
	done

shell: ## Open a shell in one service container (SVC=booking|...|assets)
	$(COMPOSE) exec rbp-$(SVC) sh

clean: ## Remove containers, network and the pulled images
	$(COMPOSE) down --rmi all
