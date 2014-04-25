# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  has_and_belongs_to_many :points, class_name: 'Geo::Point'
end
