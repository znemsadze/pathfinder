# -*- encoding : utf-8 -*-
class Api::LinesController < ApiController
  def show; @line=Objects::Line.find(params[:id]) end

  def new
    line=Objects::Line.create(line_params)
    parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
    line.set_points(parameter_points)
    render json:{id:line.id.to_s}
  end

  def edit
    line=Objects::Line.find(params[:id])
    parameter_points=params[:points].map{|k,v| [v['lat'].to_f,v['lng'].to_f]}
    line.set_points(parameter_points); line.save
    line.update_attributes(line_params)
    render json:{id:line.id.to_s}
  end

  def delete
    line=Objects::Line.in(id: params[:id])
    line.destroy
    render text:'ok'
  end

  private
  def line_params; params.permit(:name,:description,:region_id,:direction) end
end
