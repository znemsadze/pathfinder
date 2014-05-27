# -*- encoding : utf-8 -*-
class Region
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps
  field :name, type: String
  field :description, type: String
  validates :name, presence: {message: 'ჩაწერეთ სახელი'}

  def can_delete?; true end
end
