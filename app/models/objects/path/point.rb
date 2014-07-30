# -*- encoding : utf-8 -*-
class Objects::Path::Point
  include Mongoid::Document
  include Objects::Coordinate
  field :edge, type: Mongoid::Boolean, default: false
  field :pathline_ids, type: Array, default:[]
  index(egde: 1)
end
