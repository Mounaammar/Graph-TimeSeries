#!/usr/bin/env bash
set -euo pipefail

# Helper script for the TimeTravelDB (TTDB) polyglot demo.
# TTDB itself lives in an external repo; this script:
#   - ensures the TTDB repo is cloned locally
#   - wires in this project's graph_template.yaml
#   - starts the Neo4j + TimescaleDB Docker stack used by TTDB
# It does NOT drive the interactive TTQL CLI for you (GD/LD/query),
# but prints the exact next steps.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

TTDB_REPO_URL="https://git.informatik.uni-leipzig.de/ek41rali/time-travel-db-v-2"
TTDB_DIR="time-travel-db-v-2"

if [ ! -d "$TTDB_DIR" ]; then
  echo "Cloning TimeTravelDB prototype from:"
  echo "  $TTDB_REPO_URL"
  git clone "$TTDB_REPO_URL" "$TTDB_DIR"
else
  echo "Using existing TTDB clone at '$TTDB_DIR'."
fi

if [ -d "$TTDB_DIR/data-generator" ]; then
  echo "Copying demo graph template into TTDB data-generator..."
  cp data/graph_template.yaml "$TTDB_DIR/data-generator/graph_template.yaml"
else
  echo "WARNING: '$TTDB_DIR/data-generator' not found; please copy 'data/graph_template.yaml'"
  echo "into the appropriate location in the TTDB repo manually."
fi

# Ensure TimescaleDB backup for the 'restore' service exists to avoid pg_restore errors
TS_BACKUP_SRC="$TTDB_DIR/test-data/timescaledb_test_backup/postgres.bak"
TS_BACKUP_DST_DIR="$TTDB_DIR/docker-test/timescaledb/backups"
TS_BACKUP_DST="$TS_BACKUP_DST_DIR/postgres.bak"

if [ -f "$TS_BACKUP_SRC" ]; then
  mkdir -p "$TS_BACKUP_DST_DIR"
  if [ ! -f "$TS_BACKUP_DST" ]; then
    echo "Seeding TimescaleDB backup for TTDB restore service..."
    cp "$TS_BACKUP_SRC" "$TS_BACKUP_DST"
  fi
fi

echo
echo "Starting TTDB Docker environment (Neo4j + TimescaleDB)..."
( cd "$TTDB_DIR" && docker compose up -d )

echo "Waiting for Neo4j (bolt://localhost:7687) and TimescaleDB (localhost:5432)..."
max_retries=60
for i in $(seq 1 "$max_retries"); do
  neo4j_ok=0
  ts_ok=0

  if nc -z 127.0.0.1 7687 2>/dev/null; then
    neo4j_ok=1
  fi
  if nc -z 127.0.0.1 5432 2>/dev/null; then
    ts_ok=1
  fi

  if [ "$neo4j_ok" -eq 1 ] && [ "$ts_ok" -eq 1 ]; then
    ready=1
    break
  fi
  sleep 2
done

if [ "${ready:-0}" != "1" ]; then
  echo "WARNING: Docker services for TTDB did not become ready in time."
  echo "Check 'docker ps' and the logs under '$TTDB_DIR/docker-test/'."
fi

cat <<EOF

TTDB is a research prototype and its full Docker/TTQL workflow lives in the
cloned repository '$TTDB_DIR'.

Recommended next steps:
  1. cd "$TTDB_DIR"
  2. Build and start the TTDB CLI (one of):
       - go run main/main.go
       - or build the 'TTDB' binary as described in its README, then run ./TTDB
  3. In the TTQL prompt, run:
       GD        # generate data from data-generator/graph_template.yaml
       LD        # load generated data into Neo4j + TimescaleDB
  4. Then paste and run the low-neighbor TTQL query shown in this folder's README.

EOF
