json.id @path.id.to_s
json.name @path.name
json.description @path.description
if @path.detail_id
  json.detail_id @path.detail.id.to_s
  json.surface_id @path.detail.surface.id.to_s
  json.type_id @path.detail.surface.type.id.to_s
end