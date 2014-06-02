# -*- encoding : utf-8 -*-
class Objects::Substation
  include Mongoid::Document
  include Objects::Coordinate

  field :name, type: String
  field :description, type: String
  belongs_to :region
end
