class Api::GeoController < ApiController
  def new_path
    path=Geo::Path.create
    points=params[:points].map{|k,v| v}
    points.each do |p|
      lat=p['lat'].to_f ; lng=p['lng'].to_f ; featureId=p['featureId']
      if featureId
        point=Geo::Path.find(featureId).points.where(lat:lat,lng:lng).first
      else
        point=Geo::Point.create(lat:lat,lng:lng)
      end
      path.points<<point
    end
    render json:{id: path.id.to_s}
  end

  def edit_path
    path=Geo::Path.find(params[:id]) ; path.point_ids=[] ; path.save
    points=params[:points].map{|k,v| v}
    points.each do |p|
      id=p['id'] ; lat=p['lat'].to_f ; lng=p['lng'].to_f ; featureId=p['featureId']
      if id.present?
        point=Geo::Point.find(id)
        point.lat=lat ; point.lng=lng ; point.save
      elsif featureId
        point=Geo::Path.find(featureId).points.where(lat:lat,lng:lng).first
      else
        point=Geo::Point.create(lat:lat,lng:lng)
      end
      path.points<<point
    end
    render json:{id:path.id.to_s}
  end
end