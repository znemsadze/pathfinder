# -*- encoding : utf-8 -*-
class Objects::Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Objects::Coordinate

  belongs_to :task, class_name: 'Task'
  belongs_to :detail, class_name: 'Objects::Path::Detail'
  field :text, type: String
end
