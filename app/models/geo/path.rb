# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  field :point_ids, type: Array

  def points; Geo::Point.in(id:self.point_ids) end

  def self.new_path(points)
    if points.uniq.size>1
      path=Geo::Path.create(point_ids: [])
      points.each do |p|
        if p.is_a?(Hash) then  lat,lng=p['lat'],p['lng']
        else lat,lng=p[0],p[1] end
        point=Geo::Point.where(lat: lat,lng: lng).first || Geo::Point.new(lat: lat,lng: lng, path_ids: [])
        point.path_ids.push(path.id)
        path.point_ids.push(point.id)
        point.save
      end
      path.point_ids=path.point_ids.uniq
      path.save
      path
    end
  end

  def self.subindecies(a1,a2)
    [a1.index(a2.first), a1.index(a2.last)]
  end

  def self.join(path1,path2)
    points1=path1.point_ids
    points2=path2.point_ids
    intr=points1&points2
    size=intr.size
    if size>0
      # first path analization
      i11,i12=subindecies(points1,intr)
      if points1[i11..i12]==intr
        if i11==0 and i12!=(points1.size-1)
          points1.reverse! ; intr.reverse!
          i11,i12=subindecies(points1,intr)
        end
      else
        return
      end

      # second path analization
      i21,i22=subindecies(points2,intr)
      unless points2[i21..i22]==intr
        points2.reverse!
        i21,i22=subindecies(points2,intr)
        return unless points2[i21..i22]==intr
      else
        if i22==(points2.size-1) and i21!=0
          points2.reverse!
          i21,i22=subindecies(points2,intr)
        end
      end

      # final checking results
      has_first=(i11==0 or i21==0)
      has_last=(i12==points1.size-1 or i22==points2.size-1)
      return unless has_first and has_last

      # joining after everything checked
      new_points=(points1+points2).uniq
      new_points.each do |p|
        point=Geo::Point.find(p)
        point.path_ids.delete(path2.id)
        point.path_ids.push(path1.id) unless point.path_ids.include?(path1.id)
        point.save
      end
      path1.point_ids=new_points
      path1.save
      path2.destroy
      path1
    end
  end
end
