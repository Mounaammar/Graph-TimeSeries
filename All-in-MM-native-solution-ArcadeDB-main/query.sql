LET $max_ts = SELECT max(ts) AS t FROM Metric
              WHERE ts <= DATE('2025-08-04 10:20:00', 'yyyy-MM-dd HH:mm:ss');
LET $low = SELECT stationId FROM Metric
           WHERE ts = $max_ts[0].t
             AND value <= 3;
             
SELECT name AS low_neighbors ,
         set(in('TRIP').name) AS src   
FROM Station
where id IN $low.stationId
