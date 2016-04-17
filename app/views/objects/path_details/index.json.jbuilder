json.array! @details do |detail|
  json.id detail.id.to_s
  json.name detail.name
  json.coefficient detail.coefficient
  json.surface_id detail.surface_id.to_s
end