# -*- encoding : utf-8 -*-
require 'xml'

class Objects::Path::Line
  include Mongoid::Document
  include Objects::LengthProperty
  include Objects::Kml

  belongs_to :detail, class_name: 'Objects::Path::Detail'
  field :point_ids, type: Array, default:[]
  field :name, type: String
  field :description, type: String
  field :kmlid, type: String
  belongs_to :region

  def self.from_kml(xml)
    parser=XML::Parser.string xml
    doc=parser.parse ; root=doc.child
    kmlns="kml:#{KMLNS}"
    placemarks=doc.child.find '//kml:Placemark',kmlns
    Objects::Path::Line.delete_all
    Objects::Path::Point.delete_all
    placemarks.each do |placemark|
      id = placemark.attributes['id']
      name = placemark.find('./kml:name', kmlns).first.content
      coords = placemark.find('./kml:MultiGeometry/kml:LineString/kml:coordinates', kmlns).first.content
      # description content
      descr=placemark.find('./kml:description',kmlns).first.content
      s1='<td>რეგიონი</td>'
      s2='<td>შენიშვნა</td>'
      s3='<td>გზის_სახეობა</td>'
      s4='<td>გზის_საფარი</td>'
      s5='<td>საფარის_დეტალები</td>'
      idx1 = descr.index(s1) + s1.length
      idx2 = descr.index(s2) + s2.length
      idx3 = descr.index(s3) + s3.length
      idx4 = descr.index(s4) + s4.length
      idx5 = descr.index(s5) + s5.length

      regname = descr[idx1..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      line_description = descr[idx2..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      path_type = descr[idx3..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      path_surface = descr[idx4..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      path_detail = descr[idx5..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip

      region = Region.get_by_name(regname)
      type = Objects::Path::Type.get_type(path_type)
      surface = Objects::Path::Surface.get_surface(type, path_surface)
      detail = Objects::Path::Detail.get_detail(surface, path_detail)
      # end of description section

      line = Objects::Path::Line.create(kmlid: id)
      line.name = name ; line.detail = detail ; line.region = region ; line.description = line_description
      coord_strings = coords.split(' ')
      coord_strings.each_with_index do |coord, index|
        edge = ( index == 0 || index == coord_strings.length - 1 )
        point = Objects::Path::Point.new(edge: edge) ; point.set_coordinate(coord)
        if edge
          existing = Objects::Path::Point.where(edge: true, location: [point.lng, point.lat]).first
          point = existing if existing.present?
        end
        point.pathline_ids << line.id
        point.save
        line.point_ids << point.id
      end
      line.save ; line.calc_length!
    end
  end

  def points; self.point_ids.map{|x|Objects::Path::Point.find(x)} end

  def to_kml(xml)
    extra = extra_data('რეგიონი' => region.to_s,
      'სიგრძე' => length,
      'შენიშვნა' => description,
      'დასახელება' => name,
      'გზის_სახეობა' => self.detail.surface.type.name,
      'გზის_საფარი' => self.detail.surface.name,
      'საფარის_დეტალები' => self.detail.name,
    )
    xml.Placemark(id: "ID_#{self.id.to_s}") do |xml|
      xml.name self.name
      xml.description "<p>#{self.name}, #{self.detail.to_s}</p> <!-- #{extra} -->"
      xml.MultiGeometry do |xml|
        xml.LineString do
          xml.extrude 0
          xml.altitudeMode 'clampedToGround'
          xml.coordinates ' ' + self.points.map{|p| [p.lng, p.lat, p.alt||0].join(',')}.join(' ')
        end
      end
    end
  end

  private

  def splitat(point)
    point.path_ids.each do |pathid|
      path=Objects::Path::Line.find(pathid)
      unless path.edge?(point)
        points=path.points
        idx=points.index(point)
        new_path=Objects::Path::Line.create(detail:path.detail, description:path.description)
        points[idx..-1].each do |p|
          p.path_ids.push(new_path.id)
          unless p==point
            p.path_ids.delete(pathid)
            path.point_ids.delete(p.id)
          end
          p.save
          new_path.point_ids<<p.id
        end
        new_path.save
        path.save
        # delete duplicate paths
        validate_unique(new_path)
        validate_unique(path)
      end
    end
  end

  def validate_unique(path)
    if Objects::Path::Line.where(point_ids: path.point_ids).count>1
      path.points.each do |point|
        point.path_ids.delete path.id
        point.save
      end
      path.destroy
    end
  end
end
