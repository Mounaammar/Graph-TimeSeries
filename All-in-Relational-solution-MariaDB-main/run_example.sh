#!/usr/bin/env bash
set -euo pipefail

# Run the MariaDB ColumnStore + OQGRAPH bike-sharing demo:
# - starts two MariaDB containers via docker compose (graph + time-series)
# - installs the OQGRAPH plugin in the graph container (first run only)
# - loads demo schema and data
# - runs the hybrid neighbor query from the 'query' script

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Ensuring there are no leftover demo containers named 'mcs1' or 'mariadb_graph'..."
for name in mcs1 mariadb_graph; do
  if docker ps -a --format '{{.Names}}' | grep -q "^${name}\$"; then
    echo "  - Removing existing container ${name} to avoid conflicts with docker compose..."
    docker rm -f "${name}" >/dev/null 2>&1 || true
  fi
done

echo "Starting MariaDB ColumnStore + OQGRAPH Docker stack (if not already running)..."
docker compose up -d

echo "Waiting for MariaDB servers to be ready..."
max_retries=60
for i in $(seq 1 "$max_retries"); do
  if docker exec mariadb_graph mariadb -uroot -proot -e "SELECT 1" >/dev/null 2>&1 \
     && docker exec mcs1 mariadb -uroot -e "SELECT 1" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [ "${ready:-0}" != "1" ]; then
  echo "MariaDB containers did not become ready in time."
  exit 1
fi

echo "Ensuring OQGRAPH plugin is installed (this may take a while on first run)..."
docker exec -i mariadb_graph bash -lc '
set -e
if [ ! -f /root/.oqgraph_installed ]; then
  apt-get update
  apt-get install -y curl gnupg
  curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version="11.1"
  apt-get update
  apt-get install -y mariadb-plugin-oqgraph libjudydebian1
  mariadb -uroot -proot -e "INSTALL SONAME '\''ha_oqgraph'\'';"
  mariadb -uroot -proot -e "SELECT ENGINE,SUPPORT FROM information_schema.ENGINES WHERE ENGINE='\''OQGRAPH'\'';"
  touch /root/.oqgraph_installed
else
  echo "OQGRAPH already installed; skipping plugin setup."
fi
'

echo "Loading graph schema and demo data into 'mariadb_graph'..."
docker exec -i mariadb_graph mariadb -uroot -proot < data/create_data_graph.sql

echo "Loading time-series schema and demo data into 'mcs1'..."
docker exec -i mcs1 mariadb -uroot < data/create_data_ts.sql

echo "Running hybrid graph + time-series query from 'query'..."
bash query

echo
echo "Done. You should see the hybrid neighbor results above."