# -*- encoding : utf-8 -*-
class Objects::Office
  include Mongoid::Document
  include Objects::Coordinate

  field :name, type: String
  field :description, type: String
  field :address, type: String
  belongs_to :region
end
