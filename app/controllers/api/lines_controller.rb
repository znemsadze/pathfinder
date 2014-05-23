# -*- encoding : utf-8 -*-
class Api::LinesController < ApiController
  def show; @line=Objects::Line.find(params[:id]) end

  # def new
  #   parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
  #   path=Objects::Path::Line.new_path(parameter_points,params)
  #   path.splitjoin
  #   render json:{id:path.neighbours.join(',')}
  # end

  def edit
    line=Objects::Line.find(params[:id])
    parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
    line.set_points(parameter_points)
    line.name=params[:name]
    line.description=params[:description]
    line.save
    render json:{id:line.id.to_s}
  end

  # def delete
  #   path=Objects::Path::Line.in(id: params[:id].split(','))
  #   path.each{|x| x.destroy_path }
  #   render text:'ok'
  # end
end
