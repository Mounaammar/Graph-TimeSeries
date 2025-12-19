# Graph-TimeSeries Demo Suite

A collection of small “graph + time-series” demos using the same bike-sharing scenario across multiple data platforms. Each folder is self-contained; start the stack, load the seed data, and run the sample hybrid query.

## Projects at a Glance

| Project folder | Graph engine | Time-series engine | How to start | Sample query | Notes |
| --- | --- | --- | --- | --- | --- |
| `All-in-document-solution-mongodb-main` | MongoDB (docs) | MongoDB (docs) | `docker compose up -d` then run `scripts/data_upload.js` and `queries/run_samples.js` | `queries/low_neighbors_at_t.mongo.js` | Uses `mongosh`; data volume at `./data` |
| `All-in-MM-E-Posrtgres-main` | Apache AGE | TimescaleDB | `docker compose up -d --build` then `psql` (`pg-mmdb` on port 5433) | `query.sql` | Postgres 16; load `age` + set `search_path` per README |
| `All-in-MM-native-solution-ArcadeDB-main` | ArcadeDB | ArcadeDB (embedded TS) | `docker compose up -d` then `./run_example.sh` | `query.sql` | Stores graph + metrics in ArcadeDB; experimental, simple station listing query |
| `All-in-polyglot-TimeTravelDB-main` | Neo4j (via TTDB) | TimescaleDB (via TTDB) | `./run_example.sh` then follow printed TTQL steps | Query in README | Polyglot prototype; relies on external repo & Go toolchain |
| `All-in-Relational-solution-MariaDB-main` | MariaDB + OQGRAPH | MariaDB ColumnStore | `docker compose up -d` then `./run_example.sh` | `query` (shell + SQL pipeline) | Hybrid query exports neighbors then filters TS |
| `All-in-timeseries-solution-Influxdb-main` | Influx measurement tags for graph | InfluxDB 2.x | `docker compose up -d` then `./scripts/write_data.sh` | `queries/low_neighbors_at_t.flux` | Needs `DOCKER_INFLUXDB_INIT_*` env vars |

## Quick Usage Pattern

1. `cd` into a project folder.
2. Start services (usually `docker compose up -d`).
3. Load seed data (script or SQL noted in the project README).
4. Run the provided hybrid query.

## One-liner Run Scripts

For a fully scripted path, each project folder exposes a `run_example.sh` helper:

- `All-in-document-solution-mongodb-main/run_example.sh` — starts MongoDB in Docker, seeds data, runs the sample query.
- `All-in-MM-E-Posrtgres-main/run_example.sh` — starts Postgres (AGE + Timescale), loads schema/data if needed, runs `query.sql`.
- `All-in-Relational-solution-MariaDB-main/run_example.sh` — starts MariaDB + ColumnStore, installs OQGRAPH (first run), loads data, runs `query`.
- `All-in-timeseries-solution-Influxdb-main/run_example.sh` — starts InfluxDB, writes LP data, and POSTs `queries/low_neighbors_at_t.flux`.
- `All-in-polyglot-TimeTravelDB-main/run_example.sh` — clones the external TTDB repo (if needed), copies `data/graph_template.yaml`, starts its Neo4j + TimescaleDB Docker stack, and prints TTQL CLI steps.
- `All-in-MM-native-solution-ArcadeDB-main/run_example.sh` — starts ArcadeDB, creates a `bike_sharing` graph DB, seeds schema + data, and runs `query.sql` (currently a simple `SELECT FROM Station` demo; full hybrid query is experimental).

Usage:

```bash
cd <project-folder>
./run_example.sh       # or: bash run_example.sh
```

## Stopping All Demo Containers

To shut down all demo stacks and the standalone MariaDB containers in one go:

```bash
cd Graph-TimeSeries
./stop_all.sh
```

This stops containers but leaves any local Docker volumes intact so you can re-run the examples quickly.

## Data & Artifacts Hygiene

- Seed inputs live under each project’s `data/` folder; avoid committing generated DB files or dumps.  
- Local volumes are ignored via `.gitignore`; if you need to keep a dump, place it outside the repo or document it explicitly.

## Smoke Tests (lightweight)

- MongoDB: after `docker compose up -d`, run `scripts/data_upload.js`, then `queries/run_samples.js`; expect neighbor output without errors.
- Postgres AGE + Timescale: start compose, `psql` to port 5433, `LOAD 'age'; SET search_path...;` run `query.sql`; expect station rows.
- MariaDB ColumnStore + OQGRAPH: start both containers (per README), load `data/create_data_graph.sql` and `data/create_data_ts.sql`, then run `query`; expect grouped neighbor names.
- InfluxDB: start compose with required env vars, run `./scripts/write_data.sh`, paste `queries/low_neighbors_at_t.flux` into UI; expect station results.
- TTDB / ArcadeDB: manual/prototype; follow their docs; no automated smoke included here.
