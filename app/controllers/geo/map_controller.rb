# -*- encoding : utf-8 -*-
class Geo::MapController < ApplicationController
  layout 'map'
  def index; @paths=Geo::Path.all end
end
