json.array! @regions do |region|
  json.id region.id.to_s
  json.name region.name
end