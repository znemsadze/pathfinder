class Api::GeoController < ApiController
  def new_path
    points=params[:points].map{|k,v| v}
    path=Geo::Path.create
    points.each do |p|
      point=Geo::Point.create(lat:p[0].to_f,lng:p[1].to_f,single:true)
      point.paths << path
    end
    render text:path.id.to_s
  end
end