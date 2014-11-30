# -*- encoding : utf-8 -*-
class Api::PathsController < ApiController
  def show; @path=Objects::Path::Line.find(params[:id]) end

  def edit
    path = Objects::Path::Line.find(params[:id])
    path.update_attributes(path_params)
    Sys::Cache.replace_object(path)
    render json:{ id: path.id }
  end

  def delete
    path=Objects::Path::Line.find(params[:id])
    Objects::Path::Point.where(line_id: path.id).destroy_all
    path.destroy
    Sys::Cache.remove_object(params[:id])
    render text: 'ok'
  end

  def details; @types = Objects::Path::Type.asc(:order_by) end

  private
  def path_params; params.permit(:detail_id, :name, :description, :region_id) end
end
