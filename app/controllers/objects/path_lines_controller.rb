# -*- encoding : utf-8 -*-
class Objects::PathLinesController < ApplicationController
  def index
    @title='მარშუტები'
    @lines=Objects::Path::Line.asc(:name)
  end

  protected
  def nav
    @nav=super
    @nav['მარშუტები']=objects_path_lines_url
    # if @surface
    #   @nav[@surface.name]=objects_path_surface_url(id:@surface.id) if 'edit'==action_name
    #   @nav[@title]=nil
    # end
  end
end
