# -*- encoding : utf-8 -*-
class ImageConversion
  include Sidekiq::Worker

  def perform(linename)
    Objects::Tower.where(linename: linename).each do |tower|
      # puts "#{Time.now}: generate image for: #{linename}, ##{tower.name}"
      tower.generate_images
    end
  end
end
