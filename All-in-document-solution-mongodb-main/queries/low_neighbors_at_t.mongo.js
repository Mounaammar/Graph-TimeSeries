use('bike-sharing');

// Read query: Stations with a Low-Availability
Neighbor at Time t (MongoDB)

const threshold = 3;             
db.edges.aggregate([
  { $lookup: {
      from: "metrics_ts",
      let: { neighbor: "$dst", cutoff: ISODate("2025-08-04T10:20:00Z") },
      pipeline: [
        { $match: { $expr: {
            $and: [
              { $eq: ["$meta.id", "$$neighbor"] },
              { $eq: ["$meta.metric_name", "available_bikes"] },
              { $lte: ["$ts", "$$cutoff"] }
            ] } } },
        { $sort: { ts: -1 } },
        { $limit: 1 },
        { $project: { _id: 0, value: 1 } }
      ],
      as: "n"
  }},
  { $unwind: "$n" },
  { $match: { "n.value": { $lte: threshold } } },
  { $group: { _id: "$src", lowNeighbors: { $addToSet: "$dst" } } },
  { $project: { _id: 0, src: "$_id", lowNeighbors: 1 } }
])
