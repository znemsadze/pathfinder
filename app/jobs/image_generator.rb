class ImageGenerator
  @queue = :image_generation

  def self.perform(dirname)
    Objects::Tower.where(linename: dirname.to_ka(:all)).each { |x| x.generate_images }
  end
end
