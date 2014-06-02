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
  validates :name, presence: {message: 'ჩაწერეთ სახელი'}

  def self.get_by_name(name); Region.where(name:name).first || Region.create(name:name) end
  def can_delete?; lines.empty? and  paths.empty? and towers.empty? and offices.empty? and substations.empty? end
end
