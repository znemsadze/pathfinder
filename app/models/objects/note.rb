# -*- encoding : utf-8 -*-
class Objects::Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Objects::Coordinate

  belongs_to :task, class_name: 'Task'
  belongs_to :detail, class_name: 'Objects::Path::Detail'
  field :text, type: String

  def to_kml(xml)
    xml.Placemark do |xml|
      xml.name "#{task.assignee.username} - #{self.created_at.strftime('%d-%b-%Y')}"
      xml.description "<p>#{self.text}</p> <p>#{self.detail.to_s}</p>"
      xml.Point do |xml|
        xml.coordinates "#{self.lng},#{self.lat},#{self.alt||0}"
      end
    end
  end
end
