json.type 'FeatureCollection'
json.features do
  json.array! @towers+@lines do |t|
    json.type 'Feature'
    json.geometry do
      if t.is_a?(Objects::Tower)
        json.type 'Point'
        json.coordinates [t.lng,t.lat]
      elsif t.is_a?(Objects::Line)
        json.type 'LineString'
        json.coordinates t.points.map{|p| [p.lng,p.lat] }
      end
    end
    json.id t.id.to_s
    json.properties do
      json.class t.class.name
    end
  end
end