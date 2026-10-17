#!/usr/bin/env bash
# Reset ParaBank's database to its default seed data (known state for test runs).
set -euo pipefail
BASE_URL="${PARABANK_URL:-http://localhost:8080/parabank}"

curl -fsS -X POST "$BASE_URL/services/bank/cleanDB" >/dev/null
curl -fsS -X POST "$BASE_URL/services/bank/initializeDB" >/dev/null
echo "ParaBank DB reset at $BASE_URL"
