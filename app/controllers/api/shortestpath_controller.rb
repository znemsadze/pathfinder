# -*- encoding : utf-8 -*-
class Api::ShortestpathController < ApiController
  def index
    origins = params[:ids].map{|x| a=x.split('/'); a[0].constantize.find(a[1]) }
    closest_points = origins.map{|x| Objects::Path::Point.geo_near(x.location).spherical.first }
    dist = heur = ->(p1,p2){ distance_between(p1,p2) }
    if closest_points.length > 1
      p1 = p2 = closest_points[0]
      graph = build_graph(closest_points)
      @responses = []
      (1..closest_points.length-1).each do |idx|
        p2 = closest_points[idx]
        path = Shortest::Path.astar(dist, heur, graph, p1, p2)
        @responses << extract_path(path)
        p1 = p2
      end
    else
      render json: { path: 'empty' }
    end
  end

  private

  def add_graph_edge(graph, p1, p2, length)
    point1 = Objects::Path::Point.find(p1)
    point2 = Objects::Path::Point.find(p2)
    graph << point1 unless graph.include?(point1)
    graph << point2 unless graph.include?(point2)
    graph.connect_mutually(point1, point2, length)
  end

  def build_graph(points)
    points_by_path = points.group_by { |point| point.pathline_ids.first }
    graph=Shortest::Path::Graph.new
    Objects::Path::Line.each do |line|
      point_ids = line.point_ids
      split_by = points_by_path[line.id]
      if split_by.present?
        split_by = split_by.map{|x| x.id }.sort_by{ |id| point_ids.index(id) }
        i1, p1 = [ 0, point_ids.first ]
        split_by.each do |point_id|
          p2 = point_id ; i2 = point_ids.index(point_id)
          add_graph_edge(graph, p1, p2, line_length(line, i1, i2))
          i1, p1 = [ i2, p2 ]
        end
        i2, p2 = [ point_ids.length - 1, point_ids.last ]
        add_graph_edge(graph, p1, p2, line_length(line, i1, i2))
      else
        p1 = point_ids.first ; p2 = point_ids.last
        add_graph_edge(graph, p1, p2, line.length)
      end
    end

    graph
  end

  def line_length(line, i1, i2)
    len = 0 ; points = line.points.to_a
    (i1 + 1 .. i2).each do |idx|
      p1 = points[idx-1] ; p2=points[idx]
      a1 = Geokit::LatLng.new(p1.lat, p1.lng)
      a2 = Geokit::LatLng.new(p2.lat, p2.lng)
      len += a1.distance_to(a2)
    end
    len
  end

  def extract_path(points)
    p1 = p2 = points[0]
    new_points=[]
    length=0
    (1..points.length-1).each do |idx|
      p2 = points[idx]
      line=Objects::Path::Line.all(point_ids: [p1.id, p2.id]).first
      i1=line.point_ids.index(p1.id) ; i2=line.point_ids.index(p2.id)
      if i1 < i2
        (i1..i2).each do |i|
          new_points << Objects::Path::Point.find(line.point_ids[i])
        end
      else
        ary=[]
        (i2..i1).each do |i|
          ary << Objects::Path::Point.find(line.point_ids[i])
        end
        ary.reverse.each do |p|
          new_points << p
        end
      end
      length += distance_between(p1, p2)
      p1 = p2
    end
    {points: new_points, length: length}
  end

  def distance_between(p1,p2)
    a1 = Geokit::LatLng.new(p1.lat, p1.lng)
    a2 = Geokit::LatLng.new(p2.lat, p2.lng)
    a1.distance_to(a2)
  end
end
