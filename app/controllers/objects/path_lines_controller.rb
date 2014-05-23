# -*- encoding : utf-8 -*-
class Objects::PathLinesController < ApplicationController
  def index
    @title='მარშუტები'
    @lines=Objects::Path::Line.asc(:name).paginate(per_page: 10, page: params[:page])
  end

  def show
    @title='მარშუტის თვისებები'
    @line=Objects::Path::Line.find(params[:id])
  end


  protected
  def nav
    @nav=super
    @nav['მარშუტები']=objects_path_lines_url
    if @line
      @nav[@line.name]=objects_path_line_url(id:@line.id) if 'edit'==action_name
      @nav[@title]=nil
    end
  end
end
