
# Bike Sharing — MongoDB Test Kit (Graph + Time Series)
Quick start:

  docker compose up -d 
  
  docker compose exec mongo mongosh "mongodb://admin:1234@localhost:27017/admin" /scripts/data_upload.js
  
  docker compose exec mongo mongosh "mongodb://admin:1234@localhost:27017/admin" /queries/run_samples.js

