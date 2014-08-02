json.type 'FeatureCollection'
json.features do
  json.array! @objects do |t|
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
      json.linename t.linename if t.respond_to?(:linename)
      if t.respond_to? :northing
        json.northing t.northing
        json.easting t.easting
      end
      if t.respond_to?(:has_images?) and t.has_images?
        json.images do
          json.thumbnails { json.array! t.thumbnails }
          json.larges { json.array! t.larges }
        end
      end
      if t.respond_to?(:detail) and t.detail
        json.detail do
          json.detail  t.detail.name
          json.surface t.detail.surface.name
          json.type    t.detail.surface.type.name
        end
      end
    end
  end
end