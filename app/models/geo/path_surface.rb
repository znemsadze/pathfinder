# -*- encoding : utf-8 -*-
class Geo::PathSurface
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps

  field :name, type: String
  field :order_by, type: Integer
  belongs_to :type, class_name: 'Geo::PathType'
  validates :name, presence: {message: 'ჩაწერეთ დასახელება'}
  validates :type, presence: {message: 'აარჩიეთ გზის სახეობა'}

  def self.numerate(type)
    # offset=0
    # Geo::PathType.ne(order_by: nil).asc(:order_by).each_with_index do |t,idx|
    #   offset=idx+1 ; t.order_by=offset ; t.save
    # end
    # Geo::PathType.where(order_by: nil).each_with_index do |t,idx|
    #   t.order_by=idx+offset+1 ; t.save
    # end
  end

  def up
    # if self.order_by>1
    #   type=Geo::PathType.where(order_by:self.order_by-1).first
    #   type.order_by=self.order_by
    #   type.save
    #   self.order_by=self.order_by-1
    #   self.save
    # end
  end

  def down
    # if self.order_by<Geo::PathType.count
    #   type=Geo::PathType.where(order_by:self.order_by+1).first
    #   type.order_by=self.order_by
    #   type.save
    #   self.order_by=self.order_by+1
    #   self.save
    # end
  end

  def to_s; "#{self.type.name} > #{self.name}" end
end
