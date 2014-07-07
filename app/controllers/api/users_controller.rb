# -*- encoding : utf-8 -*-
class Api::UsersController < ApiController
  def index; @users = Sys::User.where(active: true).asc(:username) end

  def login
    authenticate do |user|
      @user = user
    end
  end

  def track_point
    user=Sys::User.find(params[:userid])
    Tracking::Path.add_point(user, params[:lat].to_f, params[:lng].to_f)
    render json: {status: 'ok'}
  end
end
