# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  field :lat, type: Float
  field :lng, type: Float
  field :path_ids, type: Array

  def path_count; self.path_ids.size end
  def route_count; self.neighbours.size end

  def neighbours
    points=[]
    self.path_ids.each do |path_id|
      path=Geo::Path.find(path_id)
      idx=path.point_ids.index(self.id)
      points<<path.point_ids[idx-1] if (idx>0)
      points<<path.point_ids[idx+1] if (idx<path.point_ids.size-1)
    end
    points.uniq
  end
end
