# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  field :point_ids, type: Array, default:[]
  def points; Geo::Point.in(id:self.point_ids) end

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
end
