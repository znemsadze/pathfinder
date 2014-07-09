# -*- encoding : utf-8 -*-
class Objects::MapsController < ApplicationController
  def editor
    @title='ობიექტების რედაქტირება'
    render layout: 'map'
  end

  def clear_cache
    if request.post?
      expire_action controller: '/api/objects', action: 'index', format: 'json'
      redirect_to objects_clear_cache_url(status: 'ok')
    else
      @title = 'კეშის გასუფთავება'
    end
  end

  protected
  def nav
    @nav=super
    @nav[@title]=nil
  end
end
