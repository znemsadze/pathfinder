class Api::GeoController < ApiController
  def new_path
    path=Geo::Path.create
    parameter_points=params[:points].map{|k,v| v}
    parameter_points.each do |p|
      lat,lng=p['lat'].to_f,p['lng'].to_f
      point=Geo::Point.where(lat:lat,lng:lng).first || Geo::Point.create(lat:lat,lng:lng)
      path.points<<point
    end
    path.split_intersections
    path.join_continuations
    render json:{id: path.id.to_s}
  end

  def edit_path
    parameter_points=params[:points].map{|k,v| v}
    path=Geo::Path.find(params[:id])
    points=path.ordered_points ; path.point_ids=[] ; path.save
    parameter_points.each_with_index do |p,i|
      lat=p['lat'].to_f ; lng=p['lng'].to_f
      if i==0 or i==parameter_points.length-1
        point=(i==0 ? points[0] : points[points.length-1])
        point.lat=lat ; point.lng=lng ; point.save
      else
        point=Geo::Point.where(lat:lat,lng:lng).first || Geo::Point.create(lat:lat,lng:lng)
      end
      path.points<<point
    end
    render json:{id:path.id.to_s}
  end
end