# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  has_many :points, class_name: 'Geo::Point'
end
