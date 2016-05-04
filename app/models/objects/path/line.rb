# -*- encoding : utf-8 -*-
require 'xml'

class Objects::Path::Line
  include Mongoid::Document
  include Objects::LengthProperty
  include Objects::Kml
  include Objects::GeoJson
  include Mongoid::Timestamps

  belongs_to :detail, class_name: 'Objects::Path::Detail'
  field :point_ids, type: Array, default:[]
  field :name, type: String
  field :description, type: String
  field :kmlid, type: String
  field :directed,type:Integer

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
      s6='<td>სიგრძე</td>'
      s7='<td>X_დასაწყისი</td>'
      s8='<td>Y_დასაწყისი</td>'
      s9='<td>X_დასასრული</td>'
      s10='<td>Y_დასასრული</td>'
      idx1 = descr.index(s1) + s1.length rescue nil
      idx2 = descr.index(s2) + s2.length rescue nil
      idx3 = descr.index(s3) + s3.length rescue nil
      idx4 = descr.index(s4) + s4.length rescue nil
      idx5 = descr.index(s5) + s5.length rescue nil
      idx6 = descr.index(s6) + s6.length rescue nil
      idx7 = descr.index(s7) + s7.length rescue nil
      idx8 = descr.index(s8) + s8.length rescue nil
      idx9 = descr.index(s9) + s9.length rescue nil
      idx10 = descr.index(s10) + s10.length rescue nil
      regname = descr[idx1..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip          if idx1
      line_description = descr[idx2..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip if idx2
      path_type = descr[idx3..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip        if idx3
      path_surface = descr[idx4..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip     if idx4
      path_detail = descr[idx5..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip      if idx5
      path_length= descr[idx6..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip      if idx6
      x_start= descr[idx7..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip      if idx7
      y_start= descr[idx8..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip      if idx8
      x_end= descr[idx9..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip      if idx9
      y_end= descr[idx10..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip      if idx10

      path_length=(path_length.to_f/1000).to_s;

      region = Region.get_by_name(regname)
      type = Objects::Path::Type.get_type(path_type)
      surface = Objects::Path::Surface.get_surface(type, path_surface)
      detail = Objects::Path::Detail.get_detail(surface, path_detail)
      # end of description section
      # puts('path_length='+path_length )
      line = Objects::Path::Line.create(kmlid: id)
      line.name = name ; line.detail = detail ; line.region = region ; line.description = line_description;line.set_legth(path_length);
      coord_strings = coords.split(' ')
      do_reverse=0;
      if(x_start!="&lt;Null&gt;" )
          line.directed=1
          coordsSP=coord_strings[0].split(',').map{|x| x.strip.to_s }
           if((x_start[0,10] !=coordsSP[0][0,10]) ||(y_start!=coordsSP[1][0,10]))
             coord_strings= coord_strings.reverse
           end
      else
          line.directed=0;
      end
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


      line.save ;
      # line.calc_length!
    end
  end

  def points;
    #self.point_ids.map{ |x| Objects::Path::Point.find(x) } end#
    Objects::Path::Point.find(self.point_ids).map{ |x| x } end

  def geo_type(opts={}); 'LineString' end
  def geo_coordinates(opts={})
    pathpoints = opts[:pathpoints]
    if pathpoints.present?
      self.point_ids.map{ |pid| p = pathpoints[pid.to_s] ; [ p[1], p[0] ] }
    else
      self.points.map{ |p| [ p.lng, p.lat ] } 
    end
  end

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
      xml.description { xml.cdata! "<p>#{self.name}, #{self.detail.to_s}</p> <!-- #{ extra } -->" }
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
