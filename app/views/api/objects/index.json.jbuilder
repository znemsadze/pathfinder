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
        json.coordinates t.points.map{ |p| [p.lng,p.lat] }
      elsif t.is_a?(Objects::Path::Line)
        json.type 'LineString'
        json.coordinates t.point_ids.map{ |pid| p = @pathpoints[pid.to_s] ; [ p[1], p[0] ] }
      end
    end
    json.id t.id.to_s
    json.properties do
      json.class t.class.name
      json.name t.name
      json.description t.description if t.respond_to?(:description)
      if t.region_id.present?
        region = @regions.present? ? @regions[t.region_id.to_s] : t.region
        json.region region.name
      end
      json.direction t.direction if t.respond_to?(:direction)
      json.category t.category if t.respond_to?(:category)
      json.address t.address if t.respond_to?(:address)
      json.linename t.linename if t.respond_to?(:linename)
      if t.respond_to? :northing
        json.northing t.northing
        json.easting t.easting
      end
      # if t.respond_to?(:has_images?) and t.has_images?
      #   json.images do
      #     json.thumbnails { json.array! t.thumbnails }
      #     json.larges { json.array! t.larges }
      #   end
      # end
      if t.respond_to?(:detail) and t.detail_id
        det = @details.present? ? @details[ t.detail_id.to_s ] : t.detail
        json.detail do
          json.detail  det.name
          json.surface det.surface.name
          json.type    det.surface.type.name
        end
      end
    end
  end
end
