# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  has_and_belongs_to_many :points, class_name: 'Geo::Point'
  field :startid, type: Moped::BSON::ObjectId
  field :endid, type: Moped::BSON::ObjectId
  field :length, type: Float

  def sync_route
    self.startid=points.first.id
    self.endid=points.last.id
    self.length=self.calculateLength
    self.save
  end

  def calculateLength
    prev=self.points.first; dist=0
    points.each{|p| dist+=prev.distance_to(p) if prev!=p }; dist
  end
end
