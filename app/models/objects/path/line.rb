# -*- encoding : utf-8 -*-
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

  def self.new_path(points,params)
    if points.uniq.size>1
      path=Objects::Path::Line.create(description:params[:description], detail_id:params[:detail_id], region_id: params[:region_id])
      points.each do |p|
        if p.is_a?(Objects::Path::Point) then point=p
        else
          if p.is_a?(Hash) then lat,lng=p['lat'],p['lng']
          else lat,lng=p[0],p[1] end
          point=Objects::Path::Point.where(location: [lng,lat]).first || Objects::Path::Point.new(location: [lng,lat], path_ids: [])
        end
        point.path_ids.push(path.id)
        path.point_ids.push(point.id)
        point.save
      end
      path.point_ids=path.point_ids.uniq
      path.save
      path
    end
  end

  def update_path(points,params)
    if points.uniq.size>1
      existing_points=self.points
      self.point_ids=[]
      existing_points.each{|x| x.path_ids.delete(self.id); x.save }
      points.each_with_index do |p,i|
        if p.is_a?(Hash) then lat,lng=p['lat'],p['lng']
        else lat,lng=p[0],p[1] end
        point=Objects::Path::Point.where(location: [lng,lat]).first
        if existing_points.any? and point.blank? and (i==0 or i==points.length-1)
          point=(i==0 ? existing_points.first : existing_points.last)
          if self.point_ids.include?(point.id)
            point=nil
          else
            point.lat=lat ; point.lng=lng
          end
        end
        point=Objects::Path::Point.new(lat: lat,lng: lng, path_ids: []) if point.blank?
        point.path_ids.push(self.id) unless point.path_ids.include?(self.id)
        point.save
        self.point_ids.push(point.id)
      end
      self.save
      self.update_attributes(name: params[:name], description:params[:description], detail_id:params[:detail_id], region_id: params[:region_id])
    end
  end

  def destroy_path
    self.points.each{|x| x.path_ids.delete(self.id); x.save }
    self.destroy
  end

  def points; self.point_ids.map{|x|Objects::Path::Point.find(x)} end
  def neighbours; points.map{|x|x.path_ids}.flatten.uniq end

  def edge?(p)
    id=p.is_a?(Objects::Path::Point) ? p.id : p
    point_ids.first==id or point_ids.last==id
  end

  def splitjoin
    self.point_ids.each do |point_id|
      point=Objects::Path::Point.find(point_id)
      route_count=point.route_count
      splitat(point) if (point.path_count>1 and route_count>2)
    end
  end

  def self.from_kml(xml)
    parser=XML::Parser.string xml
    doc=parser.parse ; root=doc.child
    kmlns="kml:#{KMLNS}"
    placemarks=doc.child.find '//kml:Placemark',kmlns
    placemarks.each do |placemark|
      id = placemark.attributes['id']
      name = placemark.find('./kml:name', kmlns).first.content
      coords = placemark.find('./kml:MultiGeometry/kml:LineString/kml:coordinates', kmlns).first.content

      # description content
      # descr=placemark.find('./kml:description',kmlns).first.content
      # s1='<td>რეგიონი</td>'
      # s2='<td>მიმართულება</td>'
      # idx1=descr.index(s1)+s1.length
      # idx2=descr.index(s2)+s2.length
      # regname=descr[idx1..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      # direction=descr[idx2..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      # region=Region.where(name:regname).first
      # region=Region.create(name:regname) if region.blank?
      # end of description section

      detail = Objects::Path::Detail.first # XXX
      region = Region.first # XXX
      params = { name: name, description: '', detail_id: detail.id, region_id: region.id }
      points = coords.split(' ').map do |text|
        coords = text.split(',').map{ |x| x.strip.to_f }
        { 'lng' => coords[0],  'lat' => coords[1] }
      end
      line = Objects::Path::Line.where(kmlid: id).first || Objects::Path::Line.create(kmlid: id)
      line.update_path(points, params)
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
