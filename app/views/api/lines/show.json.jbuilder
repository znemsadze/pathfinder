json.id @line.id.to_s
json.name @line.name
json.description @line.description
json.region_id @line.region.id.to_s if @line.region