# -*- encoding : utf-8 -*-
require 'xml'
class Objects::Line
  include Mongoid::Document
  include Objects::Kml

  field :kmlid, type: String
  field :name, type: String
  embeds_many :points, class_name: 'Objects::LinePoint'

  def self.from_kml(xml)
    parser=XML::Parser.string xml
    doc=parser.parse ; root=doc.child
    kmlns="kml:#{KMLNS}"
    placemarks=doc.child.find '//kml:Placemark',kmlns
    placemarks.each do |placemark|
      id=placemark.attributes['id']
      name=placemark.find('./kml:name',kmlns).first.content
      coords=placemark.find('./kml:MultiGeometry/kml:LineString/kml:coordinates',kmlns).first.content
      obj=Objects::Line.where(kmlid:id).first || Objects::Line.create(kmlid:id)
      obj.name=name; obj.save
      obj.points.destroy_all
      coords.split(' ').each do |coord|
        point=obj.points.new(line:obj)
        point.set_coordinate(coord)
        point.save
      end
    end
  end
end

class Objects::LinePoint
  include Mongoid::Document
  include Objects::Coordinate
  embedded_in :line, class_name: 'Objects::Line'
end
