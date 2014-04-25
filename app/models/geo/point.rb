# -*- encoding : utf-8 -*-
class Geo::Point
  include Mongoid::Document
  belongs_to :path, class_name:'Geo::Path'
  field :lat, type: Float
  field :lng, type: Float
  validates :lat, presence: {message: 'ჩაწერეთ განედი'}
  validates :lng, presence: {message: 'ჩაწერეთ გრძედი'}
end
