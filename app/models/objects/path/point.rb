# -*- encoding : utf-8 -*-
class Objects::Path::Point
  include Mongoid::Document
  include Objects::Coordinate
  field :edge, type: Mongoid::Boolean, default: false
  field :pathline_ids, type: Array, default:[]
  index(egde: 1)

  # graph caching in A* requires this...
  def ==(another_point); self.id == another_point.id end
end
