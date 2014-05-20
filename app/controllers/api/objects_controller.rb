# -*- encoding : utf-8 -*-
class Api::ObjectsController < ApiController
  def all
    @towers=Objects::Tower.all
    @lines=Objects::Line.all
  end
end
