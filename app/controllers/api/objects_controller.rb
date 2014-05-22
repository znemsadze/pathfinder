# -*- encoding : utf-8 -*-
class Api::ObjectsController < ApiController
  def index
    towers=Objects::Tower.all.paginate(per_page:100)
    lines=Objects::Line.all
    paths=Objects::Path::Line.all
    @all=towers+lines+paths
  end
end
