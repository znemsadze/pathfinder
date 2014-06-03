json.type 'FeatureCollection'
json.features do
  json.array! @all do |t|
    json.type 'Feature'
    json.geometry do
      if t.is_a?(Objects::Tower)
        json.type 'Point'
        json.coordinates [t.lng,t.lat]
      elsif t.is_a?(Objects::Office)
        json.type 'Point'
        json.coordinates [t.lng,t.lat]
      elsif t.is_a?(Objects::Substation)
        json.type 'Point'
        json.coordinates [t.lng,t.lat]
      elsif t.is_a?(Objects::Line)
        json.type 'LineString'
        json.coordinates t.points.map{|p| [p.lng,p.lat] }
      elsif t.is_a?(Objects::Path::Line)
        json.type 'LineString'
        json.coordinates t.points.map{|p| [p.lng,p.lat] }
      end
    end
    json.id t.id.to_s
    json.properties do
      json.class t.class.name
      json.name t.name
      json.description t.description if t.respond_to?(:description)
      json.region t.region.name if t.region.present?
      json.direction t.direction if t.respond_to?(:direction)
      json.category t.category if t.respond_to?(:category)
      json.address t.address if t.respond_to?(:address)
    end
  end
end