# -*- encoding : utf-8 -*-
class Api::ShortestpathController < ApiController
  def index
    origins = ( if params[:from] and params[:to]
                  from = params[:from].split(':').map{ |x| x.to_f }
                  to = params[:to].split(':').map{ |x| x.to_f }

                  [ from, to ]
                else
                  params[:ids].map{|x| a=x.split('/'); a[0].constantize.find(a[1]).location }
                end )


    closest_points = origins.map{|x| Objects::Path::Point.geo_near(x).spherical.first }
    dist = heur = ->(p1,p2){ distance_between(p1,p2) }

    #Sys::Cache::clear_map_objects
    @points=Sys::Cache::pathpoints;
    @lines=Sys::Cache::pathlines;
    @pathcolor=Sys::Cache::pathColors;
    #@lines=Sys::Cache::pathlinessmall;

    puts "cache get end"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")

    if closest_points.length > 1
      p1 = p2 = closest_points[0]
      puts "build_graph started"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")
      graph = build_graph(closest_points)
      puts "build_graph end"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")
      @responses = []


      (1..closest_points.length-1).each do |idx|
        p2 = closest_points[idx]
        puts "astar started"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")
        path = Shortest::Path.astar(dist, heur, graph, p1, p2)
        puts "astar ended"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")
        @responses.concat extract_path(path)
        p1 = p2
      end
    else
      render json: { path: 'empty' }
    end
  end

  private

  def build_graph(points)
    @edgePoint=Sys::Cache::edgepoints;

    graph = get_current_graph
    points_by_path = points.group_by { |point| point.pathline_ids.first }
    points_by_path.each do |line_id, split_by|
      line = Objects::Path::Line.find(line_id)
      point_ids = line.point_ids
      remove_graph_edge(graph, point_ids.first, point_ids.last)
      split_by = split_by.map{|x| x.id }.sort_by{ |id| point_ids.index(id) }
      i1, p1 = [ 0, point_ids.first ]
      split_by.each do |point_id|
        p2 = point_id ; i2 = point_ids.index(point_id)
        add_graph_edge_slow(graph, p1, p2, line_length2(line, i1, i2))
        i1, p1 = [ i2, p2 ]
      end
      i2, p2 = [ point_ids.length - 1, point_ids.last ]
      add_graph_edge_slow(graph, p1, p2, line_length2(line, i1, i2))
    end

    graph
  end

  def get_current_graph
    # check graph caching
    build_graph = ( $__graph.blank? || ($__graph_date < Objects::Path::Point.first.created_at   ) )

    # re-create graph, if necessary
    if build_graph
      $__graph = build_default_graph
      $__graph_date = Time.now
    end

    # prepare search graph
    graph = $__graph.clone
    graph.edges = $__graph.edges.clone
    graph
  end

  def build_default_graph
    graph = Shortest::Path::Graph.new
    # @edgePoint=   Hash[ Objects::Path::Point.where(edge:true).to_a.map{ |x| [ x.id, x ] } ]



    Objects::Path::Line.each do |line|
      point_ids = line.point_ids
      p1 = point_ids.first ; p2 = point_ids.last
      add_graph_edgefast(graph, p1, p2, line.length)
    end
    graph
  end




  def add_graph_edge_slow(graph, p1, p2, length)
    point1 = Objects::Path::Point.find(p1)
    point2 = Objects::Path::Point.find(p2)
    # point1=@edgePoint[p1]# Sys::Cache::edgepoints[p1];
    # point2=@edgePoint[p1]# Sys::Cache::edgepoints[p2];

    # graph << point1 unless graph.include?(point1)
    # graph << point2 unless graph.include?(point2)
    graph.connect_mutually(point1, point2, length)
  end


  def add_graph_edgefast(graph, p1, p2, length)
    point1=@edgePoint[p1]
    point2=@edgePoint[p2]
    graph.connect_mutually(point1, point2, length)
  end

  def remove_graph_edge(graph, p1, p2)
    # point1 = Objects::Path::Point.find(p1)
    # point2 = Objects::Path::Point.find(p2)
    point1= @edgePoint[p1]#Sys::Cache::edgepoints[p1];
    point2= @edgePoint[p2]#Sys::Cache::edgepoints[p2];

    graph.remove_edge(point1, point2)
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

  def line_length2(line, i1, i2)
    len = 0; points = line.point_ids
    (i1 + 1 .. i2).each do |idx|
      p1 = @points[points[idx-1].to_s] ; p2=@points[points[idx].to_s]
      a1 = Geokit::LatLng.new(p1[0], p1[1])
      a2 = Geokit::LatLng.new(p2[0], p2[1])
      len += a1.distance_to(a2)
    end
    len
  end


  def extract_path(points)

    puts "extract  started"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")


    p1 = p2 = points[0]

    length=0
    result_arr=[]
    (1..points.length-1).each do |idx|
      p2 = points[idx]
      new_points=[]

      pathline_id = 0
      p1.pathline_ids.each do |p1_path|
        p2.pathline_ids.each do |p2_path|
          if p1_path == p2_path
            pathline_id = p1_path
            break
          end
        end
        if pathline_id != 0
          break
        end
      end

      line=@lines[pathline_id]


      #line=Objects::Path::Line.find(pathline_id)

      i1=line.point_ids.index(p1.id) ; i2=line.point_ids.index(p2.id)

      if i1 < i2
        (i1..i2).each do |i|
          new_points << @points[line.point_ids[i].to_s]
        end
      else
        ary=[]
        (i2..i1).each do |i|
          ary << @points[line.point_ids[i].to_s]
        end
        ary.reverse.each do |p|
          new_points << p
        end
      end
      # length += line.length
      p1 = p2
      pathcl=@pathcolor[line.detail.surface.name ]
      if(pathcl==nil)
        pathcl=@pathcolor["unknown"]
      end
      result_arr<< {points: new_points, length: line.length,line_name: line.detail.name,
          surface_name:line.detail.surface.name,path_color:pathcl }
    end
    puts "extract end"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")
    return result_arr
  end

  def extract_path_p(points)
    puts "extract  started"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")

    p1 = p2 = points[0]
    new_points=[]
    length=0
    #@points=Sys::Cache::pathpoints;

    puts "extract cache get "+  Time.now.strftime("%d/%m/%Y %H:%M:%S")

    (1..points.length-1).each do |idx|
      p2 = points[idx]

      pathline_id = 0
      p1.pathline_ids.each do |p1_path|
        p2.pathline_ids.each do |p2_path|
          if p1_path == p2_path
            pathline_id = p1_path
            break
          end
        end
        if pathline_id != 0
          break
        end
      end

      line=Objects::Path::Line.find(pathline_id)

      i1=line.point_ids.index(p1.id) ; i2=line.point_ids.index(p2.id)

      if i1 < i2
        (i1..i2).each do |i|
          po = Objects::Path::Point.find(line.point_ids[i])
          new_points << [po.lat, po.lng]
        end
      else
        ary=[]
        (i2..i1).each do |i|
          po = Objects::Path::Point.find(line.point_ids[i])
          ary <<  [po.lat, po.lng]# Objects::Path::Point.find(line.point_ids[i])
        end
        ary.reverse.each do |p|
          new_points << p
        end
      end
      length += line.length
      p1 = p2
    end

    puts "extract end"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")

    {points: new_points, length: length}

  end

  def extract_path2(points)
    puts "extract  started"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")

    p1 = p2 = points[0]
    new_points=[]
    length=0

    puts "extract cache get "+  Time.now.strftime("%d/%m/%Y %H:%M:%S")

    (1..points.length-1).each do |idx|
      p2 = points[idx]

      pathline_id = 0
      p1.pathline_ids.each do |p1_path|
        p2.pathline_ids.each do |p2_path|
          if p1_path == p2_path
            pathline_id = p1_path
            break
          end
        end
        if pathline_id != 0
          break
        end
      end

      #line=Objects::Path::Line.all(point_ids: [p1.id, p2.id]).first
      #line=Objects::Path::Line.find(pathline_id)

      line=@lines[pathline_id];


      i1=line[0].index(p1.id) ; i2=line[0].index(p2.id)


      #@points=   Hash[ Objects::Path::Point.find(line.point_ids).to_a.map{ |x| [ x.id, x ] }]
      if i1 < i2
        (i1..i2).each do |i|
          new_points << @points[line[0][i].to_s]#  Objects::Path::Point.find(line.point_ids[i])
        end
      else
        ary=[]
        (i2..i1).each do |i|
          ary << @points[line[0][i].to_s]# Objects::Path::Point.find(line.point_ids[i])
        end
        ary.reverse.each do |p|
          new_points << p
        end
      end
      length += line[1]  # distance_between(p1, p2)
      p1 = p2
    end

    puts "extract end"+  Time.now.strftime("%d/%m/%Y %H:%M:%S")

    {points: new_points, length: length}

  end


#   def extract_path(points)
#
#     p1 = p2 = points[0]
#     new_points=[]
#     @lineids =[]
#     @lines=[]
#     length=0
#     (1..points.length-1).each do |idx|
#       p2 = points[idx]
#
#       pathline_id = 0
#       p1.pathline_ids.each do |p1_path|
#         p2.pathline_ids.each do |p2_path|
#           if p1_path == p2_path
#             pathline_id = p1_path
#             @lineids<<pathline_id
#             break
#           end
#         end
#         if pathline_id != 0
#           break
#         end
#       end
#       p1=p2
#       end;
#
#     @lines=Objects::Path::Line.find(@lineids);
#
#     @pointids=[]
#      (0..@lines.length-1).each do |ndx|
#        @pointids.concat @lines[ndx].point_ids
#      end
#     @linesMap=Hash[@lines.to_a.map{|x| [ x.id, x ]}]
#
#     @allPoints=   Hash[ Objects::Path::Point.find(@pointids).to_a.map{ |x| [ x.id, x ] }]
#      # @points=Sys::Cache::allpoints
#
#
# #   path start node points
#     pstart=points[0]
#     pend=points[points.length-1]
#     line=@linesMap[@lineids[0]]
#     i1= line.point_ids.index( pstart.id)
#     i2= line.point_ids.length-1
#     (i1..i2).each do |i|
#       new_points << @allPoints[line.point_ids[i]]#  Objects::Path::Point.find(line.point_ids[i])
#     end
# #   path midle points
#    (1..@lineids.length-2).each do |ndx|
#       line=@linesMap[@lineids[ndx]]
#       i1=0 ;      i2= line.point_ids.length-1
#        (i1..i2).each do |i|
#           new_points << @allPoints[line.point_ids[i]]#  Objects::Path::Point.find(line.point_ids[i])
#         end
#       length += line.length  # distance_between(p1, p2)
#    end
# #   path end node  points
#     line=@linesMap[@lineids[@lineids.length-1]]
#     i1=0
#     i2= line.point_ids.index( pend.id)
#     (i1..i2).each do |i|
#       new_points << @allPoints[line.point_ids[i]]#  Objects::Path::Point.find(line.point_ids[i])
#     end
#
#     {points: new_points, length: length}
#   end

  def distance_between(p1,p2)
    # return 1;

    # return 1;
    a1 = Geokit::LatLng.new(p1.lat, p1.lng)
    a2 = Geokit::LatLng.new(p2.lat, p2.lng)
    a1.distance_to(a2)
  end
end
