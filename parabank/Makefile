# ParaBank - local app under test
PARABANK_URL ?= http://localhost:8080/parabank
COMPOSE      ?= docker compose

.DEFAULT_GOAL := help
.PHONY: help up down stop start restart reset status logs smoke shell clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

up: ## Start ParaBank and seed a fresh DB (resets data; waits until healthy)
	$(COMPOSE) up -d --wait
	@echo "ParaBank ready at $(PARABANK_URL)/index.htm (john / demo)"

down: ## Stop and REMOVE containers (data is lost)
	$(COMPOSE) down

stop: ## Stop containers, keep data (resume with 'make start')
	$(COMPOSE) stop

# Start only 'parabank': starting the exited parabank-init seeder would reset the DB.
start: ## Start stopped containers, keeping data (no re-seed)
	$(COMPOSE) start parabank
	@until [ "$$(docker inspect -f '{{.State.Health.Status}}' parabank)" = healthy ]; do sleep 2; done
	@echo "ParaBank ready at $(PARABANK_URL)/index.htm (data kept)"

restart: ## Restart ParaBank and re-seed the DB
	$(COMPOSE) restart parabank
	@until [ "$$(docker inspect -f '{{.State.Health.Status}}' parabank)" = healthy ]; do sleep 2; done
	@$(MAKE) --no-print-directory reset

reset: ## Reset the DB to its default seed data
	@PARABANK_URL=$(PARABANK_URL) scripts/reset-db.sh

status: ## Show container status
	$(COMPOSE) ps -a

logs: ## Follow ParaBank logs
	$(COMPOSE) logs -f parabank

smoke: ## Quick check (non-destructive): UI, REST login, SOAP WSDL, admin page
	@set -e; \
	for p in about.htm admin.htm 'services/ParaBank?wsdl'; do \
	  code=$$(curl -s -o /dev/null -w '%{http_code}' "$(PARABANK_URL)/$$p"); \
	  [ "$$code" = 200 ] || { echo "FAIL $$p -> $$code"; exit 1; }; echo "ok   $$p"; \
	done; \
	curl -fsS -H 'Accept: application/json' "$(PARABANK_URL)/services/bank/login/john/demo" | grep -q '"id":12212' \
	  || { echo "FAIL REST login john/demo"; exit 1; }; echo "ok   REST login john/demo"

shell: ## Open a shell inside the ParaBank container
	docker exec -it parabank bash

clean: ## Remove containers, network and the pulled images
	$(COMPOSE) down --rmi all
