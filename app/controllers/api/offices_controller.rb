# -*- encoding : utf-8 -*-
class Api::OfficesController < ApiController
  def show; @office=Objects::Office.find(params[:id]) end

  def new
    office=Objects::Office.create(office_params)
    Sys::Cache.add_object(office)
    render json: { id: office.id.to_s }
  end

  def edit
    office=Objects::Office.find(params[:id])
    office.update_attributes(office_params)
    Sys::Cache.replace_object(office)
    render json: { id: office.id.to_s }
  end

  def delete
    office=Objects::Office.find(params[:id])
    office.destroy
    Sys::Cache.remove_object(office)
    render text: 'ok'
  end

  private
  def office_params; params.permit(:name, :region_id, :lat, :lng, :description, :address) end
end
