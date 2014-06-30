# -*- encoding : utf-8 -*-
class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  START = 0
  CANCELED = 1
  IN_PROGRESS = 2
  COMPELETED = 10

  belongs_to :assignee, class_name: 'Sys::User'
  field :destinations, type: Array
  field :paths, type: Array
  field :number, type: Integer
  field :note, type: String
  field :status, type: Integer, default: START
  before_create :on_before_create

  def normal_destinations
    self.destinations.map do |dest|
      dest['type'].constantize.find(dest['id'])
    end
  end

  private
  def on_before_create
    last = Task.last
    if last.blank? then self.number = 1
    else self.number = last.number + 1 end
    true
  end
end
