-- Extensions
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS age;

LOAD 'age';
SET search_path = ag_catalog, "$user", public;


-- --------Hypertable for time series--------

CREATE TABLE public.available_bikes(
  station_id BIGINT NOT NULL REFERENCES public.stations(id),
  ts         TIMESTAMPTZ NOT NULL,
  value      INT NOT NULL
);

SELECT create_hypertable('public.available_bikes','ts', if_not_exists => TRUE);

--  ------time series--------
INSERT INTO public.available_bikes(station_id, ts, value) VALUES
  (1,'2025-08-04T10:00:00Z',3),(1,'2025-08-04T10:10:00Z',5),(1,'2025-08-04T10:20:00Z',6),
  (2,'2025-08-04T10:00:00Z',6),(2,'2025-08-04T10:10:00Z',4),(2,'2025-08-04T10:20:00Z',3),
  (3,'2025-08-04T10:00:00Z',4),(3,'2025-08-04T10:10:00Z',4),(3,'2025-08-04T10:20:00Z',5);

CREATE INDEX ON public.available_bikes (station_id, ts DESC);

-- -------- AGE graph --------
SELECT * FROM ag_catalog.create_graph('bike_graph');

-- Nodes: Stations
SELECT * FROM cypher('bike_graph', $$
  CREATE (:Station {id: 1,name:'Central Park',capacity:12}),(:Station{id:2,name:'Riverside',capacity:10}),(:Station{id:3, name:'Museum',capacity:8})
$$) AS (v agtype);

-- -----------Edges: Trips ----------------
SELECT * FROM cypher('bike_graph', $$ MATCH (a:Station {id:1}),(b:Station {id:2}) CREATE (a)-[:TRIP]->(b) $$) AS (r agtype);
SELECT * FROM cypher('bike_graph', $$ MATCH (a:Station {id:1}),(b:Station {id:3}) CREATE (a)-[:TRIP]->(b) $$) AS (r agtype);
SELECT * FROM cypher('bike_graph', $$ MATCH (a:Station {id:2}),(b:Station {id:1}) CREATE (a)-[:TRIP]->(b) $$) AS (r agtype);
SELECT * FROM cypher('bike_graph', $$ MATCH (a:Station {id:2}),(b:Station {id:3}) CREATE (a)-[:TRIP]->(b) $$) AS (r agtype);
SELECT * FROM cypher('bike_graph', $$ MATCH (a:Station {id:3}),(b:Station {id:1}) CREATE (a)-[:TRIP]->(b) $$) AS (r agtype);
