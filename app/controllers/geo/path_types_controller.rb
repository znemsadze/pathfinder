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
      if @type.save
      end
    else
      @type=Geo::PathType.new
    end
  end

  protected
  def nav
    @nav=super
    @nav['გზის სახეობები']=geo_path_types_url
    if @type
      @nav[@title]=nil
    end
  end

  private
  def type_params; params.require(:geo_path_type).permit(:name) end
end
