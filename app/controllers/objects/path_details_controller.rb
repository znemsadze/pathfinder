# -*- encoding : utf-8 -*-
class Objects::PathDetailsController < ApplicationController
  def index
    @title='საფარის დეტალები'
    respond_to do |format|
      format.html{ @types=Objects::Path::Type.asc(:order_by) }
      format.json{ @details=Objects::Path::Detail.all }
    end
  end

  def new
    @title='საფარის ახალი დეტალი'
    if request.post?
      detail_params=params.require(:objects_path_detail).permit(:surface_id, :name, :coefficient)
      @detail=Objects::Path::Detail.new(detail_params)
      if @detail.save(user:current_user)
        Objects::Path::Detail.numerate(@detail.surface)
        redirect_to objects_path_detail_url(id: @detail.id), notice: 'გზის დეტალი დამატებულია'
      end
    else
      @detail=Objects::Path::Detail.new(surface_id: params[:surface_id])
    end
  end

  def edit
    @title='საფარის დეტალის რედაქტირება'
    @detail=Objects::Path::Detail.find(params[:id])
    if request.post?
      detail_params=params.require(:objects_path_detail).permit(:name, :coefficient)
      @detail.update_attributes(detail_params.merge(user:current_user))
      redirect_to objects_path_detail_url(id:@detail.id), notice: 'საფარის დეტალი შეცვლილია'
    end
  end

  def show
    @title='საფარის დეტალის თვისებები'
    @detail=Objects::Path::Detail.find(params[:id])
  end

  def delete
    detail=Objects::Path::Detail.find(params[:id]); surface=detail.surface
    if detail.can_delete?
      detail.destroy
      Objects::Path::Detail.numerate(surface)
      redirect_to objects_path_details_url, notice: 'საფარის დეტალი წაშლილია'
    else
      redirect_to objects_path_detail_url(id:detail.id), alert: 'წაშლა დაუშვებელია: დამოკიდებული ობიექტები'
    end
  end

  def up
    detail=Objects::Path::Detail.find(params[:id]) ; detail.up
    redirect_to objects_path_details_url, notice: 'ნუმერაცია შეცვლილია'
  end

  def down
    detail=Objects::Path::Detail.find(params[:id]) ; detail.down
    redirect_to objects_path_details_url, notice: 'ნუმერაცია შეცვლილია'
  end

  protected
  def nav
    @nav=super
    @nav['საფარის დეტალები']=objects_path_details_url
    if @detail
      @nav[@detail.name]=objects_path_detail_url(id:@detail.id) if 'edit'==action_name
      @nav[@title]=nil
    end
  end

  def login_required; true end
  def permission_required; not current_user.admin? end
end
