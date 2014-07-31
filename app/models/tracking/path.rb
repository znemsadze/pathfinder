# -*- encoding : utf-8 -*-
class Tracking::Path
  DISTANCE = 100 # meters
  INTERVAL = 300 # sec
  MAX_INTERVAL = 60*60 # sec

  include Mongoid::Document
  include Mongoid::Timestamps
  include Kml
  belongs_to :user, class_name: 'Sys::User'
  belongs_to :task, class_name: 'Task'
  has_many :points, class_name: 'Tracking::Point'
  field :open, type: Mongoid::Boolean, default: true

  def self.add_point(user, lat, lng)
    path = Tracking::Path.get_path(user, lat, lng)
    if path.blank?
      Tracking::Path.where(user: user, open: true).update_all(open: false)
      path = Tracking::Path.create(user: user, task: user.current_task)
    end
    path.touch; path.save
    point=Tracking::Point.new(path: path)
    point.lat = lat ; point.lng = lng
    point.save
  end

  def self.open_tracks; Tracking::Path.where(open: true) end

  def self.get_path(user, lat, lng)
    path = Tracking::Path.where(user: user, open: true).last
    return nil if path.blank?

    last_point = path.points.last
    return path if last_point.blank?

    return path if (Time.now - last_point.created_at < INTERVAL)
    return nil if (Time.now - last_point.created_at > MAX_INTERVAL)

    a1 = Geokit::LatLng.new(last_point.lat, last_point.lng)
    a2 = Geokit::LatLng.new(lat, lng)
    distance = a1.distance_to(a2)
    return path if distance < DISTANCE

    return nil
  end

  def self.close_paths(user); Tracking::Path.where(user: user, open: true).update_all(open: false) end

  def to_kml(xml = nil)
    if xml then placemark(xml)
    else kml_document { |xml| placemark(xml) } end
  end

  def short; "#{self.user.username} - #{self.created_at.localtime.strftime('%Y%m%d')}" end
  def description; "ტრეკი: #{self.created_at.localtime.strftime('%d-%b-%Y %H:%M:%S')} / #{self.updated_at.localtime.strftime('%d-%b-%Y %H:%M:%S')}" end

  private

  def placemark(xml)
    xml.Placemark(id: "ID_#{self.id.to_s}") do |xml|
      xml.name self.short
      xml.Snippet
      xml.description self.description
      xml.MultiGeometry do |xml|
        xml.LineString do
          xml.extrude 0
          xml.altitudeMode 'clampedToGround'
          xml.coordinates ' ' + self.points.map{|p| [p.lng, p.lat, p.alt||0].join(',')}.join(' ')
        end
      end
    end
  end
end
