# -*- encoding : utf-8 -*-
class Geo::PathType
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps

  field :name, type: String
  field :order_by, type: Integer
  validates :name, presence: {message: 'ჩაწერეთ დასახელება'}

  def self.numerate
    Geo::PathType.asc(:order_by,:_id).each_with_index do |t,idx|
      t.order_by=idx+1
      t.save
    end
  end
end
