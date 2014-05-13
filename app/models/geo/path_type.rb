# -*- encoding : utf-8 -*-
class Geo::PathType
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps

  field :name, type: String
  field :order_by, type: Integer
  validates :name, presence: {message: 'ჩაწერეთ დასახელება'}
  after_save :on_after_save
end
