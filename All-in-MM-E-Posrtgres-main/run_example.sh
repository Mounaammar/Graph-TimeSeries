#!/usr/bin/env bash
set -euo pipefail

# Run the Postgres (Apache AGE + TimescaleDB) bike-sharing demo end to end.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Starting Postgres (AGE + TimescaleDB) Docker stack (if not already running)..."
docker compose up -d --build

echo "Waiting for Postgres to accept connections on container 'pg-mmdb'..."
max_retries=30
for i in $(seq 1 "$max_retries"); do
  if docker exec pg-mmdb pg_isready -U postgres -d mmdb >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [ "${ready:-0}" != "1" ]; then
  echo "Postgres did not become ready in time."
  exit 1
fi

# Seed schema + data only if missing (to keep the script idempotent)
echo "Ensuring demo schema and data are loaded..."
if ! docker exec pg-mmdb psql -U postgres -d mmdb -Atqc "SELECT to_regclass('public.available_bikes')" | grep -q 'public.available_bikes'; then
  echo "  - Loading seed schema and data from data/data.sql..."
  docker exec -i pg-mmdb psql -U postgres -d mmdb < data/data.sql
else
  echo "  - Seed data already present, skipping data/data.sql"
fi

echo "Running hybrid query from query.sql..."
{
  echo "LOAD 'age';"
  echo 'SET search_path = ag_catalog, "$user", public;';
  cat query.sql
} | docker exec -i pg-mmdb psql -U postgres -d mmdb

echo
echo "Done. You should see the hybrid query result above."