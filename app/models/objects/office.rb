# -*- encoding : utf-8 -*-
class Objects::Office
  include Mongoid::Document
  include Objects::Coordinate
  include Objects::Kml

  field :kmlid, type: String
  field :name, type: String
  field :description, type: String
  field :address, type: String
  belongs_to :region
end
