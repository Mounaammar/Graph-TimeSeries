#!/usr/bin/env bash
set -euo pipefail

# Stop all Graph-TimeSeries demo containers for this repo.
# This will:
# - run `docker compose down` in each compose-based project
# - stop and remove the standalone MariaDB containers (mcs1, mariadb_graph)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

compose_projects=(
  "All-in-document-solution-mongodb-main"
  "All-in-MM-E-Posrtgres-main"
  "All-in-timeseries-solution-Influxdb-main"
  "All-in-MM-native-solution-ArcadeDB-main"
  "All-in-Relational-solution-MariaDB-main"
)

echo "Stopping compose-based demo stacks (if running)..."
for proj in "${compose_projects[@]}"; do
  if [ -f "$proj/docker-compose.yml" ] || [ -f "$proj/docker-compose.yaml" ]; then
    echo "- $proj: docker compose down"
    (cd "$proj" && docker compose down || true)
  fi
done

echo
echo "Stopping standalone MariaDB demo containers (if present)..."
for name in mcs1 mariadb_graph; do
  if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
    echo "- Stopping $name..."
    docker stop "$name" >/dev/null 2>&1 || true
    echo "- Removing $name..."
    docker rm "$name" >/dev/null 2>&1 || true
  else
    echo "- $name: not found (skipping)"
  fi
done

echo
echo "All demo containers stopped (remaining volumes are left intact)."