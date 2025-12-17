#!/usr/bin/env bash
set -euo pipefail

# Run the MongoDB bike-sharing demo end to end:
# - starts the Docker stack
# - seeds sample graph + time-series data
# - runs the example hybrid query

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Starting MongoDB Docker stack (if not already running)..."
docker compose up -d

echo "Waiting for MongoDB to accept connections..."
max_retries=30
for i in $(seq 1 "$max_retries"); do
  if docker compose exec -T mongo mongosh "mongodb://admin:1234@localhost:27017/admin" --quiet --eval "db.runCommand({ ping: 1 })" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [ "${ready:-0}" != "1" ]; then
  echo "MongoDB did not become ready in time."
  exit 1
fi

echo "Seeding demo data into MongoDB..."
docker compose exec -T mongo bash -lc 'cd /work && mongosh "mongodb://admin:1234@localhost:27017/admin" scripts/data_upload.js'

echo "Running sample queries..."
docker compose exec -T mongo bash -lc 'cd /work/queries && mongosh "mongodb://admin:1234@localhost:27017/admin" run_samples.js'

echo
echo "Done. You should see the hybrid query output above."