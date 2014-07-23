class ImageConversion
  @queue = :image_conversion

  def self.perform(linename)
    Objects::Tower.where(linename: linename).each do |tower|
      tower.generate_images
    end
  end
end
