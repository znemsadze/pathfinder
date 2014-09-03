# -*- encoding : utf-8 -*-
class Objects::Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Objects::Coordinate
  include Objects::Kml

  belongs_to :task, class_name: 'Task'
  belongs_to :detail, class_name: 'Objects::Path::Detail'
  field :text, type: String

  def to_kml(xml)
    xml.Placemark do
      extra = extra_data('გზის_სახეობა' => self.detail.surface.type.name,
        'გზის_საფარი' => self.detail.surface.name,
        'საფარის_დეტალები' => self.detail.name,
      )
      xml.name "#{task.assignee.username} - #{self.created_at.strftime('%d-%b-%Y')}"
      xml.description { xml.cdata! "<p>#{self.text}</p> <p>#{self.detail.to_s}</p> <!-- #{ extra } -->" }
      xml.Point do
        xml.coordinates "#{self.lng},#{self.lat},#{self.alt||0}"
      end
    end
  end
end
