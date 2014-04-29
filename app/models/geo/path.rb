# -*- encoding : utf-8 -*-
class Geo::Path
  include Mongoid::Document
  has_and_belongs_to_many :points, class_name: 'Geo::Point'

  # Returns ordered array of points in this path.
  # This method should be used for index-sensitive operations.
  def ordered_points; self.point_ids.map{|x|self.points.find(x)} end

  # Splits the given path on given point.
  def split_at(point)
    points=self.ordered_points
    idx=points.index(point)
    if idx and idx>0 and idx<points.length-1
      new_path=Geo::Path.create
      points[idx..-1].each_with_index do |p,i|
        p.path_ids.delete(self.id) if i>0
        p.path_ids.push(new_path.id)
        p.save
      end
    end
  end

  # Splits this path on intersection points.
  def split_intersections
    points=self.ordered_points
    points.each_with_index do |p,idx|
      unless p.single?
        p.paths.each {|path| path.split_at p if path != self }
      end
    end
  end
end
