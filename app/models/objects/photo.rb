# -*- encoding : utf-8 -*-
class Objects::Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :owner, polymorphic: true
  field :filename, type: String
  field :confirmed, type: Mongoid::Boolean

  def self.not_confirmed; Objects::Photo.where(confirmed: false) end
  def thumbnail_url; "#{self.owner.thumb_url}/#{self.filename}" end
  def large_url; "#{self.owner.large_url}/#{self.filename}" end
end
