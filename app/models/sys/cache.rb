class Sys::Cache
  include Mongoid::Document

  field :name, type: String
  field :content, type: String
  field :content_hash, type: Hash

  index({ name: 1 }, { unique: true })

  def self.pathpoints
    cache = Sys::Cache.where(name: 'pathpoints').first
    if cache.blank?
      content_hash = Hash[ Objects::Path::Point.all.to_a.map{ |x| [ x.id.to_s, [x.lat,x.lng] ] } ]
      Sys::Cache.create(name: 'pathpoints', content_hash: content_hash)
      content_hash
    else
      cache.content_hash
    end
  end

  def self.get_map_objects
    cache = Sys::Cache.where(name: 'map-all-objects').first
    cache.content if cache
  end

  def self.set_map_objects(text)
    cache = Sys::Cache.where(name: 'map-all-objects').first || Sys::Cache.new(name: 'map-all-objects')
    cache.content = text
    cache.save
  end

  def self.clear_map_objects
    Sys::Cache.where(name: 'map-all-objects').destroy_all
    Sys::Cache.where(name: 'pathpoints').destroy_all
  end
end
