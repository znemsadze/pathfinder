# -*- encoding : utf-8 -*-
class Objects::Path::Point
  include Mongoid::Document
  include Objects::Coordinate
  field :edge, type: Mongoid::Boolean, default: false
  has_and_belongs_to_many :pathlines, class_name: 'Objects::Path::Line'
  index(egde: 1)
end
