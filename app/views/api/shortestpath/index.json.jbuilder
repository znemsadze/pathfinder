json.array! @responses do |response|
  json.length response[:length]
  json.lineName response[:line_name]
  json.surfaceName response[:surface_name]
  json.pathcolor  response[:path_color]
  json.points do
    json.array! response[:points] do |point|
      #json.id  point[0]
      json.lat point[0]
      json.lng point[1]
    end
  end
end