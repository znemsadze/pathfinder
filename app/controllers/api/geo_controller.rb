class Api::GeoController < ApiController
  def new_path
    path=Geo::Path.create
    points=params[:points].map{|k,v| v}
    points.each do |p|
      lat=p[:lat].to_f ; lng=p[:lng].to_f
      if p[:featureId]
        point=Geo::Path.find(p[:featureId]).points.where(lat:lat,lng:lng).first
        point.single=false ; point.save
      else
        point=Geo::Point.create(lat:lat,lng:lng,single:true)
      end
      path.points<<point
    end
    render json: {id: path.id.to_s}
  end
end