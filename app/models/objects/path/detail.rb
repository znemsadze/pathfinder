# -*- encoding : utf-8 -*-
class Objects::Path::Detail
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps
  field :name, type: String
  field :order_by, type: Integer
  field :coefficient, type: Float
  belongs_to :surface, class_name: 'Objects::Path::Surface'
  validates :name, presence: {message: 'ჩაწერეთ დასახელება'}
  validates :surface, presence: {message: 'აარჩიეთ გზის საფარი'}
  validates :coefficient, :numericality => {:only_float => true, message: 'კოეფიციენტი არასწორია'}, presence: {message: 'მიუთითეთ კოეფიციენტი'}

  def to_s
    "#{self.surface.type.name } > #{self.surface.name} > #{self.name}"
  end

  def self.numerate(surface)
    offset=0
    Objects::Path::Detail.where(surface: surface).ne(order_by: nil).asc(:order_by).each_with_index do |t,idx|
      offset=idx+1 ; t.order_by=offset ; t.save
    end
    Objects::Path::Detail.where(surface: surface, order_by: nil).each_with_index do |t,idx|
      t.order_by=idx+offset+1 ; t.save
    end
  end

  def self.get_detail(surface, name)
    detail = Objects::Path::Detail.where(surface: surface, name: name).first
    if (detail.blank?)
    detail = Objects::Path::Detail.create!(surface: surface, name: name, order_by: Objects::Path::Detail.where(surface: surface).count + 1)
        puts("detail_id"+detail.id)
        puts("surface="+surface.type.name.to_s+" "+surface.name.to_s);
        puts("name="+name.to_s);
    end;
    detail
  end

  def up
    if self.order_by>1
      detail=Objects::Path::Detail.where(surface: self.surface, order_by:self.order_by-1).first
      detail.order_by=self.order_by ; detail.save
      self.order_by=self.order_by-1 ; self.save
    end
  end

  def down
    if self.order_by<Objects::Path::Detail.where(surface: self.surface).count
      detail=Objects::Path::Detail.where(surface: self.surface, order_by:self.order_by+1).first
      detail.order_by=self.order_by ; detail.save
      self.order_by=self.order_by+1 ; self.save
    end
  end

  def can_delete?; Objects::Path::Line.where(detail:self).count==0 end
end
