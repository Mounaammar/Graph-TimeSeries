#!/usr/bin/env bash
set -euo pipefail

# Run the ArcadeDB native (graph + time-series-in-graph) bike-sharing demo.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

DB_NAME="bike_sharing"
ARCADE_URL="http://localhost:2480"
AUTH_ARGS=("-u" "root:graphTSroot")

echo "Starting ArcadeDB Docker stack (if not already running)..."
docker compose up -d

echo "Waiting for ArcadeDB HTTP API on ${ARCADE_URL}..."
max_retries=60
for i in $(seq 1 "$max_retries"); do
  if curl -sS "${ARCADE_URL}/api/v1/openapi.json" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [ "${ready:-0}" != "1" ]; then
  echo "ArcadeDB did not become ready in time."
  exit 1
fi

echo "Ensuring '${DB_NAME}' database exists..."
curl -sS "${AUTH_ARGS[@]}" \
  -H "Content-Type: application/json" \
  -d '{"language":"sql","command":"create database bike_sharing"}' \
  "${ARCADE_URL}/api/v1/server" >/dev/null || true

echo "Seeding demo schema and data into '${DB_NAME}'..."
SEED_SQL=$(tr '\n' ' ' < schema_and_data.sql)
curl -sS "${AUTH_ARGS[@]}" \
  -H "Content-Type: application/json" \
  -d "{\"language\":\"sqlscript\",\"command\":\"${SEED_SQL}\"}" \
  "${ARCADE_URL}/api/v1/command/${DB_NAME}" >/dev/null

echo "Running hybrid graph + time-series query from query.sql..."
QUERY_SQL=$(tr '\n' ' ' < query.sql)
RESPONSE=$(curl -sS "${AUTH_ARGS[@]}" \
  -H "Content-Type: application/json" \
  -d "{\"language\":\"sqlscript\",\"command\":\"${QUERY_SQL}\"}" \
  "${ARCADE_URL}/api/v1/command/${DB_NAME}" || true)

echo "Raw ArcadeDB response:"
if [ -n "$RESPONSE" ]; then
  echo "$RESPONSE"
else
  echo "(empty response from server)"
fi

echo
echo "Done. You should see the ArcadeDB low-neighbor query result (JSON) above."