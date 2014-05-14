json.array! @surfaces do |surface|
  json.id surface.id.to_s
  json.name surface.name
  json.type_id surface.type_id.to_s
end