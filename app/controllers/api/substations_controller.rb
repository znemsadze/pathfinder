# -*- encoding : utf-8 -*-
class Api::SubstationsController < ApiController
  def show; @substation=Objects::Substation.find(params[:id]) end

  def new
    substation=Objects::Substation.create(substation_params)
    render json:{id:substation.id.to_s}

  end

  def edit
    substation=Objects::Substation.find(params[:id])
    substation.update_attributes(substation_params)
    render json:{id:substation.id.to_s}
  end

  def delete
    substation=Objects::Substation.find(params[:id])
    substation.destroy
    render text:'ok'
  end

  private
  def substation; params.permit(:name, :region_id, :lat, :lng, :description) end
end
