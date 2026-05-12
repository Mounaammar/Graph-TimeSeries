-- ---------- Graph schema ----------
CREATE VERTEX TYPE Station IF NOT EXISTS;
CREATE PROPERTY Station.id IF NOT EXISTS LONG;
CREATE PROPERTY Station.name IF NOT EXISTS STRING;
CREATE PROPERTY Station.capacity IF NOT EXISTS INTEGER;
CREATE INDEX IF NOT EXISTS ON Station (id) UNIQUE;
 
CREATE EDGE TYPE TRIP IF NOT EXISTS;
-- ---------- Node data ----------
INSERT INTO Station SET id = 1, name = 'Central Park', capacity = 12;
INSERT INTO Station SET id = 2, name = 'Riverside',    capacity = 10;
INSERT INTO Station SET id = 3, name = 'Museum',       capacity = 8;
 
-- ---------- Edge data ----------
CREATE EDGE TRIP FROM (SELECT FROM Station WHERE id = 1) TO (SELECT FROM Station WHERE id = 2);
CREATE EDGE TRIP FROM (SELECT FROM Station WHERE id = 1) TO (SELECT FROM Station WHERE id = 3);
CREATE EDGE TRIP FROM (SELECT FROM Station WHERE id = 2) TO (SELECT FROM Station WHERE id = 1);
CREATE EDGE TRIP FROM (SELECT FROM Station WHERE id = 2) TO (SELECT FROM Station WHERE id = 3);
CREATE EDGE TRIP FROM (SELECT FROM Station WHERE id = 3) TO (SELECT FROM Station WHERE id = 1);
 
-- ---------- Time-series data ----------
INSERT INTO AvailableBikes (ts, station_id, value) VALUES
  ('2025-08-04T10:00:00.000Z', '1', 3),
  ('2025-08-04T10:10:00.000Z', '1', 5),
  ('2025-08-04T10:20:00.000Z', '1', 6),
  ('2025-08-04T10:00:00.000Z', '2', 6),
  ('2025-08-04T10:10:00.000Z', '2', 4),
  ('2025-08-04T10:20:00.000Z', '2', 3),
  ('2025-08-04T10:00:00.000Z', '3', 4),
  ('2025-08-04T10:10:00.000Z', '3', 4),
  ('2025-08-04T10:20:00.000Z', '3', 5);
