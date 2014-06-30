# -*- encoding : utf-8 -*-
class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :assignee, class_name: 'Sys::User'
  has_many :destinations, polymorphic: true
  field :paths, type: Array
  field :number, type: Integer
  field :note, type: String
  before_create :on_before_create

  private
  def on_before_create
    last = Taks.last
    if last.present? then self.number = 1
    else self.number = last.number + 1 end
  end
end
