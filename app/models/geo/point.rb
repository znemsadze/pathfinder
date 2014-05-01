# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  field :lat, type: Float
  field :lng, type: Float
  field :path_ids, type: Array

  #def single?; path_ids.uniq.size==1 end
end