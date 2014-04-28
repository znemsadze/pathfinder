# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  field :startid, type: Moped::BSON::ObjectId
  field :endid, type: Moped::BSON::ObjectId
  field :length, type: Float, default: 0
  has_and_belongs_to_many :points, class_name: 'Geo::Point'

  def ordered_points; self.point_ids.map{|x|self.points.find(x)} end

  # def sync_route
  #   self.startid=points.first.id
  #   self.endid=points.last.id
  #   self.length=self.calculateLength
  #   self.save
  # end
end
