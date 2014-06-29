# -*- encoding : utf-8 -*-
class Tracking::Point
  include Mongoid::Document
  include Mongoid::Timestamps
  include Objects::Coordinate
  belongs_to :path, class_name: 'Tracking::Path'
end
