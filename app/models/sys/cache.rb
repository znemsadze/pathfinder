module Sys::Cache
  PATHPOINTS = 'pathpoints'
  MAPOBJECTS = 'mapobjects'

  def self.pathpoints
    pathpoints = Rails.cache.read(PATHPOINTS)
    if pathpoints.blank?
      pathpoints = Hash[ Objects::Path::Point.all.to_a.map{ |x| [ x.id.to_s, [x.lat,x.lng] ] } ]
      Rails.cache.write(PATHPOINTS, pathpoints)
    end
    return pathpoints
  end

  def self.map_objects
    json = Rails.cache.read(MAPOBJECTS)
    if json.blank?
      objects = Objects::Office.all + Objects::Tower.all + Objects::Substation.all + Objects::Line.all + Objects::Path::Line.all
      pathpoints = Sys::Cache.pathpoints
      regions = Hash[ Region.all.to_a.map{ |x| [ x.id.to_s, x ] } ]
      details = Hash[ Objects::Path::Detail.all.to_a.map{ |x| [ x.id.to_s, x ] } ]
      json = Objects::GeoJson.geo_json(objects, { regions: regions, details: details, pathpoints: pathpoints })
      Rails.cache.write(MAPOBJECTS, json)
    end
    return json
  end

  def self.clear_map_objects
    Rails.cache.delete(PATHPOINTS)
    Rails.cache.delete(MAPOBJECTS)
  end

  def replace

end
