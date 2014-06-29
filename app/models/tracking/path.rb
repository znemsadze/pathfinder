# -*- encoding : utf-8 -*-
class Tracking::Path
  DISTANCE = 100 # meters
  INTERVAL = 300 # sec

  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user, class_name: 'Sys::User'
  has_many :points, class_name: 'Tracking::Point'

  def self.add_point(user, lat, lng)
    path = Tracking::Path.get_path(user, lat, lng) || Tracking::Path.create(user: user)
    point=Tracking::Point.new(path: path)
    point.lat = lat ; point.lng = lng
    point.save
  end

  def self.get_path(user, lat, lng)
    path = Tracking::Path.where(user: user).last
    return nil if path.blank?

    last_point = path.points.last
    return path if last_point.blank?

    return path if (Time.now - last_point.created_at < INTERVAL)

    a1 = Geokit::LatLng.new(last_point.lat, last_point.lng)
    a2 = Geokit::LatLng.new(lat, lng)
    distance = a1.distance_to(a2)
    return path if distance < DISTANCE

    return nil
  end
end
