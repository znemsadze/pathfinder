# -*- encoding : utf-8 -*-
class Api::SubstationsController < ApiController
  def show; @substation=Objects::Substation.find(params[:id]) end

  def new
    substation=Objects::Substation.create(substation_params)
    Sys::Cache.add_object(substation)
    render json: { id: substation.id.to_s }
  end

  def edit
    substation=Objects::Substation.find(params[:id])
    substation.update_attributes(substation_params)
    Sys::Cache.replace_object(substation)
    render json: { id: substation.id.to_s }
  end

  def delete
    substation=Objects::Substation.find(params[:id])
    substation.destroy
    Sys::Cache.remove_object(substation)
    render text:'ok'
  end

  private
  def substation_params; params.permit(:name, :region_id, :lat, :lng, :description) end
end
