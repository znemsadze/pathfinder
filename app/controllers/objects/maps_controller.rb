# -*- encoding : utf-8 -*-
class Objects::MapsController < ApplicationController
  def editor
    @title='ობიექტების რედაქტირება'
    render layout: 'map'
  end

  def clear_cache
    expire_action controller: '/api/objects', action: 'index', format: 'json'
    # url_for(controller: '/api/objects', action: 'index', format: 'json')
    render text: 'კეში გასუფთავებულია'
  end
end
