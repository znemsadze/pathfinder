# -*- encoding : utf-8 -*-
class CacheGeneration
  include Sidekiq::Worker

  def perform
    Sys::Cache.map_objects
  end
end
