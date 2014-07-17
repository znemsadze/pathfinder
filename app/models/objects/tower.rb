# -*- encoding : utf-8 -*-
require 'RMagick'
require 'xml'

class Objects::Tower
  include Mongoid::Document
  include Objects::Coordinate
  include Objects::Kml

  field :kmlid, type: String
  field :name, type: String
  field :category, type: String
  field :description, type: String
  field :linename, type: String
  field :images, type: Array
  belongs_to :region

  def self.from_kml(xml)
    parser=XML::Parser.string xml
    doc=parser.parse ; root=doc.child
    kmlns="kml:#{KMLNS}"
    placemarks=doc.child.find '//kml:Placemark',kmlns
    placemarks.each do |placemark|
      id=placemark.attributes['id']
      name=placemark.find('./kml:name',kmlns).first.content
      # description content
      descr=placemark.find('./kml:description',kmlns).first.content
      s1='<td>რეგიონი</td>'
      s2='<td>ანძის ტიპი</td>'
      s3='<td>გადამცემი ხაზი</td>'
      idx1=descr.index(s1)+s1.length
      idx2=descr.index(s2)+s2.length
      idx3=descr.index(s3)+s3.length
      regname=descr[idx1..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      category=descr[idx2..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      linename=descr[idx3..-1].match(/<td>([^<])*<\/td>/)[0][4..-6].strip
      region=Region.get_by_name(regname)
      # end of description section
      coord=placemark.find('./kml:Point/kml:coordinates',kmlns).first.content
      obj=Objects::Tower.where(kmlid:id).first || Objects::Tower.create(kmlid:id)
      obj.name=name ; obj.region=region ; obj.set_coordinate(coord)
      obj.category=category ; obj.linename=linename
      obj.save
    end
  end

  def has_images?; self.images.present? end
  def thumbnails; self.images.map{ |x| "/uploads/#{self.id}/thumb/#{x}" } end
  def larges; self.images.map{ |x| "/uploads/#{self.id}/large/#{x}" } end
  # def originals; self.images.map{ |x| "/uploads/#{self.id}/original/#{x}" } end

  def generate_images
    images = Dir.glob("#{Pathfinder::POLES_HOME}/#{self.linename.to_lat}/#{self.name}_*.jpg") if self.linename
    if images.present?
      images.each do |url|
        basename = File.basename(url)
        original = Magick::Image::read(url).first
        large = original.scale(800,600).rotate(90)
        thumb = large.scale(90,120) ; 
        dir1 = "#{Rails.root}/public/uploads/#{self.id}/thumb" ; FileUtils.mkdir_p(dir1)
        dir2 = "#{Rails.root}/public/uploads/#{self.id}/large" ; FileUtils.mkdir_p(dir2)
        #dir3 = "#{Rails.root}/public/uploads/#{self.id}/original" ; FileUtils.mkdir_p(dir3)
        path1 = "#{dir1}/#{basename}"
        path2 = "#{dir2}/#{basename}"
        # path3 = "#{dir3}/#{basename}"
        thumb.write(path1) ; large.write(path2) #; original.write(path3)
        thumb.destroy! ; large.destroy! ; original.destroy!
      end
    end
    self.images = images.map{|x| File.basename(x) } ; self.save
  end
end
