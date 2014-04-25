json.type 'FeatureCollection'
json.features @paths do |path|
  json.type 'Feature'
  json.geometry do
    json.type 'LineString'
    json.coordinates path.points.map{|p| [p.lng,p.lat] }
  end
end