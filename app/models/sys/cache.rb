module Sys::Cache
  PATHPOINTS = 'pathpoints'
  MAPOBJECTS = 'mapobjects'
  PHOTOS = 'photos'
  EDGEPOINTS='edgepoints'
  ALLPOINTS='allpoints'
  PATHLINES='pathlines'
  PATHLINESSMALL='pathlinessmall'
  PATHCOLORS='pathcolors'

  MAPJSON='mapjson'


  def pathpoints
    pathpoints = Rails.cache.read(PATHPOINTS)
    if pathpoints.blank?
      pathpoints = Hash[ Objects::Path::Point.all.to_a.map{ |x| [ x.id.to_s, [x.lat,x.lng] ] } ]
      Rails.cache.write(PATHPOINTS, pathpoints)
    end
    return pathpoints
  end

  def pathlines
    pathlines = Rails.cache.read(PATHLINES)
    if pathlines.blank?
      pathlines = Hash[ Objects::Path::Line.all.to_a.map{ |x| [ x.id, x ] } ]
      Rails.cache.write(PATHLINES, pathlines)
    end
    return pathlines
  end

  def pathlinessmall
    pathlinessmall = Rails.cache.read(PATHLINESSMALL)
    if pathlinessmall.blank?
      pathlinessmall = Hash[ Objects::Path::Line.all.to_a.map{ |x| [ x.id, [x.point_ids, x.length] ] } ]
      Rails.cache.write(PATHLINESSMALL, pathlinessmall)
    end
    return pathlinessmall
  end

  def edgepoints
    edgepoints = Rails.cache.read(EDGEPOINTS)
    if edgepoints.blank?
      edgepoints = Hash[ Objects::Path::Point.where(edge:true).to_a.map{ |x| [ x.id, x ] } ]
      Rails.cache.write(EDGEPOINTS, edgepoints)
    end
    return edgepoints
  end

  def allpoints
    allpoints = Rails.cache.read(ALLPOINTS)
    if allpoints.blank?
      allpoints = Hash[ Objects::Path::Point.all.to_a.map{ |x| [ x.id, x ] } ]
      Rails.cache.write(ALLPOINTS, allpoints)
    end
    return allpoints
  end

def pathColors
  pathColors = Rails.cache.read(PATHCOLORS)
  if pathColors.blank?
    pathColors = {"გრუნტი"=>"#ffbf00","ასფალტი"=>"#3333ff","ძირითადი"=>"#ff3399","ბეტონი"=>"#a38f8f","unknown"=>"#b94646"}
    Rails.cache.write(PATHCOLORS, pathColors)
  end
  return pathColors

end


  def photos
    photos = Rails.cache.read(PHOTOS)
    if photos.blank?
      photos = Hash[ Objects::Photo.all.to_a.map{ |x| [ x.id.to_s, [ x.thumbnail_url, x.large_url ] ] } ]
      Rails.cache.write(PHOTOS, photos)
    end
    return photos
  end

  def map_objects
    json = Rails.cache.read(MAPOBJECTS)
    if json.blank?
      objects = Objects::Office.all + Objects::Tower.all + Objects::Substation.all + Objects::Line.all + Objects::Path::Line.all
      pathpoints = Sys::Cache.pathpoints
      edgepoints=Sys::Cache.edgepoints
      photos = Sys::Cache.photos
      regions = Hash[ Region.all.to_a.map{ |x| [ x.id.to_s, x ] } ]
      details = Hash[ Objects::Path::Detail.all.to_a.map{ |x| [ x.id.to_s, x ] } ]
      json = Objects::GeoJson.geo_json(objects, { regions: regions, details: details, pathpoints: pathpoints, photos: photos })
      Rails.cache.write(MAPOBJECTS, json)

    end
    return json
  end

  def clear_map_objects
    Rails.cache.delete(PATHPOINTS)
    Rails.cache.delete(PATHLINES)
    Rails.cache.delete(MAPOBJECTS)
    Rails.cache.delete(PHOTOS)
  end

  def add_object(object)
    json = map_objects
    json[:features].push(object.geo_json)
    Rails.cache.write(MAPOBJECTS, json)
  end

  def remove_object(object)
    json = map_objects
    features = json[:features]
    id = object.respond_to?(:id) ? object.id.to_s : object.to_s
    filtered = features.select{|x| x[:id] == id }
    features.delete(filtered.first) if filtered.any?
    Rails.cache.write(MAPOBJECTS, json)
  end

  def replace_object(object)
    remove_object(object)
    add_object(object)
  end

  module_function :pathpoints
  module_function :map_objects
  module_function :clear_map_objects
  module_function :add_object
  module_function :remove_object
  module_function :replace_object
  module_function :photos
  module_function :edgepoints
  module_function :allpoints
  module_function :pathlines
  module_function :pathlinessmall
  module_function :pathColors


end

