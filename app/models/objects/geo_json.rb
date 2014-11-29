# -*- encoding : utf-8 -*-
module Objects::GeoJson
  def self.geo_json(objects, opts = {})
    {
      type: 'FeatureCollection',
      features: objects.map{ |x| x.geo_json(opts) }
    }
  end

  def geo_json(opts = {})
    properties = {
      class: self.class.name,
      name: self.name
    }
    properties[:description] = self.description if self.respond_to?(:description)
    properties[:direction] = self.direction if self.respond_to?(:direction)
    properties[:category] = self.category if self.respond_to?(:category)
    properties[:address] = self.address if self.respond_to?(:address)
    properties[:linename] = self.linename if self.respond_to?(:linename)
    if self.respond_to?(:northing)
      properties[:northing] = self.northing
      properties[:easting] = self.easting
    end
    if self.region_id.present?
      regions = opts[:regions]
      region = regions.present? ? regions[self.region_id.to_s] : self.region
      properties[:region] = region.name
    end
    if self.respond_to?(:detail) and self.detail_id
      details = opts[:details]
      det = details.present? ? details[ self.detail_id.to_s ] : self.detail
      properties[:detail] = { detail: det.name, surface: det.surface.name, type: det.surface.type.name }
    end
    ## XXX: add this to properties !!
    # if t.respond_to?(:has_images?) and t.has_images?
    #   json.images do
    #     json.thumbnails { json.array! t.thumbnails }
    #     json.larges { json.array! t.larges }
    #   end
    # end

    {
      type: 'Feature',
      id: self.id.to_s,
      geometry: { type: self.geo_type(opts), coordinates: self.geo_coordinates(opts) },
      properties: properties
    }
  end
end
