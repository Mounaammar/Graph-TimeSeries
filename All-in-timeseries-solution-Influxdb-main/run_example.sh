#!/usr/bin/env bash
set -euo pipefail

# Run the InfluxDB bike-sharing demo:
# - starts the InfluxDB container
# - writes demo graph + time-series data
# - issues the sample Flux query over HTTP

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -f ".env" ]; then
  echo "Loading InfluxDB config from .env..."
  set -a; source .env; set +a
else
  echo "Loading InfluxDB config from .env.example (copy to .env to customize)..."
  set -a; source .env.example; set +a
fi

echo "Starting InfluxDB Docker stack (if not already running)..."
docker compose up -d

echo "Waiting for InfluxDB to become healthy on http://localhost:8086..."
max_retries=30
for i in $(seq 1 "$max_retries"); do
  if curl -sSf "http://localhost:8086/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [ "${ready:-0}" != "1" ]; then
  echo "InfluxDB did not become ready in time."
  exit 1
fi

echo "Writing demo line-protocol data..."
bash scripts/write_data.sh

echo "Running sample Flux query from queries/low_neighbors_at_t.flux..."
curl -sS \
  --request POST \
  "http://localhost:8086/api/v2/query?org=${DOCKER_INFLUXDB_INIT_ORG}" \
  --header "Authorization: Token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}" \
  --header "Accept: application/csv" \
  --header "Content-Type: application/vnd.flux" \
  --data-binary @queries/low_neighbors_at_t.flux

echo
echo "Done. CSV output for low-neighbor stations is shown above."