# -*- encoding : utf-8 -*-
class Api::LinesController < ApiController
  def show; @line=Objects::Line.find(params[:id]) end

  # def new
  #   parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
  #   path=Objects::Path::Line.new_path(parameter_points,params)
  #   path.splitjoin
  #   render json:{id:path.neighbours.join(',')}
  # end

  # def edit
  #   parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
  #   path=Objects::Path::Line.find(params[:id])
  #   path.update_path(parameter_points,params)
  #   path.splitjoin
  #   render json:{id:path.neighbours.join(',')}
  # end

  # def delete
  #   path=Objects::Path::Line.in(id: params[:id].split(','))
  #   path.each{|x| x.destroy_path }
  #   render text:'ok'
  # end
end
