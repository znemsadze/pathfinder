# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  field :lat, type: Float
  field :lng, type: Float
  field :path_ids, type: Array
end
