# All-in-MM-native-solution-ArcadeDB
We want to store a whole Hygraph instance in ArcadeDB using its model to store both structural and temporal data
### Graph 
* `Station` (vertex type): `id : LONG`, `name : STRING`,
  `capacity : INTEGER`.
* `TRIP` (edge type): connects two `Station` vertices.

### Time series
 `Metric` is a plain `DOCUMENT TYPE` with
  properties `stationId : LONG`, `ts : DATETIME`, `value : LONG` 

## Cross-model query

> For each station `S`, list the outgoing `TRIP` neighbours of `S`
> whose latest time-series reading at or before
> `2025-08-04T10:20:00` is at most 3

## Steps to run

Prerequisite: Docker.

```bash
./run_example.sh
```

To stop and clean up:

```bash
docker compose down -v
```

## Studio

Once the container is up, the ArcadeDB Studio UI is reachable at
<http://localhost:2480>. Log in with `root / graphTSroot`.
