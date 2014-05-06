# -*- encoding : utf-8 -*-
class Geo::MapController < ApplicationController
  layout 'map'
  def index
    @paths=Geo::Path
    @paths=@paths.in(_id:params[:id].split(',')) if params[:id].present?
    @paths=@paths.all
  end
end
