# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  field :point_ids, type: Array, default:[]

  def self.new_path(points)
    if points.uniq.size>1
      path=Geo::Path.create(point_ids: [])
      points.each do |p|
        if p.is_a?(Geo::Point)
          point=p
        else
          if p.is_a?(Hash) then lat,lng=p['lat'],p['lng']
          else lat,lng=p[0],p[1] end
          point=Geo::Point.where(lat: lat,lng: lng).first || Geo::Point.new(lat: lat,lng: lng, path_ids: [])
        end
        point.path_ids.push(path.id)
        path.point_ids.push(point.id)
        point.save
      end
      path.point_ids=path.point_ids.uniq
      path.save
      path
    end
  end

  def points; Geo::Point.in(id:self.point_ids) end

  def edge?(p)
    id=p.is_a?(Point) ? p.id : p
    point_ids.first==id or point_ids.last==id
  end

  def splitjoin
    self.point_ids.each do |point_id|
      point=Geo::Point.find(point_id)
      route_count=point.route_count
      if point.path_count>1
        if route_count==2
          joinat(point)
        else
          # TODO:
        end
      end
    end
  end

  private

  def joinat(point)
    # assume route_count == 2
    path1=self
    path2=Geo::Path.find(point.path_ids.select{|x|x.id!=self.id}.first)
    edge1=path1.edge?(point)
    edge2=path2.edge?(point)

    if edge2 # second path's edge
      addtoend=true
      if not edge1
        new_points=[point]
      else
        idx=path2.point_ids.index(point.id)
        if idx==0
          new_points=path2.points
        else
          new_points=path2.points.reverse
        end
      end
    else # we are in the middle of the secon path
      addtoend=false
      points2=path2.points
      idx=path2.point_ids.index(point.id)
      if points2[idx-1].path_ids.contains?(path1.id)
        new_points=points2[0..idx]
      else
        new_points=points2[idx..-1].reverse
      end
    end

    new_points.each do |point|
      point.path_ids.delete(path2.id)
      point.path_ids.push(path1.id) unless point.path_ids.include?(path1.id)
      point.save
      path2.point_ids.delete(point.id)
      path2.save
    end

    path2.destroy unless path2.point_ids.any?

    if addtoend
      path1.point_ids=(path1.point_ids+new_points).uniq
    else
      path1.point_ids=(new_points+path1.point_ids).uniq
    end
    path1.save
  end
end
