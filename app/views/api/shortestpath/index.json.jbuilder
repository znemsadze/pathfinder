json.array! @responses do |response|
  json.length response[:length]
  json.points do
    json.array! response[:points] do |point|
      json.id  point.id
      json.lat point.lat
      json.lng point.lng
    end
  end
end