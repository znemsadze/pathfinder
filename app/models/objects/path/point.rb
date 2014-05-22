# -*- encoding : utf-8 -*-
class Objects::Path::Point
  include Mongoid::Document
  field :lat, type: Float
  field :lng, type: Float
  field :path_ids, type: Array, default:[]

  def path_count; self.path_ids.size end
  def route_count; self.neighbours.size end

  def neighbours
    points=[]
    self.path_ids.each do |path_id|
      path=Objects::Path::Line.find(path_id) rescue nil
      if path
        idx=path.point_ids.index(self.id)
        points<<path.point_ids[idx-1] if (idx>0)
        points<<path.point_ids[idx+1] if (idx<path.point_ids.size-1)
      end
    end
    points.uniq
  end
end
