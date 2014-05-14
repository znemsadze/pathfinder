# -*- encoding : utf-8 -*-
class Geo::PathDetailsController < ApplicationController
  def index
    @title='გზის დეტალები'
    @details=Geo::PathDetail.asc(:surface_id, :order_by)
  end

  def new
    @title='გზის ახალი დეტალი'
    if request.post?
      detail_params=params.require(:geo_path_detail).permit(:surface_id, :name)
      @detail=Geo::PathDetail.new(detail_params)
      if @detail.save(user:current_user)
        Geo::PathDetail.numerate(@detail.surface)
        redirect_to geo_path_detail_url(id: @detail.id), notice: 'გზის დეტალი დამატებულია'
      end
    else
      @detail=Geo::PathDetail.new(surface_id: params[:surface_id])
    end
  end

  def edit
    @title='გზის დეტალის რედაქტირება'
    @detail=Geo::PathDetail.find(params[:id])
    if request.post?
      detail_params=params.require(:geo_path_detail).permit(:name)
      @detail.update_attributes(detail_params.merge(user:current_user))
      redirect_to geo_path_detail_url(id:@detail.id), notice: 'დეტალი შეცვლილია'
      # Geo::PathDetail.numerate(@detail.surface)
    end
  end

  def show
    @title='გზის დეტალის თვისებები'
    @detail=Geo::PathDetail.find(params[:id])
  end

  def delete
    detail=Geo::PathDetail.find(params[:id]); surface=detail.surface
    if detail.can_delete?
      detail.destroy
      Geo::PathDetail.numerate(surface)
      redirect_to geo_path_details_url, notice: 'გზის დეტალი წაშლილია'
    else
      redirect_to geo_path_detail_url(id:detail.id), alert: 'წაშლა დაუშვებელია: დამოკიდებული ობიექტები'
    end
  end

  def up
    detail=Geo::PathDetail.find(params[:id]) ; detail.up
    redirect_to geo_path_details_url, notice: 'ნუმერაცია შეცვლილია'
  end

  def down
    detail=Geo::PathDetail.find(params[:id]) ; detail.down
    redirect_to geo_path_details_url, notice: 'ნუმერაცია შეცვლილია'
  end

  protected
  def nav
    @nav=super
    @nav['გზის დეტალები']=geo_path_details_url
    if @detail
      @nav[@detail.name]=geo_path_detail_url(id:@detail.id) if 'edit'==action_name
      @nav[@title]=nil
    end
  end
end
