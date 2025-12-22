# All-in-MM-native-solution-ArcadeDB
We want to store a whole Hygraph instance in ArcadeDB using its model to store both structural and temporal data
1/ To connect to ArcadeDB cloud version and add data using the 
2/ query : 
~~~~sql
SELECT n as dest FROM (select OUT('trip').id AS n
FROM station UNWIND n) WHERE n IN (
SELECT stationId FROM   `Metrics`
WHERE  VALUE <= 3
AND  ts <= date('2025-08-04 10:20:00','yyyy-MM-dd HH:mm:ss') ORDER BY ts DESC LIMIT 1)
~~~~
