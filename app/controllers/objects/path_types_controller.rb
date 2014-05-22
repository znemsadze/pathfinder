# -*- encoding : utf-8 -*-
class Objects::PathTypesController < ApplicationController
  def index
    @title='გზის სახეობები'
    @types=Objects::Path::Type.asc(:order_by)
  end

  def new
    @title='გზის ახალი სახეობა'
    if request.post?
      @type=Objects::Path::Type.new(type_params)
      if @type.save(user:current_user)
        redirect_to objects_path_types_url, notice: 'სახეობა დამატებულია'
        Objects::Path::Type.numerate
      end
    else
      @type=Objects::Path::Type.new
    end
  end

  def edit
    @title='გზის სახეობის რედაქტირება'
    @type=Objects::Path::Type.find(params[:id])
    if request.post?
      @type.update_attributes(type_params.merge(user:current_user))
      redirect_to objects_path_type_url(id:@type.id), notice: 'სახეობა შეცვლილია'
      Objects::Path::Type.numerate
    end
  end

  def show
    @title='გზის სახეობის თვისებები'
    @type=Objects::Path::Type.find(params[:id])
  end

  def delete
    type=Objects::Path::Type.find(params[:id])
    if type.can_delete?
      type.destroy
      Objects::Path::Type.numerate
      redirect_to objects_path_types_url, notice: 'გზის სახეობა წაშლილია'
    else
      redirect_to objects_path_type_url(id:type.id), alert: 'წაშლა დაუშვებელია: დამოკიდებული ობიექტები'
    end
  end

  def up
    type=Objects::Path::Type.find(params[:id])
    type.up
    redirect_to objects_path_types_url, notice: 'ნუმერაცია შეცვლილია'
  end

  def down
    type=Objects::Path::Type.find(params[:id])
    type.down
    redirect_to objects_path_types_url, notice: 'ნუმერაცია შეცვლილია'
  end

  protected
  def nav
    @nav=super
    @nav['გზის სახეობები']=objects_path_types_url
    if @type
      if 'edit'==action_name
        @nav[@type.name]=objects_path_type_url(id:@type.id)
      end
      @nav[@title]=nil
    end
  end

  private
  def type_params; params.require(:objects_path_type).permit(:name) end
end
