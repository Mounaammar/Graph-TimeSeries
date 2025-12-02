# TTDB Bikesharing (polyglot demo)

This mini-repo reproduces a **polyglot** query on the TimeTravelDB (TTDB) research prototype:
- Graph topology in **Neo4j** (stations + trips)
- Time series in **TimescaleDB** (available_bikes)
- One **TTQL** query that returns stations having at least one neighbor with low availability at time *t*.

---
## Code source link 
- Clone the project under this link: https://git.informatik.uni-leipzig.de/ek41rali/time-travel-db-v-2
- Launch Docker and a terminal in this folder and follow the steps described in the project link.
---
## Data generation
- Replace the file in the cloned project in data-generator/graph_template.yaml with the one in this repository under "data/graph_template.yaml"
- In TTQL, run GD then LD
## Query
Run the following query : 
``` sql
FROM 2023-01-01T01:00:00+01:00 TO 2023-01-01T01:00:00+01:00 MATCH (s:Station)-[:Trip]->(n:Station) WHERE ANY(n.ts_available_bikes) < 3 RETURN s;
```
