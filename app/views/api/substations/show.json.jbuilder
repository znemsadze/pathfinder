json.id @substation.id.to_s
json.name @substation.name
json.region_id @substation.region.id.to_s if @substation.region
json.description @substation.description