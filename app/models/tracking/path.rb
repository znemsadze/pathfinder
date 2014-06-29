# -*- encoding : utf-8 -*-
class Tracking::Path
  include Mongoid::Document
  belongs_to :user, class_name: 'Sys::User'
  has_many :points, class_name: 'Tracking::Point'
end
