WITH g AS ( 
  SELECT
  * 
  FROM ag_catalog.cypher('bike_graph', $$  
    MATCH (s:Station)-[:TRIP]->(n:Station)
    RETURN s.id AS s_id, s.name AS s_name, n.id AS n_id, n.name AS n_name
  $$) AS (s_id agtype, s_name agtype, n_id agtype, n_name agtype)
)
SELECT
  g.s_name AS src,
  array_agg(g.n_name ORDER BY g.n_name) 
FROM g
WHERE g.n_id=( WITH last_values AS (
  SELECT DISTINCT ON (station_id) station_id, ts, value
  FROM available_bikes
  WHERE ts <= TIMESTAMPTZ '2025-08-04 10:20:00Z'
  ORDER BY station_id, ts DESC
)
SELECT station_id
FROM last_values
WHERE value <= 3
ORDER BY station_id)
GROUP BY g.s_id, g.s_name ORDER BY g.s_id; 
