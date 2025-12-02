# All-in-MM-E-Posrtgres
Single Postgres 16 instance with two extensions:
- **Apache AGE** for property-graph 
- **TimescaleDB** for time series data

This repo exposes a tiny example using **bike-sharing** dataset and shows an **integrated query**:
“return stations that have ≥1 neighbor whose `available_bikes ≤ threshold` at time `t`”.

## Start docker container

```bash
docker compose up -d --build
docker exec -it pg-mmdb psql -U postgres -d mmdb
````

## Execute the queries
- Inside psql, for any new session that uses AGE:

````sql
LOAD 'age';
SET search_path = ag_catalog, "$user", public;
````
- Copy and paste the query from query.sql file
- (if the data could not be loaded when creating the docker container, copy paste content of the data/data.sql file in the cli directly)
