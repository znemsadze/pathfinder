# -*- encoding : utf-8 -*-
class ImageConversion
  include Sidekiq::Worker

  def perform(linename)
    Objects::Tower.where(linename: linename).each do |tower|
      puts "#{tower.name}"
      tower.generate_images
    end
  end
end
