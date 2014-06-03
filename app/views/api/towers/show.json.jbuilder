json.id @tower.id.to_s
json.name @tower.name
json.region_id @tower.region.id.to_s if @tower.region
json.category @tower.category