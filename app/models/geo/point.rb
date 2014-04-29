# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  field :lat, type: Float
  field :lng, type: Float
  has_and_belongs_to_many :paths, class_name:'Geo::Path'

  def single?; self.paths.count<2 end
end