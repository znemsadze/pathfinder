# -*- encoding : utf-8 -*-
class Region
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::Userstamps
  field :name, type: String
  field :description, type: String
  has_many :lines, class_name: 'Objects::Line'
  has_many :paths, class_name: 'Objects::Path::Line'
  has_many :towers, class_name: 'Objects::Tower'
  has_many :offices, class_name: 'Objects::Office'
  has_many :substations, class_name: 'Objects::Substation'
  has_and_belongs_to_many :users, class_name: 'Sys::User'
  validates :name, presence: {message: 'ჩაწერეთ სახელი'}

  def self.get_by_name(name);

  region=Region.where(name:name).first
  if(region.blank?)
    Region.create(name:name)
    puts "region_name="+name
    region.save
  end
  region

  end
  def can_delete?; lines.empty? and  paths.empty? and towers.empty? and offices.empty? and substations.empty? end
  def towers_limited; self.towers.paginate(per_page:50) end
  def to_s; self.name end
end
