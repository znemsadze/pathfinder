# -*- encoding : utf-8 -*-
require 'xml'
class Objects::Tower
  include Mongoid::Document

  field :kmlid, type: String
  field :name, type: String
  field :description, type: String
  field :styleUrl, type: String
  filed :lng, type: Float
  field :lat, type: Float

  def self.extract_from_kml(file_name)

  end
end
