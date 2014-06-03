json.id @office.id.to_s
json.name @office.name
json.region_id @office.region.id.to_s if @office.region
json.description @office.description
json.address @office.address