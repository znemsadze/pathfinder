# -*- encoding : utf-8 -*-
class Objects::Path::Type
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps
  field :name, type: String
  field :order_by, type: Integer
  has_many :surfaces, class_name: 'Objects::Path::Surface', order: 'order_by ASC'
  validates :name, presence: {message: 'ჩაწერეთ დასახელება'}

  def self.numerate
    offset=0
    Objects::Path::Type.ne(order_by: nil).asc(:order_by).each_with_index do |t,idx|
      offset=idx+1 ; t.order_by=offset ; t.save
    end
    Objects::Path::Type.where(order_by: nil).each_with_index do |t,idx|
      t.order_by=idx+offset+1 ; t.save
    end
  end

  def self.get_type(name)
    if(name==nil||name=="")
      name="უცნობი"
    end
    type = Objects::Path::Type.where(name: name).first
    if(type.blank?)
      puts "path_type======================="+name;
    end
    type = Objects::Path::Type.create!(name: name, order_by: Objects::Path::Type.count + 1) if type.blank?
    type
  end

  def up
    if self.order_by>1
      type=Objects::Path::Type.where(order_by:self.order_by-1).first
      type.order_by=self.order_by
      type.save
      self.order_by=self.order_by-1
      self.save
    end
  end

  def down
    if self.order_by<Objects::Path::Type.count
      type=Objects::Path::Type.where(order_by:self.order_by+1).first
      type.order_by=self.order_by
      type.save
      self.order_by=self.order_by+1
      self.save
    end
  end

  def can_delete?; self.surfaces.empty? end
end
