use('bike-sharing');
const stationId = "S1";
const t1 = ISODate("2025-08-04T10:00:00Z");
const t2 = ISODate("2025-08-04T10:20:00Z");
db.metrics_ts.find(
  { "meta.id": stationId, "meta.metric_name": "available_bikes", ts: { $gte: t1, $lte: t2 } },
  { _id: 0, ts: 1, value: 1 }
).sort({ ts: 1 });
