# -*- encoding : utf-8 -*-
class Api::GeoController < ApiController
  def new_path
    parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
    path=Geo::Path.new_path(parameter_points)
    path.splitjoin
    render json:{id: path.id.to_s}
  end

  def edit_path
    parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
    path=Geo::Path.find(params[:id])
    path.update_points(parameter_points)
    render json:{id:path.id.to_s}
  end
end
