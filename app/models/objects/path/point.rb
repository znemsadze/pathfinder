# -*- encoding : utf-8 -*-
class Objects::Path::Point
  include Mongoid::Document
  include Objects::Coordinate
  belongs_to :pathline, class_name: 'Objects::Path::Line'
end
