json.type 'FeatureCollection'
json.features @paths do |path|
  json.type 'Feature'
  json.geometry do
    json.type 'LineString'
    json.coordinates path.ordered_points.map{|p| [p.lng,p.lat] }
  end
  json.id path.id.to_s
  json.properties do
    json.point_ids path.point_ids.map{|x|x.to_s}.join(',')
  end
end