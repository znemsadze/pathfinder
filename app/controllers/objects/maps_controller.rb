# -*- encoding : utf-8 -*-
class Objects::MapsController < ApplicationController
  def editor; @title='ობიექტების რედაქტირება' ; render layout: 'map' end
  def viewer; @title='ობიექტების რუკა' ; render layout: 'map' end

  def clear_cache
    if request.post?
      expire_action controller: '/api/objects', action: 'index', format: 'json'
      expire_action controller: '/api/objects', action: 'lines', format: 'json'
      expire_action controller: '/api/objects', action: 'pathlines', format: 'json'
      expire_action controller: '/api/objects', action: 'offices', format: 'json'
      expire_action controller: '/api/objects', action: 'substations', format: 'json'
      redirect_to objects_clear_cache_url(status: 'ok')
    else
      @title = 'კეშის გასუფთავება'
    end
  end

  def generate_images
    if request.post?
      Objects::Tower.each { |x| x.generate_images }
      redirect_to objects_generate_images_url(status: 'ok')
    else
      @title = 'გამოსახულებების გენერაცია'
    end
  end

  protected
  def nav
    @nav=super
    @nav[@title]=nil
  end
end
