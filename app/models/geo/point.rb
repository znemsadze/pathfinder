# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  field :lat, type: Float
  field :lng, type: Float
  field :single, type: Boolean, default: true
  has_and_belongs_to_many :paths, class_name:'Geo::Path'
  # validates :lat, presence: {message: 'ჩაწერეთ განედი'}
  # validates :lng, presence: {message: 'ჩაწერეთ გრძედი'}

  def distance_to(p); Geo::Point.distance(self,p) end

  # @see http://stackoverflow.com/questions/12966638/rails-how-to-calculate-the-distance-of-two-gps-coordinates-without-having-to-u
  def self.distance(p1,p2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlon_rad = (p2.lng-p1.lng) * rad_per_deg  # Delta, converted to rad
    dlat_rad = (p2.lat-p1.lat) * rad_per_deg

    lat1_rad = p1.lat * rad_per_deg
    lon1_rad = p1.lng * rad_per_deg
    lat2_rad = p2.lat * rad_per_deg
    lon2_rad = p2.lng * rad_per_deg

    x = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin(Math.sqrt(x))

    rm * c # Delta in meters
  end
end