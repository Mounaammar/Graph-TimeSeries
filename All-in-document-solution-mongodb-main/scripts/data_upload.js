// Seed schema, indexes, and sample data
const bikes = db.getSiblingDB("bike_sharing");

// collections
if (!bikes.getCollectionNames().includes("nodes")) bikes.createCollection("nodes");
if (!bikes.getCollectionNames().includes("edges")) bikes.createCollection("edges");
if (!bikes.getCollectionNames().includes("metrics_ts")) {
  bikes.createCollection("metrics_ts", {
    timeseries: { timeField: "ts", metaField: "meta", granularity: "minutes" }
  });
}

// reset (demo)
bikes.nodes.deleteMany({});
bikes.edges.deleteMany({});
bikes.metrics_ts.deleteMany({ "meta.metric_name": "available_bikes" });

// nodes
bikes.nodes.insertMany([
  { _id: "1", label: "Station", name: "Central Park", capacity: 12 },
  { _id: "2", label: "Station", name: "Riverside",    capacity: 10 },
  { _id: "3", label: "Station", name: "Museum",       capacity: 8  },
]);

// edges
bikes.edges.insertMany([
  { _id:"12", src:"1", dst:"2", label:"Trip", member_type:"member",  bike_type:"classic",  user_id:"u001", ts: ISODate("2025-08-04T10:03:00Z") },
  { _id:"13", src:"1", dst:"2", label:"Trip", member_type:"casual",  bike_type:"electric", user_id:"u006", ts: ISODate("2025-08-04T10:05:00Z") },
  { _id:"14", src:"1", dst:"3", label:"Trip", member_type:"casual",  bike_type:"electric", user_id:"u002", ts: ISODate("2025-08-04T10:07:10Z") },
  { _id:"15", src:"2", dst:"1", label:"Trip", member_type:"member",  bike_type:"classic",  user_id:"u003", ts: ISODate("2025-08-04T10:06:00Z") },
  { _id:"16", src:"2", dst:"3", label:"Trip", member_type:"member",  bike_type:"electric", user_id:"u004", ts: ISODate("2025-08-04T10:12:00Z") },
  { _id:"17", src:"3", dst:"1", label:"Trip", member_type:"casual",  bike_type:"classic",  user_id:"u005", ts: ISODate("2025-08-04T10:15:00Z") },
]);

// time-series metrics
bikes.metrics_ts.insertMany([
  { ts: ISODate("2025-08-04T10:00:00Z"), meta:{ id:"1", metric_name:"available_bikes" }, value: 3 },
  { ts: ISODate("2025-08-04T10:10:00Z"), meta:{ id:"1", metric_name:"available_bikes" }, value: 5 },
  { ts: ISODate("2025-08-04T10:20:00Z"), meta:{ id:"1", metric_name:"available_bikes" }, value: 6 },
  { ts: ISODate("2025-08-04T10:00:00Z"), meta:{ id:"2", metric_name:"available_bikes" }, value: 6 },
  { ts: ISODate("2025-08-04T10:10:00Z"), meta:{ id:"2", metric_name:"available_bikes" }, value: 4 },
  { ts: ISODate("2025-08-04T10:20:00Z"), meta:{ id:"2", metric_name:"available_bikes" }, value: 3 },
  { ts: ISODate("2025-08-04T10:00:00Z"), meta:{ id:"3", metric_name:"available_bikes" }, value: 4 },
  { ts: ISODate("2025-08-04T10:10:00Z"), meta:{ id:"3", metric_name:"available_bikes" }, value: 4 },
  { ts: ISODate("2025-08-04T10:20:00Z"), meta:{ id:"3", metric_name:"available_bikes" }, value: 5 },
]);

