# -*- encoding : utf-8 -*-
class Geo::MapController < ApplicationController
  layout 'map'
  def index
    @paths=Geo::Path
    @paths=@paths.where(_id:params[:id]) if params[:id].present?
    @paths=@paths.all
  end
end
