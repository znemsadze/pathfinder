# -*- encoding : utf-8 -*-
class Api::TowersController < ApiController
  def show; @tower=Objects::Tower.find(params[:id]) end

  def new
    tower=Objects::Tower.create(params.permit(:name,:region_id, :lat, :lng))
    render json:{id:tower.id.to_s}

  end

  def edit
    tower=Objects::Tower.find(params[:id])
    tower.update_attributes(params.permit(:name,:region_id, :lat, :lng))
    render json:{id:tower.id.to_s}
  end

  def delete
    tower=Objects::Tower.find(params[:id])
    tower.destroy
    render text:'ok'
  end
end
