# -*- encoding : utf-8 -*-
class Objects::Substation
  include Mongoid::Document
  include Objects::Coordinate
  include Objects::Kml
  include Objects::GeoJson

  field :kmlid, type: String
  field :name, type: String
  field :description, type: String
  belongs_to :region

  def geo_type(opts={}); 'Point' end
  def geo_coordinates(opts={}); [self.lng, self.lat] end

  def self.from_kml(xml)
    parser=XML::Parser.string xml
    doc=parser.parse ; root=doc.child
    kmlns="kml:#{KMLNS}"
    placemarks=doc.child.find '//kml:Placemark',kmlns
    Objects::Substation.delete_all
    placemarks.each do |placemark|
      id=placemark.attributes['id']
      name=placemark.find('./kml:name',kmlns).first.content
      # description content
      descr=placemark.find('./kml:description',kmlns).first.content
      # s1='<td>რეგიონი</td>'
      # idx1=descr.index(s1)+s1.length
      # regname=descr[idx1..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      regname="---"
      region=Region.get_by_name(regname)
      # end of description section
      coord=placemark.find('./kml:Point/kml:coordinates',kmlns).first.content
      obj=Objects::Substation.where(kmlid:id).first || Objects::Substation.create(kmlid:id)
      obj.name=name
      obj.region=region
      obj.set_coordinate(coord)
      obj.save
    end
  end

  def to_kml(xml)
    descr = "<p><strong>#{self.name}</strong></p><p>#{self.description}</p>"
    extra = extra_data('დასახელება' => name,
      'შენიშვნა' => description,
      'რეგიონი' => region.to_s
    )
    xml.Placemark do
      xml.name self.name
      xml.description { xml.cdata! "#{ descr } <!-- #{ extra } -->" }
      xml.Point { xml.coordinates "#{self.lng},#{self.lat},#{self.alt||0}" }
    end
  end
end
