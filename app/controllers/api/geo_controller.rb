class Api::GeoController < ApiController
  def new_path
    points=params[:points].map{|k,v| v}
    if params[:id].present?
      path=Geo::Path.find(params[:id])
      path.points.where(single: true).destroy_all
    else
      path=Geo::Path.create
    end
    points.each do |p|
      point=Geo::Point.create(lat:p[0].to_f,lng:p[1].to_f,single:true)
      point.paths << path
    end
    path.sync_route
    render json: {id: path.id.to_s}
  end
end