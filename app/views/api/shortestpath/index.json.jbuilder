json.array! @responses do |response|
  json.array! response do |point|
    json.id  point.id
    json.lat point.lat
    json.lng point.lng
  end
end