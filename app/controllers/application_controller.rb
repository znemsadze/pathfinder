# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :validate_permission

  def render(*args); self.nav; super end
  def current_user; @_curr_user ||= (Sys::User.find(session[:user_id]) rescue nil) if session[:user_id] end
  def search; params[:search] == 'clear' ? nil : params[:search] end
  helper_method :current_user


  protected
  def nav; @nav = {t('pages.site.index.title') => home_url} end

  private
  def validate_permission
    unless Sys::Permission.has_permission?(current_user, controller_path, action_name)
      if current_user then render text: t('pages.application.validate_permission.no_permission')
      else redirect_to login_url, alert: t('pages.application.validate_permission.login_required') end
    end
  end
end
