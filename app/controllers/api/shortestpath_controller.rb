# -*- encoding : utf-8 -*-
class Api::ShortestpathController < ApiController
  def index
    origins=params[:ids].map{|x| a=x.split('/'); a[0].constantize.find(a[1]) }
    close_points=origins.map{|x| Objects::Path::Point.geo_near(x.location).spherical.first }.uniq

    dist = heur = ->(p1,p2){ distance_between(p1,p2) }

    if close_points.length > 1
      p1 = p2 = close_points[0]
      graph = build_graph(origins, close_points)
      @responses = []
      (1..close_points.length-1).each do |idx|
        p2 = close_points[idx]
        @responses << extract_path(Shortest::Path.astar(dist, heur, graph, p1, p2))
        p1 = p2
      end
    else
      render text: 'empty path'
    end
  end

  private

  def build_graph(origins, close_points)
    graph=Shortest::Path::Graph.new

    Objects::Path::Line.each do |line|
      line_points=line.points
      p1=line_points.first
      p2=line_points.last
      graph << p1 unless graph.include?(p1)
      graph << p2 unless graph.include?(p2)
      graph.connect_mutually(p1, p2, line.length)
    end

    close_points.each do |p|
      unless graph.include?(p)
        graph << p
        line = Objects::Path::Line.find(p.path_ids.first)
        p1 = Objects::Path::Point.find(line.point_ids.first)
        p2 = Objects::Path::Point.find(line.point_ids.last)
        idx=line.point_ids.index(p.id)
        graph.connect_mutually(p, p1, line_length(line, 0, idx))
        graph.connect_mutually(p, p2, line_length(line, idx, line.point_ids.length-1))
      end
    end

    graph
  end

  def line_length(line, i1, i2)
    len=0; points=line.points.to_a
    (i1+1..i2).each do |idx|
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
