# -*- encoding : utf-8 -*-
class Geo::PathSurfacesController < ApplicationController
  def index
    @title='გზის საფარი'
    @surfaces=Geo::PathSurface.asc(:type_id, :order_by)
  end

  def new
    @title='გზის ახალი საფარი'
    if request.post?
      @surface=Geo::PathSurface.new(surface_params)
      if @surface.save(user:current_user)
        Geo::PathSurface.numerate(@surface.type)
        redirect_to geo_path_surface_url(id: @surface.id), notice: 'საფარი დამატებულია'
      end
    else
      @surface=Geo::PathSurface.new(type_id: params[:type_id])
    end
  end

  def edit
    @title='გზის საფარის რედაქტირება'
    @surface=Geo::PathSurface.find(params[:id])
    if request.post?
      @surface.update_attributes(surface_params.merge(user:current_user))
      redirect_to geo_path_surface_url(id:@surface.id), notice: 'საფარი შეცვლილია'
      Geo::PathSurface.numerate(@surface.type)
    end
  end

  def show
    @title='გზის საფარის თვისებები'
    @surface=Geo::PathSurface.find(params[:id])
  end

  def delete
    surface=Geo::PathSurface.find(params[:id]); type=surface.type
    if surface.can_delete?
      surface.destroy
      Geo::PathSurface.numerate(type)
      redirect_to geo_path_surfaces_url, notice: 'გზის საფარი წაშლილია'
    else
      redirect_to geo_path_surface_url(id:surface.id), alert: 'წაშლა დაუშვებელია: დამოკიდებული ობიექტები'
    end
  end

  def up
    surface=Geo::PathSurface.find(params[:id]) ; surface.up
    redirect_to geo_path_surfaces_url, notice: 'ნუმერაცია შეცვლილია'
  end

  def down
    surface=Geo::PathSurface.find(params[:id]) ; surface.down
    redirect_to geo_path_surfaces_url, notice: 'ნუმერაცია შეცვლილია'
  end

  protected
  def nav
    @nav=super
    @nav['გზის საფარი']=geo_path_surfaces_url
    if @surface
      @nav[@surface.name]=geo_path_surface_url(id:@surface.id) if 'edit'==action_name
      @nav[@title]=nil
    end
  end

  private
  def surface_params; params.require(:geo_path_surface).permit(:name, :type_id) end
end
