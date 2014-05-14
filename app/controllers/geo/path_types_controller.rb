# -*- encoding : utf-8 -*-
class Geo::PathTypesController < ApplicationController
  def index
    @title='გზის სახეობები'
    @types=Geo::PathType.asc(:order_by)
  end

  def new
    @title='გზის ახალი სახეობა'
    if request.post?
      @type=Geo::PathType.new(type_params)
      if @type.save(user:current_user)
        redirect_to geo_path_types_url, notice: 'სახეობა დამატებულია'
        Geo::PathType.numerate
      end
    else
      @type=Geo::PathType.new
    end
  end

  def edit
    @title='გზის სახეობის რედაქტირება'
    @type=Geo::PathType.find(params[:id])
    if request.post?
      @type.update_attributes(type_params.merge(user:current_user))
      redirect_to geo_path_type_url(id:@type.id), notice: 'სახეობა შეცვლილია'
      Geo::PathType.numerate
    end
  end

  def show
    @title='გზის სახეობის თვისებები'
    @type=Geo::PathType.find(params[:id])
  end

  def delete
    type=Geo::PathType.find(params[:id])
    if type.can_delete?
      type.destroy
      Geo::PathType.numerate
      redirect_to geo_path_types_url, notice: 'გზის სახეობა წაშლილია'
    else
      redirect_to geo_path_type_url(id:type.id), alert: 'წაშლა დაუშვებელია: დამოკიდებული ობიექტები'
    end
  end

  def up
    type=Geo::PathType.find(params[:id])
    type.up
    redirect_to geo_path_types_url, notice: 'ნუმერაცია შეცვლილია'
  end

  def down
    type=Geo::PathType.find(params[:id])
    type.down
    redirect_to geo_path_types_url, notice: 'ნუმერაცია შეცვლილია'
  end

  protected
  def nav
    @nav=super
    @nav['გზის სახეობები']=geo_path_types_url
    if @type
      if 'edit'==action_name
        @nav[@type.name]=geo_path_type_url(id:@type.id)
      end
      @nav[@title]=nil
    end
  end

  private
  def type_params; params.require(:geo_path_type).permit(:name) end
end
