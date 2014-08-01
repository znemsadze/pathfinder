# -*- encoding : utf-8 -*-
class Objects::Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Objects::Coordinate
  include Kml

  belongs_to :task, class_name: 'Task'
  belongs_to :detail, class_name: 'Objects::Path::Detail'
  field :text, type: String

  def to_kml(xml)
    xml.Placemark do
      xml.name "#{task.assignee.username} - #{self.created_at.strftime('%d-%b-%Y')}"
      xml.description "<p>#{self.text}</p> <p>#{self.detail.to_s}</p>"
      extended_data(xml, type: self.detail.surface.type.name, surface: self.detail.surface.name, detail: self.detail.name)
      xml.Point do
        xml.coordinates "#{self.lng},#{self.lat},#{self.alt||0}"
      end
    end
  end
end
