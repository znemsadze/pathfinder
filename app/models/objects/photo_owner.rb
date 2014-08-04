module Objects::PhotoOwner
  def self.included(base)
    base.has_many :photos, class_name: 'Objects::Photo', as: :owner
  end

  def images; self.photos.all.map{ |x| x.filename } end
  def has_images?; self.photos.any? end
  def thumb_dir; "#{Rails.root}/public/uploads/#{self.id}/thumb" end
  def large_dir; "#{Rails.root}/public/uploads/#{self.id}/large" end
  def thumb_url; "/uploads/#{self.id}/thumb" end
  def large_url; "/uploads/#{self.id}/large" end

  def thumbnails; self.photos.all.map{ |x| "#{thumb_url}/#{x.filename}" } end
  def larges; self.photos.all.map{ |x| "#{large_url}/#{x.filename}" } end

  def generate_images_from_file(filepath, basename, confirmed=true)
    original = Magick::Image::read(filepath).first
    large = original.resize_to_fit(800,800).auto_orient
    thumb = large.resize_to_fit(80,80)
    FileUtils.mkdir_p(thumb_dir) ; FileUtils.mkdir_p(large_dir)
    thumb.write("#{thumb_dir}/#{basename}") ; large.write("#{large_dir}/#{basename}")
    thumb.destroy! ; large.destroy! ; original.destroy!
    Objects::Photo.where(owner: self, filename: basename).destroy_all
    Objects::Photo.create(owner: self, filename: basename, confirmed: confirmed)
  end

  def destroy_image(basename)
    File.delete("#{large_dir}/#{basename}")
    File.delete("#{thumb_dir}/#{basename}")
    self.photos.where(filename: basename).destroy_all
  end
end
