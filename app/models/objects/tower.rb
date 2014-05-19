# -*- encoding : utf-8 -*-
require 'xml'
class Objects::Tower
  include Mongoid::Document
  include Objects::Coordinate

  field :kmlid, type: String
  field :name, type: String

  def self.extract_from_kml(xml)
    parser=XML::Parser.string xml
    doc=parser.parse ; root=doc.child
    kmlns="kml:#{KMLNS}"
    placemarks=doc.child.find '//kml:Placemark',kmlns
    placemarks.each do |placemark|
      id=placemark.attributes['id']
      name=placemark.find('./kml:name',kmlns).first.content
      coord=placemark.find('./kml:Point/kml:coordinates',kmlns).first.content
      obj=Objects::Tower.where(kmlid:id).first || Objects::Tower.new(kmlid:id)
      obj.name=name ; obj.set_coordinate(coord)
      obj.save
    end
  end
end
