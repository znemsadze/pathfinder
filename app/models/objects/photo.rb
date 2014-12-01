# -*- encoding : utf-8 -*-
class Objects::Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :owner, polymorphic: true
  field :filename, type: String
  field :confirmed, type: Mongoid::Boolean

  def self.not_confirmed; Objects::Photo.where(confirmed: false) end
  def thumbnail_url; "/uploads/#{self.owner_id}/thumb/#{self.filename}" end
  def large_url; "/uploads/#{self.owner_id}/large/#{self.filename}" end
end
