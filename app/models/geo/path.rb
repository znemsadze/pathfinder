# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  field :point_ids, type: Array, default:[]

  def self.new_path(points)
    if points.uniq.size>1
      path=Geo::Path.create
      points.each do |p|
        if p.is_a?(Geo::Point) then point=p
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

  def update_points(points)
    if points.uniq.size>1
      existing_points=self.points
      self.point_ids=[]
      existing_points.each{|x| x.path_ids.delete(self.id); x.save }
      points.each_with_index do |p,i|
        if p.is_a?(Hash) then lat,lng=p['lat'],p['lng']
        else lat,lng=p[0],p[1] end
        point=Geo::Point.where(lat: lat,lng: lng).first
        if point.blank? and (i==0 or i==points.length-1)
          point=(i==0 ? existing_points.first : existing_points.last)
          if self.point_ids.include?(point.id)
            point=nil
          else
            point.lat=lat ; point.lng=lng
          end
        end
        point=Geo::Point.new(lat: lat,lng: lng, path_ids: []) if point.blank?
        point.path_ids.push(self.id) unless point.path_ids.include?(self.id)
        point.save
        self.point_ids.push(point.id)
      end

      self.save
    end
  end

  def points; self.point_ids.map{|x|Geo::Point.find(x)} end

  def edge?(p)
    id=p.is_a?(Geo::Point) ? p.id : p
    point_ids.first==id or point_ids.last==id
  end

  def splitjoin
    self.point_ids.each do |point_id|
      point=Geo::Point.find(point_id)
      route_count=point.route_count
      if point.path_count>1
        if route_count<=2
          joinat(point)
        else
          splitat(point)
        end
      end
    end
  end

  private

  def joinat(point)
    # assume route_count == 2
    path1=self
    path2=Geo::Path.find(point.path_ids.select{|x|x!=self.id}.first)
    edge1=path1.edge?(point)
    edge2=path2.edge?(point)

    if edge2 # second path's edge
      if not edge1
        addtoend=true
        new_points=[point]
      else
        idx1=path1.point_ids.index(point.id)
        idx2=path2.point_ids.index(point.id)
        if idx1==0 and idx2==0
          canjoin=path2.points.select{|x|x.path_ids.include?(path1.id)}.size==1 #only this point
          if canjoin
            addtoend=false ; new_points=path2.points.reverse
          else
            return
          end
        elsif idx1==0
          addtoend=false ; new_points=path2.points
        elsif idx2==0
          addtoend=true ; new_points=path2.points
        else
          addtoend=true; new_points=path2.points.reverse
        end
      end
    else # we are in the middle of the second path
      addtoend=false
      points2=path2.points
      idx=path2.point_ids.index(point.id)
      if points2[idx-1].path_ids.include?(path1.id)
        new_points=points2[idx..-1].reverse
      else
        new_points=points2[0..idx]
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
      path1.point_ids=(path1.point_ids+new_points.map{|x| x.id}).uniq
    else
      path1.point_ids=(new_points.map{|x| x.id}+path1.point_ids).uniq
    end
    path1.save
  end

  def splitat(point)
    point.path_ids.each do |pathid|
      path=Geo::Path.find(pathid)
      unless path.edge?(point)
        points=path.points
        idx=points.index(point)
        new_path=Geo::Path.create
        points[idx..-1].each do |p|
          p.path_ids.push(new_path.id)
          unless p==point
            p.path_ids.delete(pathid)
            path.point_ids.delete(p.id)
          end
          p.save
          new_path.point_ids<<p.id
        end
        new_path.save
        path.save
        # XXX: delete duplicate paths
        validate_unique(new_path)
        validate_unique(path)
      end
    end
  end

  def validate_unique(path)
    if Geo::Path.where(point_ids: path.point_ids).count>1
      path.points.each do |point|
        point.path_ids.delete path.id
        point.save
      end
      path.destroy
    end
  end
end
