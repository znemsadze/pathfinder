# -*- encoding : utf-8 -*-
class ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  before_filter :set_access_control_headers
  rescue_from Exception, with: :api_error

  protected
  def authenticate
    user=Sys::User.authenticate(params[:username], params[:password])
    if user and user.active
      yield user
    else
      render json: {error: 'არასწორი მომხამრებლი ან პაროლი'}
    end
  end

  def clear_cache; Sys::Cache.clear_map_objects end

  private

  def api_error(ex)
    render json: { error: ex.to_s }
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = "*"
    headers['Access-Control-Request-Method'] = %w{GET POST OPTIONS}.join(",")
  end
end
