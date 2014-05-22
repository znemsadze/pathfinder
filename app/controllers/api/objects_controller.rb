# -*- encoding : utf-8 -*-
class Api::ObjectsController < ApiController
  def all
    @towers=Objects::Tower.all.paginate(per_page:100)
    @lines=Objects::Line.all.paginate
  end
end
