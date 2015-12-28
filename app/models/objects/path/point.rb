# -*- encoding : utf-8 -*-
class Objects::Path::Point
  include Mongoid::Document
  include Objects::Coordinate
  include Mongoid::Timestamps
  field :edge, type: Mongoid::Boolean, default: false
  field :pathline_ids, type: Array, default:[]
  index(egde: 1)

  # graph caching in A* requires this...
  def ==(another_point); self.id == another_point.id end
  def hash
    self.id.hash # XOR
  end
end
