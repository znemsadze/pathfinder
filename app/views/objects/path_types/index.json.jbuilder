json.array! @types do |type|
  json.id type.id.to_s
  json.name type.name
end