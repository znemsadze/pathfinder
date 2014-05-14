# -*- encoding : utf-8 -*-
class Geo::PathDetail
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps

  field :name, type: String
  field :order_by, type: Integer
  belongs_to :surface, class_name: 'Geo::PathSurface'
  validates :name, presence: {message: 'ჩაწერეთ დასახელება'}
  validates :surface, presence: {message: 'აარჩიეთ გზის საფარი'}

  def self.numerate(surface)
    offset=0
    Geo::PathDetail.where(surface: surface).ne(order_by: nil).asc(:order_by).each_with_index do |t,idx|
      offset=idx+1 ; t.order_by=offset ; t.save
    end
    Geo::PathDetail.where(surface: surface, order_by: nil).each_with_index do |t,idx|
      t.order_by=idx+offset+1 ; t.save
    end
  end

  def up
    if self.order_by>1
      detail=Geo::PathDetail.where(surface: self.surface, order_by:self.order_by-1).first
      detail.order_by=self.order_by ; detail.save
      self.order_by=self.order_by-1 ; self.save
    end
  end

  def down
    if self.order_by<Geo::PathDetail.where(surface: self.surface).count
      detail=Geo::PathDetail.where(surface: self.surface, order_by:self.order_by+1).first
      detail.order_by=self.order_by ; detail.save
      self.order_by=self.order_by+1 ; self.save
    end
  end

  def can_delete?; true end
end
