# -*- encoding : utf-8 -*-
class Api::UsersController < ApiController
  def login
    @user=Sys::User.authenticate(params[:username], params[:password])
    unless @user and @user.active
      render json: {error: 'არასწორი მომხამრებლი ან პაროლი'}
    end
  end

  def track_point
    user=Sys::User.authenticate(params[:username], params[:password])
    lat=params[:lat].to_f ; lng=params[:lng]
    Tracking::Path.add_point(user, lat, lng)
    render text: 'ok'
  end
end