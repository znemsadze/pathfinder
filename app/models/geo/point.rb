# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps

  field :name, type: String
  field :lng, type: Float
  field :lat, type: Float

  validates :name, presence: {message: I18n.t('models.geo_point._errors.name_required')}
end
