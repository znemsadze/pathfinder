# -*- encoding : utf-8 -*-
class Api::GeoController < ApiController
  def new_path
    parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
    path=Geo::Path.new_path(parameter_points)
    path.splitjoin
    render json:{id:path.neighbours.join(',')}
  end

  def edit_path
    parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
    path=Geo::Path.find(params[:id])
    path.update_points(parameter_points)
    path.splitjoin
    render json:{id:path.neighbours.join(',')}
  end

  def delete_path
    path=Geo::Path.in(id: params[:id].split(','))
    path.each{|x| x.destroy_path }
    render text:'ok'
  end
end
