# -*- encoding : utf-8 -*-
class SiteController < ApplicationController
  def index; @title=t('pages.site.index.title') end

  def login
    @title=t('pages.site.login.title')
    if request.post?
      user = Sys::User.authenticate(params[:username], params[:password])
      if user and user.active 
        session[:user_id] = user.id
        redirect_to root_url
      else @error = t('pages.site.login.illegal_login') end
    end
  end

  protected
  def nav
    @nav=super
    @nav[@title]=nil unless action_name == 'index'
  end
end