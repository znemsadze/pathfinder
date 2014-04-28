# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  field :lat, type: Float
  field :lng, type: Float
  field :single, type: Boolean, default: true
  has_and_belongs_to_many :paths, class_name:'Geo::Path'
end