# -*- encoding : utf-8 -*-
class Region
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps
  field :name, type: String
  field :description, type: String
  has_many :lines, class_name: 'Objects::Line'
  has_many :towers, class_name: 'Objects::Tower'
  validates :name, presence: {message: 'ჩაწერეთ სახელი'}

  def can_delete?; lines.empty? end
end
