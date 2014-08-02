# -*- encoding : utf-8 -*-
class Objects::Path::Surface
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps

  field :name, type: String
  field :order_by, type: Integer
  belongs_to :type, class_name: 'Objects::Path::Type'
  has_many :details, class_name: 'Objects::Path::Detail', order: 'order_by ASC'
  validates :name, presence: {message: 'ჩაწერეთ დასახელება'}
  validates :type, presence: {message: 'აარჩიეთ გზის სახეობა'}

  def self.numerate(type)
    offset=0
    Objects::Path::Surface.where(type: type).ne(order_by: nil).asc(:order_by).each_with_index do |t,idx|
      offset=idx+1 ; t.order_by=offset ; t.save
    end
    Objects::Path::Surface.where(type: type, order_by: nil).each_with_index do |t,idx|
      t.order_by=idx+offset+1 ; t.save
    end
  end

  def self.get_surface(type, name)
    surface = Objects::Path::Surface.where(type: type, name: name).first
    surface = Objects::Path::Surface.create(type: type, name: name, order_by: Objects::Path::Surface.where(type: type).count + 1) if surface.blank?
    surface
  end

  def up
    if self.order_by>1
      surface=Objects::Path::Surface.where(type: self.type, order_by:self.order_by-1).first
      surface.order_by=self.order_by ; surface.save
      self.order_by=self.order_by-1 ; self.save
    end
  end

  def down
    if self.order_by<Objects::Path::Surface.where(type: self.type).count
      surface=Objects::Path::Surface.where(type: self.type, order_by:self.order_by+1).first
      surface.order_by=self.order_by ; surface.save
      self.order_by=self.order_by+1 ; self.save
    end
  end

  def can_delete?; self.details.empty? end
end
