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
  def thumb_dir; "#{Rails.root}/public/uploads/#{self.id}/thumb" end
  def large_dir; "#{Rails.root}/public/uploads/#{self.id}/large" end
  def thumbnails; self.images.map{ |x| "/uploads/#{self.id}/thumb/#{x}" } end
  def larges; self.images.map{ |x| "/uploads/#{self.id}/large/#{x}" } end
  # def originals; self.images.map{ |x| "/uploads/#{self.id}/original/#{x}" } end

  def generate_images
    images = Dir.glob("#{Pathfinder::POLES_HOME}/#{self.linename.to_lat}/#{self.name}_*.jpg") if self.linename
    if images.present?
      images.each do |url|
        basename = File.basename(url)
        generate_image_from_file(url, basename)
      end
    end
    # self.images = images.map{|x| File.basename(x) } ; self.save
  end

  def generate_images_from_file(filepath, basename)
    original = Magick::Image::read(filepath).first
    large = original.resize_to_fit(800,800).auto_orient
    thumb = large.resize_to_fit(80,80)
    FileUtils.mkdir_p(thumb_dir) ; FileUtils.mkdir_p(large_dir)
    thumb.write("#{thumb_dir}/#{basename}") ; large.write("#{large_dir}/#{basename}")
    thumb.destroy! ; large.destroy! ; original.destroy!
    self.images << basename unless self.images.include?(basename)
    self.save
  end

  def destroy_image(basename)
    File.delete("#{large_dir}/#{basename}")
    File.delete("#{thumb_dir}/#{basename}")
    self.images.delete basename
    self.save
  end
end
