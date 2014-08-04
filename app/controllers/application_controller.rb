# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def render(*args); self.nav; super end
  def current_user; @_curr_user ||= (Sys::User.find(session[:user_id]) rescue nil) if session[:user_id] end
  def search_params; params[:search] == 'clear' ? nil : params[:search] end
  helper_method :current_user

  protected
  def nav; @nav = {t('pages.site.index.title') => home_url} end
  def clear_cache; Sys::Cache.clear_map_objects end
end
