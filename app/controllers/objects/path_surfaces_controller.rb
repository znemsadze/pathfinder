# -*- encoding : utf-8 -*-
class Objects::PathSurfacesController < ApplicationController
  def index
    @title='გზის საფარი'
    @types=Objects::Path::Type.asc(:order_by)
  end

  def new
    @title='გზის ახალი საფარი'
    if request.post?
      surface_params=params.require(:objects_path_surface).permit(:name, :type_id)
      @surface=Objects::Path::Surface.new(surface_params)
      if @surface.save(user:current_user)
        Objects::Path::Surface.numerate(@surface.type)
        redirect_to objects_path_surface_url(id: @surface.id), notice: 'საფარი დამატებულია'
      end
    else
      @surface=Objects::Path::Surface.new(type_id: params[:type_id])
    end
  end

  def edit
    @title='გზის საფარის რედაქტირება'
    @surface=Objects::Path::Surface.find(params[:id])
    if request.post?
      surface_params=params.require(:objects_path_surface).permit(:name)
      @surface.update_attributes(surface_params.merge(user:current_user))
      redirect_to objects_path_surface_url(id:@surface.id), notice: 'საფარი შეცვლილია'
      Objects::Path::Surface.numerate(@surface.type)
    end
  end

  def show
    @title='გზის საფარის თვისებები'
    @surface=Objects::Path::Surface.find(params[:id])
  end

  def delete
    surface=Objects::Path::Surface.find(params[:id]); type=surface.type
    if surface.can_delete?
      surface.destroy
      Objects::Path::Surface.numerate(type)
      redirect_to objects_path_surfaces_url, notice: 'გზის საფარი წაშლილია'
    else
      redirect_to objects_path_surface_url(id:surface.id), alert: 'წაშლა დაუშვებელია: დამოკიდებული ობიექტები'
    end
  end

  def up
    surface=Objects::Path::Surface.find(params[:id]) ; surface.up
    redirect_to objects_path_surfaces_url, notice: 'ნუმერაცია შეცვლილია'
  end

  def down
    surface=Objects::Path::Surface.find(params[:id]) ; surface.down
    redirect_to objects_path_surfaces_url, notice: 'ნუმერაცია შეცვლილია'
  end

  protected
  def nav
    @nav=super
    @nav['გზის საფარი']=objects_path_surfaces_url
    if @surface
      @nav[@surface.name]=objects_path_surface_url(id:@surface.id) if 'edit'==action_name
      @nav[@title]=nil
    end
  end
end
