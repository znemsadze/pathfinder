# -*- encoding : utf-8 -*-
module Objects::Coordinate
  KMLNS='http://www.opengis.net/kml/2.2'

  def self.included(base)
    base.field :lng, type: Float
    base.field :lat, type: Float
    base.field :alt, type: Float
  end

  def set_coordinate(text)
    coords=text.split(',').map{|x| x.strip.to_f}
    self.lng=coords[0] ; self.lat=coords[1] ; self.alt=coords[2]
  end

  def coordinates; "#{self.lat} x #{self.lng}" end
end
